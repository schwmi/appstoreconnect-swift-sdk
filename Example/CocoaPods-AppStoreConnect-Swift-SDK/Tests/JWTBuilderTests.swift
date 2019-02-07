//
//  JWTBuilderTests.swift
//  AppStoreConnect-Swift-SDK_Tests
//
//  Created by Antoine van der Lee on 11/11/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import AppStoreConnect_Swift_SDK

final class JWTBuilderTests: XCTestCase {

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

    /// Test JWTToken generation
    func testTokenGeneration() {
        do {
            let jwtBuilder = JWTBuilder(issuerID: configuration.issuerID,
                                        pKeyID: configuration.privateKeyID,
                                        pKey: configuration.privateKey,
                                        expireDuration: 20)

            do {
                _ = try jwtBuilder.makeJWTToken()
            } catch {
                XCTFail("Unexpected error \(error)")
            }
        }

        do {
            let jwtBuilder = JWTBuilder(issuerID: configuration.issuerID,
                                        pKeyID: configuration.privateKeyID,
                                        pKey: configuration.privateKey,
                                        expireDuration: 0,
                                        referenceDate: Date.distantPast)

            do {
                let token = try jwtBuilder.makeJWTToken()
                let tokenComponents = token.components(separatedBy: ".")
                guard tokenComponents.count == 3 else {
                    XCTFail("We expect 3 components")
                    return
                }
                let header = tokenComponents[0]
                let payload = tokenComponents[1]
                XCTAssertEqual(header, "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijk0MUM0NDczLTcwQkYtNDg4Ri1BMUM2LTZBM0Y4MTMzN0QwRCJ9")
                XCTAssertEqual(payload, "eyJpc3MiOiIxMDAwQTBCNS1FNDJELTRBMEEtQUNEOC05QjM1QjdBQzBEQjIiLCJleHAiOi02MjEzNTc2OTYwMCwiYXVkIjoiYXBwc3RvcmVjb25uZWN0LXYxIn0")
            } catch {
                XCTFail("Unexpected error \(error)")
            }
        }
    }

    /// Test JWTToken validation
    func testTokenValidation() {
        // Valid JWT
        do {
            let jwtBuilder = JWTBuilder(issuerID: configuration.issuerID,
                                        pKeyID: configuration.privateKeyID,
                                        pKey: configuration.privateKey,
                                        expireDuration: 20)

            do {
                let token = try jwtBuilder.makeJWTToken()
                XCTAssertTrue(jwtBuilder.validate(token))
            } catch {
                XCTFail("Unexpected error \(error)")
            }
        }

        // Expired
        do {
            let jwtBuilder = JWTBuilder(issuerID: configuration.issuerID,
                                        pKeyID: configuration.privateKeyID,
                                        pKey: configuration.privateKey,
                                        expireDuration: -20)

            do {
                let token = try jwtBuilder.makeJWTToken()
                XCTAssertFalse(jwtBuilder.validate(token))
            } catch {
                XCTFail("Unexpected error \(error)")
            }
        }
    }
}
