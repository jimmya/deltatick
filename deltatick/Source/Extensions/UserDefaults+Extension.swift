import Foundation

extension UserDefaults {
    
    private static let hasSyncedKey = "hasSynced"
    private static let refreshIntervalKey = "refreshInterval"
    private static let displayMetricTypeKey = "displayMetricType"
    
    var hasSynced: Bool {
        set {
            set(newValue, forKey: UserDefaults.hasSyncedKey)
        }
        get {
            return bool(forKey: UserDefaults.hasSyncedKey)
        }
    }

    var refreshInterval: RefreshInterval? {
        set {
            if let newValue = newValue {
                set(newValue.rawValue, forKey: UserDefaults.refreshIntervalKey)
            } else {
                set(RefreshInterval.oneMinute.rawValue, forKey: UserDefaults.refreshIntervalKey)
            }
        }
        get {
            return RefreshInterval(rawValue: integer(forKey: UserDefaults.refreshIntervalKey))
        }
    }
    
    var displayMetricType: MetricType? {
        set {
            if let newValue = newValue {
                set(newValue.rawValue, forKey: UserDefaults.displayMetricTypeKey)
            } else {
                set(MetricType.worth.rawValue, forKey: UserDefaults.displayMetricTypeKey)
            }
        }
        get {
            return MetricType(rawValue: integer(forKey: UserDefaults.displayMetricTypeKey))
        }
    }
}
