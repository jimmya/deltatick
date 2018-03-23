//
//  RefreshInterval.swift
//  deltatick
//
//  Created by Jimmy Arts on 22/03/2018.
//  Copyright © 2018 Jimmy. All rights reserved.
//

import Foundation

enum RefreshInterval: Int {
    case tenSeconds = 0
    case thirtySeconds
    case oneMinute
    case fiveMinutes
    case tenMinutes
    case thirtyMinutes
    case oneHour
    
    static var allValues: [RefreshInterval] = [.tenSeconds, .thirtySeconds, .oneMinute, .fiveMinutes, .tenMinutes, .thirtyMinutes, .oneHour]
    
    var title: String {
        switch self {
        case .tenSeconds:
            return "10s"
        case .thirtySeconds:
            return "30s"
        case .oneMinute:
            return "1m"
        case .fiveMinutes:
            return "5m"
        case .tenMinutes:
            return "10m"
        case .thirtyMinutes:
            return "30m"
        case .oneHour:
            return "1h"
        }
    }
    
    var timeInterval: TimeInterval {
        switch self {
        case .tenSeconds:
            return 10
        case .thirtySeconds:
            return 30
        case .oneMinute:
            return 60
        case .fiveMinutes:
            return 300
        case .tenMinutes:
            return 600
        case .thirtyMinutes:
            return 1800
        case .oneHour:
            return 3600
        }
    }
}
