import Foundation

enum StatusItem {
    
    // MARK: Use cases
    
    enum Fetch {
        struct Request: Equatable { }
        struct Response: Equatable {
            let portfolio: Portfolio
            let displayMetricType: MetricType
        }
        struct ViewModel: Equatable {
            let buttonTitle: String
        }
    }
    
    enum Sync {
        struct Request { }
        struct Response: Equatable { }
        struct ViewModel: Equatable { }
    }
    
    enum Reset {
        struct Request { }
    }
    
    enum Error {
        struct Response {
            let error: Swift.Error
        }
        struct ViewModel { }
    }
    
    enum UpdateRefreshInterval {
        struct Request {
            let interval: RefreshInterval
        }
    }
    
    enum UpdateDisplayMetricType {
        struct Request {
            let displayMetricType: MetricType
        }
    }
    
    enum UpdateAutoStartup {
        struct Request {
            let autoStartup: Bool
        }
    }
}
