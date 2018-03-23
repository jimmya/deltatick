import Foundation
import KeychainSwift

extension KeychainSwift {
    
    private static let authTokenKey = "authToken"
    
    var authToken: String? {
        set {
            if let newValue = newValue {
                set(newValue, forKey: KeychainSwift.authTokenKey)
            } else {
                delete(KeychainSwift.authTokenKey)
            }
        }
        get {
            return get(KeychainSwift.authTokenKey)
        }
    }
}
