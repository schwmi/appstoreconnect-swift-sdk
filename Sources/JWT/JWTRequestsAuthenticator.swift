//
//  JWTAuthenticator.swift
//  AppStoreConnect-Swift-SDK
//
//  Created by Antoine van der Lee on 08/11/2018.
//

import Foundation
import JWT

/// An Authenticator for URL Requests which makes use of the RequestAdapter from Alamofire.
final class JWTRequestsAuthenticator {

    private var cachedJWT: JWT?
    private var cachedToken: String?
    private let apiConfiguration: APIConfiguration

    /// The JWT Creator to use for creating the JWT token. Can be overriden for test use cases.
    let signer: ES256Signer

    init(apiConfiguration: APIConfiguration) {
        let es256Key = ES256Key(pemString: apiConfiguration.privateKey)
        self.signer = ES256Signer(privateKey: es256Key)
        self.apiConfiguration = apiConfiguration
    }

    /// Generates a new JWT Token, but only if the in memory cached one is not expired.
    private func createToken() throws -> String {
        if let cachedJWT = self.cachedJWT, let cachedToken = self.cachedToken, !cachedJWT.isExpired {
            return cachedToken
        }

        let jwt = JWT(header: .init(keyIdentifier: self.apiConfiguration.privateKeyID),
            payload: .init(issuerIdentifier: self.apiConfiguration.issuerID,
                           expirationTime: Date().timeIntervalSince1970 + 60 * 15),
            signer: self.signer)
        let token = try jwt.makeToken()
        self.cachedJWT = jwt
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

extension JWT {

    var isExpired: Bool {
        // TODO: Implement
        return true
    }
}
