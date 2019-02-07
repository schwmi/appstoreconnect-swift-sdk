//
//  JWTBuilder.swift
//  AppStoreConnect-Swift-SDK
//
//  Created by Michael Schwarz on 06.02.19.
//

import Foundation
import JWT


typealias JWTToken = String

protocol JWTBuilderProtocol {
    func makeJWTToken() throws -> JWTToken
    func validate(_ token: JWTToken) -> Bool
}

/// Creates a JWT Token used for communication with AppstoreConnectAPI
struct JWTBuilder: JWTBuilderProtocol {

    enum Error: Swift.Error {
        case invalidPrivateKey
        case tokenGeneration
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

    func makeJWTToken() throws -> JWTToken {
        let expirationDate = Date().addingTimeInterval(self.expireDuration)

        let claims: [Claim] = [IssuerClaim(string: self.issuerID), ExpirationTimeClaim(date: expirationDate), AudienceClaim(string: "appstoreconnect-v1")]
        let additionalHeaders: [Header] = [KeyID(self.pKeyID)]
        let signer = ES256(bytes: self.pKey.bytes.base64Decoded)

        let jwt = try JWT(additionalHeaders: additionalHeaders, payload: JSON(claims), signer: signer)
        return try jwt.createToken()
    }

    func validate(_ token: JWTToken) -> Bool {
        do {
            let token = try JWT(token: token)
            guard let expirationTimeStamp = token.payload[ExpirationTimeClaim.name]?.int else { return false }

            return ExpirationTimeClaim(date: Date()).verify(expirationTimeStamp)
        } catch {
            return false
        }
    }
}

// MARK: - Private

fileprivate extension JWTBuilder {

    struct KeyID: Header {

        static let name = "kid"
        var node: Node

        init(_ keyID: String) {
            node = Node(keyID)
        }
    }
}
