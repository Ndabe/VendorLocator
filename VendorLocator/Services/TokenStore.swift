//
//  TokenStore.swift
//  VendorLocator
//
//  Created by Ndabenhle Langa on 2026/09/20.
//

import Foundation
import Security

protocol TokenStoring {
    func readToken() throws -> String?
    func save(token: String) throws
    func clearToken() throws
}

enum TokenStoreError: LocalizedError {
    case unexpectedStatus(OSStatus)
    case invalidStoredToken
    
    var errorDescription: String? {
        switch self {
        case .unexpectedStatus:
            "The session token could not be updated."
        case .invalidStoredToken:
            "The stored session token could not be read."
        }
    }
}

struct KeychainTokenStore: TokenStoring {
    private let service: String
    private let account = "session-token"
    
    init(service: String = Bundle.main.bundleIdentifier ?? "VendorLocator") {
        self.service = service
    }
    
    func readToken() throws -> String? {
        let query = baseQuery.merging([
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]) { _, new in new }
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        switch status {
        case errSecSuccess:
            guard let data = result as? Data,
                  let token = String(data: data, encoding: .utf8) else {
                throw TokenStoreError.invalidStoredToken
            }
            return token
        case errSecItemNotFound:
            return nil
        default:
            throw TokenStoreError.unexpectedStatus(status)
        }
    }
    
    func save(token: String) throws {
        let tokenData = Data(token.utf8)
        let update = [kSecValueData as String: tokenData]
        let status = SecItemUpdate(baseQuery as CFDictionary, update as CFDictionary)
        
        if status == errSecItemNotFound {
            let item = baseQuery.merging([
                kSecValueData as String: tokenData,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            ]) { _, new in new }
            let addStatus = SecItemAdd(item as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw TokenStoreError.unexpectedStatus(addStatus)
            }
            return
        }
        
        guard status == errSecSuccess else {
            throw TokenStoreError.unexpectedStatus(status)
        }
    }
    
    func clearToken() throws {
        let status = SecItemDelete(baseQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw TokenStoreError.unexpectedStatus(status)
        }
    }
    
    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}
