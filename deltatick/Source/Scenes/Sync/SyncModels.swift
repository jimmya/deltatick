import Foundation

enum Sync {
    
    // MARK: Use cases
    
    enum MigrationToken {
        struct Request { }
        struct Response {
            let migrationToken: MigrationTokenResponse
        }
        struct ViewModel {
            let code: String
        }
    }
    
    enum Loading {
        struct Response {
            enum LoadingType {
                case token
                case status
            }
            let type: LoadingType
        }
        struct ViewModel {
            let message: String
        }
    }
    
    enum Error {
        struct Response {
            let error: Swift.Error
        }
        struct ViewModel { }
    }
    
    enum Migration {
        struct Response {
            let status: MigrationStatusResponse.Status
        }
        struct ViewModel {
            let shouldClose: Bool
            let message: String?
        }
    }
}
