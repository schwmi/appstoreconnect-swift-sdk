//
//  JWTRequestsAuthenticatorTests.swift
//  AppStoreConnect-Swift-SDK_Tests
//
//  Created by Antoine van der Lee on 10/11/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import AppStoreConnect_Swift_SDK


final class JWTRequestsAuthenticatorTests: XCTestCase {

    private let configuration = APIConfiguration(issuerID: UUID().uuidString, privateKeyID: UUID().uuidString, privateKey: "MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgPaXyFvZfNydDEjxgjUCUxyGjXcQxiulEdGxoVbasV3GgCgYIKoZIzj0DAQehRANCAASflx/DU3TUWAoLmqE6hZL9A7i0DWpXtmIDCDiITRznC6K4/WjdIcuMcixy+m6O0IrffxJOablIX2VM8sHRscdr")
    private lazy var urlRequest = URLRequest(url: URL(string: "www.avanderlee.com")!)

    /// It should correctly set the authorization header.
    func testAuthorizationHeader() {
        let authenticator = JWTRequestsAuthenticator(apiConfiguration: configuration)
        let jwtBuilder = MockJWTBuilder()
        authenticator.jwtBuilder = jwtBuilder
        let request = try! authenticator.adapt(urlRequest)
        XCTAssertTrue(request.allHTTPHeaderFields?["Authorization"] == "Bearer \(jwtBuilder.token)")
    }

    /// It should return the cached bearer if it's not expired.
    func testCachedBearer() {
        let authenticator = JWTRequestsAuthenticator(apiConfiguration: configuration)
        var jwtBuilder = MockJWTBuilder(token: "firstTestToken", cachedTokenIsValid: true)
        authenticator.jwtBuilder = jwtBuilder
        _ = try! authenticator.adapt(urlRequest)
        jwtBuilder.token = "secondTestToken"
        authenticator.jwtBuilder = jwtBuilder

        let request = try! authenticator.adapt(urlRequest)
        XCTAssertEqual(request.allHTTPHeaderFields!["Authorization"], "Bearer firstTestToken")
    }

    /// It should return a new token if the cached token is expired.
    func testExpiredBearer() {
        let authenticator = JWTRequestsAuthenticator(apiConfiguration: configuration)
        var jwtBuilder = MockJWTBuilder(token: "firstTestToken", cachedTokenIsValid: true)
        authenticator.jwtBuilder = jwtBuilder
        _ = try! authenticator.adapt(urlRequest)
        jwtBuilder.cachedTokenIsValid = false
        jwtBuilder.token = "secondTestToken"
        authenticator.jwtBuilder = jwtBuilder

        let request = try! authenticator.adapt(urlRequest)
        XCTAssertEqual(request.allHTTPHeaderFields!["Authorization"], "Bearer secondTestToken")
    }
}

private struct MockJWTBuilder: JWTBuilderProtocol {

    var token: JWTToken = "dummyToken"
    var cachedTokenIsValid: Bool = true

    func makeJWTToken() throws -> JWTToken {
        return self.token
    }

    func validate(_ token: JWTToken) -> Bool {
        return self.cachedTokenIsValid
    }
}
