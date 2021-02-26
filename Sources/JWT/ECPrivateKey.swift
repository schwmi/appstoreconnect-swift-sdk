//
//  ECPrivateKey.swift
//  AppStoreConnect-Swift-SDK
//
//  Created by Antoine van der Lee on 08/11/2018.
//

import Foundation
import Crypto
import CCryptoBoringSSL

public typealias ECPrivateKey = SecKey

extension ECPrivateKey {
    public func es256Sign(digest: String) throws -> String {
        guard let message = digest.data(using: .utf8) else {
            throw JWT.Error.ES256SigningFailed
        }

        var sha256 = SHA256()
        sha256.update(data: message)
        let digest = sha256.finalize()

        let algorithm = SecKeyAlgorithm.ecdsaSignatureDigestX962SHA256

        guard SecKeyIsAlgorithmSupported(self, .sign, algorithm)
            else {
                throw JWT.Error.ES256SigningFailed
        }

        var error: Unmanaged<CFError>?

        guard let signature = SecKeyCreateSignature(self, algorithm, Data(digest) as CFData, &error) else {
            throw JWT.Error.privateKeyConversionFailed
        }

        let rawSignature = try (signature as ASN1).toRawSignature()

        return rawSignature.base64URLEncoded()
    }
}
