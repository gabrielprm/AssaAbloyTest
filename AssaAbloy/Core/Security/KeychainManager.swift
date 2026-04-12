import Foundation
import Security

protocol TokenManaging {
    func saveToken(_ token: String) throws
    func getToken() throws -> String?
    func saveEmail(_ email: String) throws
    func getEmail() throws -> String?
    func clear() throws
}

enum KeychainError: Error {
    case duplicateEntry
    case unknown(OSStatus)
    case unhandledError(status: OSStatus)
}

class KeychainManager: TokenManaging {
    static let shared = KeychainManager()
    
    private let tokenAccountName = "api_bearer_token"
    private let emailAccountName = "user_email"

    func saveToken(_ token: String) throws {
        try save(key: tokenAccountName, data: token.data(using: .utf8)!)
    }

    func getToken() throws -> String? {
        if let data = try load(key: tokenAccountName) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    func saveEmail(_ email: String) throws {
        try save(key: emailAccountName, data: email.data(using: .utf8)!)
    }
    
    func getEmail() throws -> String? {
        if let data = try load(key: emailAccountName) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }

    func clear() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    private func save(key: String, data: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    private func load(key: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject? = nil
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            return dataTypeRef as? Data
        } else if status == errSecItemNotFound {
            return nil
        } else {
            throw KeychainError.unhandledError(status: status)
        }
    }
}
