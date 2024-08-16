//
//  URL+Xc.swift
//
//
//  Created by Jaehong Kang on 8/16/24.
//

import Foundation

extension URL {
    static let appleSignIn = URL(string: "https://idmsa.apple.com/appleauth/auth/signin")!
}

extension URL {
    static let appleOlympusAPIv1 = URL(string: "https://appstoreconnect.apple.com/olympus/v1/")!

    init?(appleOlympusAPIv1Path path: String) {
        self.init(string: path, relativeTo: Self.appleOlympusAPIv1)
    }
}
