//
//  UUID+Deterministic.swift
//  ConferenceModels
//

#if canImport(CryptoKit)
import CryptoKit
#endif
#if canImport(Crypto)
import Crypto
#endif
import Foundation

extension UUID {
    /// Generates a deterministic RFC 4122 v5-style UUID by hashing the input string with SHA-256.
    ///
    /// The resulting UUID is always identical for identical inputs across all platforms and processes.
    public static func deterministic(from key: String) -> UUID {
        let digest = SHA256.hash(data: Data(key.utf8))
        var bytes = Array(digest.prefix(16))
        
        // Version 5 (SHA-based): Set bits 4-7 of time_hi_and_version to 0101 (5)
        bytes[6] = (bytes[6] & 0x0F) | 0x50
        // RFC 4122 variant: Set bits 6-7 of clock_seq_hi_and_reserved to 10
        bytes[8] = (bytes[8] & 0x3F) | 0x80
        
        return UUID(uuid: (
            bytes[0], bytes[1], bytes[2],  bytes[3],
            bytes[4], bytes[5], bytes[6],  bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15]
        ))
    }
    
    /// Generates a deterministic UUID by joining multiple string components with a delimiter.
    public static func deterministic(components: String...) -> UUID {
        deterministic(from: components.joined(separator: ":"))
    }
}
