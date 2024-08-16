//
//  AppleManagerTests.swift
//  
//
//  Created by Jaehong Kang on 8/16/24.
//

import XCTest
@testable import XcApple

final class AppleManagerTests: XCTestCase {
    static var appleID: String {
        ProcessInfo.processInfo.environment["XC_APPLE_ID"] ?? ""
    }

    static var appleIDPassword: String {
        ProcessInfo.processInfo.environment["XC_APPLE_ID_PASSWORD"] ?? ""
    }

//    func testSignIn() async throws {
//        let appleManager = AppleManager()
//
//        try await appleManager.signIn(appleID: Self.appleID, password: Self.appleIDPassword)
//    }
}
