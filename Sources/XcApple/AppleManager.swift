//
//  AppleManager.swift
//
//
//  Created by Jaehong Kang on 8/16/24.
//

import Foundation
import Crypto
import JSONValue

package actor AppleManager {
    nonisolated let urlSession = URLSession(configuration: .ephemeral)

    private var _itcServiceKey: String?
    private nonisolated var itcServiceKey: String {
        get async throws {
            if let itcServiceKey = await _itcServiceKey {
                return itcServiceKey
            }

            return try await updateITCServiceKey()
        }
    }

    package init() {

    }

    nonisolated func signIn(
        appleID: String,
        password: String
    ) async throws {
        let itcServiceKey = try await itcServiceKey
        let hashCash = try await fetchHashCash(itcServiceKey)

        var signInRequest = URLRequest(url: .appleSignIn)
        signInRequest.httpMethod = "POST"
        signInRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        signInRequest.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        signInRequest.setValue(itcServiceKey, forHTTPHeaderField: "X-Apple-Widget-Key")
        signInRequest.setValue("application/json, text/javascript", forHTTPHeaderField: "Accept")
        signInRequest.setValue(hashCash, forHTTPHeaderField: "X-Apple-HC")

        let signInRequestBody: JSONValue.Object = [
            "accountName": .string(appleID),
            "password": .string(password),
            "rememberMe": .bool(true),
        ]

        signInRequest.httpBody = try JSONEncoder().encode(signInRequestBody)

        let (data, response) = try await urlSession.data(for: signInRequest)

        guard let response = response as? HTTPURLResponse else {
            throw XcAppleError.invalidURLResponse
        }

        switch response.statusCode {
        case 200..<300: // OK
            break
        case 400..<500: // Client Error
            break
        case 500..<600: // Server Error
            break
        default:
            fatalError("This should not be happend.")
        }

        dump(response)
    }

    func updateITCServiceKey() async throws -> String {
        let itcServiceKey = try await fetchITCServiceKey()
        _itcServiceKey = itcServiceKey
        return itcServiceKey
    }

    nonisolated func fetchITCServiceKey() async throws -> String {
        let appConfigResponse = try await urlSession.data(from: .init(appleOlympusAPIv1Path: "app/config?hostname=itunesconnect.apple.com")!)

        let appConfig = try JSONDecoder().decode(JSONValue.Object.self, from: appConfigResponse.0)

        guard let authServiceKey = appConfig["authServiceKey"]?.stringValue else {
            throw XcAppleError.invalidITCServiceKey
        }

        return authServiceKey
    }

    nonisolated func fetchHashCash(_ itcServiceKey: String) async throws -> String {
        var urlComponents = URLComponents(url: .appleSignIn, resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [.init(name: "widgetKey", value: itcServiceKey)]

        let response = try await urlSession.data(from: urlComponents.url!)

        guard
            let httpResponse = response.1 as? HTTPURLResponse,
            let hcBits = httpResponse.value(forHTTPHeaderField: "X-Apple-HC-Bits").flatMap({Int($0)}),
            let hcChallenge = httpResponse.value(forHTTPHeaderField: "X-Apple-HC-Challenge")
        else {
            throw XcAppleError.invalidHashCashHeader
        }

        return try Self.generateHashCash(bits: hcBits, challenge: hcChallenge)
    }
}

extension AppleManager {
    static func generateHashCash(
        bits: Int,
        challenge: String
    ) throws -> String {
        guard bits <= Insecure.SHA1.byteCount else {
            throw XcAppleError.cannotGenerateHashCash
        }

        let version: Int = 1
        let date: Date = .init()

        let hashCashDateFormatter = DateFormatter()
        hashCashDateFormatter.locale = Locale(identifier: "en_US")
        hashCashDateFormatter.dateFormat = "yyyyMMddHHmmss"

        let hashCashPrefix = [String(version), String(bits), hashCashDateFormatter.string(from: date), challenge, ""].joined(separator: ":")

        for counter in 0..<Int.max {
            let hashCash = [hashCashPrefix, String(counter)].joined(separator: ":")
            let sha1Digest = Array(Insecure.SHA1.hash(data: Array(hashCash.utf8)))

            if sha1Digest.leadingZeroBitCount == bits {
                return hashCash
            }
        }

        throw XcAppleError.cannotGenerateHashCash
    }
}
