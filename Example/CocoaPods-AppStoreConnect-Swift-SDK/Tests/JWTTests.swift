//
//  JWTTests.swift
//  AppStoreConnect-Swift-SDK_Tests
//
//  Created by Antoine van der Lee on 11/11/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import AppStoreConnect_Swift_SDK

final class JWTTests: XCTestCase {

    private let configuration = APIConfiguration(
        issuerID: "1000A0B5-E42D-4A0A-ACD8-9B35B7AC0DB2",
        privateKeyID: "941C4473-70BF-488F-A1C6-6A3F81337D0D",
        privateKey: "MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgPaXyFvZfNydDEjxgjUCUxyGjXcQxiulEdGxoVbasV3GgCgYIKoZIzj0DAQehRANCAASflx/DU3TUWAoLmqE6hZL9A7i0DWpXtmIDCDiITRznC6K4/WjdIcuMcixy+m6O0IrffxJOablIX2VM8sHRscdr")

    /// It should report an invalid P8 private key.
    func testInvalidP8PrivateKey() {
        let jwtBuilder = JWTBuilder(issuerID: configuration.issuerID,
                                    pKeyID: configuration.privateKeyID,
                                    pKey: "&^&%^$%$%",
                                    expireDuration: 20)

        XCTAssertThrowsError(try jwtBuilder.makeJWTToken()) { error in
            XCTAssertEqual(error as? JWTBuilder.Error, JWTBuilder.Error.invalidPrivateKey)
        }
    }
}
