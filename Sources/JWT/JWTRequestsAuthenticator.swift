//
//  JWTAuthenticator.swift
//  AppStoreConnect-Swift-SDK
//
//  Created by Antoine van der Lee on 08/11/2018.
//

import Foundation


/// An Authenticator for URL Requests which makes use of the RequestAdapter from Alamofire.
final class JWTRequestsAuthenticator {

    private var cachedToken: JWTToken?
    private let apiConfiguration: APIConfiguration

    /// The JWT Builder to use for creating the JWT token. Can be overriden for test use cases.
   var jwtBuilder: JWTBuilderProtocol

    init(apiConfiguration: APIConfiguration) {
        self.apiConfiguration = apiConfiguration

        self.jwtBuilder = JWTBuilder(issuerID: apiConfiguration.issuerID,
                                     pKeyID: apiConfiguration.privateKeyID,
                                     pKey: apiConfiguration.privateKey,
                                     expireDuration: 60 * 20)
    }

    /// Generates a new JWT Token, but only if the in memory cached one is not expired.
    private func createToken() throws -> JWTToken {
        if let cachedToken = cachedToken, self.jwtBuilder.validate(cachedToken) {
            return cachedToken
        }

        let token = try self.jwtBuilder.makeJWTToken()
        self.cachedToken = token
        return token
    }
}

extension JWTRequestsAuthenticator {

    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        let token = try createToken()
        var urlRequest = urlRequest
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return urlRequest
    }
}
