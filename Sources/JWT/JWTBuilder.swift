//
//  JWTBuilder.swift
//  AppStoreConnect-Swift-SDK
//
//  Created by Michael Schwarz on 06.02.19.
//

import Foundation
import SwiftJWT


/// Creates a JWT Token used for communication with AppstoreConnectAPI
struct JWTBuilder {

    enum Error: Swift.Error {
        case invalidPrivateKey
    }

    private struct AudienceClaim: Claims {
        /// Your issuer identifier from the API Keys page in App Store Connect (Ex: 57246542-96fe-1a63-e053-0824d011072a)
        let issuerIdentifier: String
        /// The required audience which is set to the App Store Connect version.
        let audience: String = "appstoreconnect-v1"
        /// The token's expiration time, in Unix epoch time; tokens that expire more than 20 minutes in the future are not valid (Ex: 1528408800)
        let expirationTime: Date

        enum CodingKeys: String, CodingKey {
            case issuerIdentifier = "iss"
            case expirationTime = "exp"
            case audience = "aud"
        }
    }

    // MARK: Properties

    let issuerID: String
    let pKeyID: String
    let pKey: String
    let expireDuration: TimeInterval


    init(issuerID: String,
         pKeyID: String,
         pKey: String,
         expireDuration: TimeInterval = 60 * 20) {
        self.issuerID = issuerID
        self.pKeyID = pKeyID
        self.pKey = pKey
        self.expireDuration = expireDuration
    }

    func makeJWTToken() throws -> String {
        var jwt = JWT(header: .init(kid: self.pKeyID), claims: AudienceClaim(issuerIdentifier: self.issuerID, expirationTime: Date().addingTimeInterval(self.expireDuration)))
        guard let base64Data = Data(base64Encoded: self.pKey) else { throw Error.invalidPrivateKey }

        return try jwt.sign(using: JWTSigner.rs256(privateKey: base64Data))
    }
}
