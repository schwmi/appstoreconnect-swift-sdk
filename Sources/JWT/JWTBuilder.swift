//
//  JWTBuilder.swift
//  AppStoreConnect-Swift-SDK
//
//  Created by Michael Schwarz on 06.02.19.
//

import Foundation


/// JWT Token used for communication with AppstoreConnectAPI
struct JWTBuilder {

    // MARK: Properties

    let teamID: String
    let pKeyID: String
    let ec256Key: String


    init(teamID: String = "W6L39UYL6Z",
         pKeyID: String = "32V623CUSS",
         pKey: String) {
        self.teamID = teamID
        self.pKeyID = pKeyID
        self.ec256Key = ES256Transformer(pKey: pKey).makeES256Key()
    }

    func makeJWT() throws -> String {
        let claims: [Claim] = [IssuerClaim(string: self.teamID), IssuedAtClaim()]
        let additionalHeaders: [Header] = [KeyID(self.pKeyID)]

        return try JWT(additionalHeaders: additionalHeaders,
                       payload: JSON(claims),
                       signer: ES256(key: self.ec256Key.bytes.base64Decoded)).createToken()
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
