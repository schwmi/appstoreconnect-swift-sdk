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

    private struct Payload: JWTPayload {

        /// Your issuer identifier from the API Keys page in App Store Connect (Ex: 57246542-96fe-1a63-e053-0824d011072a)
        let issuerIdentifier: IssuerClaim
        /// The required audience which is set to the App Store Connect version.
        let audience: AudienceClaim = "appstoreconnect-v1"
        /// The token's expiration time, in Unix epoch time; tokens that expire more than 20 minutes in the future are not valid (Ex: 1528408800)
        let expirationDate: ExpirationClaim

        enum CodingKeys: String, CodingKey {
            case issuerIdentifier = "iss"
            case expirationDate = "exp"
            case audience = "aud"
        }

        func verify(using signer: JWTSigner) throws {
            try expirationDate.verifyNotExpired()
        }
    }

    // MARK: Properties

    let issuerID: String
    let pKeyID: String
    let pKey: String
    let expireDuration: TimeInterval
    let referenceDate: Date

    init(issuerID: String,
         pKeyID: String,
         pKey: String,
         expireDuration: TimeInterval = 60 * 20,
         referenceDate: Date = Date()) {
        self.issuerID = issuerID
        self.pKeyID = pKeyID
        self.pKey = pKey
        self.referenceDate = referenceDate
        self.expireDuration = expireDuration
    }

    func makeJWTToken() throws -> JWTToken {
        let expirationDate = self.referenceDate.addingTimeInterval(self.expireDuration)
        let header = JWTHeader(alg: "ES256", typ: "JWT", kid: self.pKeyID)
        let payload = Payload(issuerIdentifier: IssuerClaim(value: self.issuerID), expirationDate: ExpirationClaim(value: expirationDate))
        let jwt = JWT(header: header, payload: payload)
        let signer = try self.makeSigner()
        let signed = try jwt.sign(using: signer)
        guard let token = String(data: signed, encoding: .utf8) else { throw Error.tokenGeneration }

        return token
    }

    func validate(_ token: JWTToken) -> Bool {
        do {
            let signer = try self.makeSigner()
            _ = try JWT<Payload>(from: token, verifiedUsing: signer)
            return true
        } catch {
            return false
        }
    }
}

// MARK: - Private

private extension JWTBuilder {

    func makeSigner() throws -> JWTSigner {
        guard let privateKey = Data(base64Encoded: self.pKey) else { throw Error.invalidPrivateKey }

        return JWTSigner(algorithm: ES256(key: privateKey))
    }
}
