//
//  MetricType.swift
//  deltatick
//
//  Created by Jimmy Arts on 23/03/2018.
//  Copyright © 2018 Jimmy. All rights reserved.
//

import Foundation

enum MetricType: Int {
    
    case worth
    case worthBTC
    case delta
    case deltaBTC
    case delta24h
    case deltaBTC24h
    case percentage
    case percentage24h
    
    var title: String {
        switch self {
        case .worth:
            return "display_value_worth".ls
        case .worthBTC:
            return "display_value_worthBTC".ls
        case .delta:
            return "display_value_delta".ls
        case .deltaBTC:
            return "display_value_deltaBTC".ls
        case .delta24h:
            return "display_value_delta24h".ls
        case .deltaBTC24h:
            return "display_value_deltaBTC24h".ls
        case .percentage:
            return "display_value_percentage".ls
        case .percentage24h:
            return "display_value_percentage24h".ls
        }
    }
    
    var isBTCValue: Bool {
        return self == .worthBTC || self == .deltaBTC || self == .deltaBTC24h
    }
    
    var isPercentage: Bool {
        return self == .percentage || self == .percentage24h
    }
    
    static var allValues: [MetricType] {
        return [.worth, .worthBTC, .delta, .deltaBTC, .delta24h, .deltaBTC24h, .percentage, .percentage24h]
    }
}
