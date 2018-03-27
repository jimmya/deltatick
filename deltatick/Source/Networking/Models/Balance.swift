//
//  Balance.swift
//  deltatick
//
//  Created by Jimmy Arts on 23/03/2018.
//  Copyright © 2018 Jimmy. All rights reserved.
//

import Foundation

struct Balance: Codable, Equatable {
    
    let worth: Double
    let worth24h: Double
    let cost: Double
    let deltaTotal: Double
    let delta24h: Double
    let percentageTotal: Double
    let percentage24h: Double
    let worthInBtc: Double
    let worth24hInBtc: Double
    let costInBtc: Double
    let deltaTotalInBtc: Double
    let delta24hInBtc: Double
    let percentageTotalInBtc: Double
    let percentage24hInBtc: Double
    
    func valueForMetricType(_ metricType: MetricType) -> Double {
        switch metricType {
        case .worth:
            return worth
        case .worthBTC:
            return worthInBtc
        case .delta:
            return deltaTotal
        case .delta24h:
            return delta24h
        case .deltaBTC:
            return deltaTotalInBtc
        case .deltaBTC24h:
            return delta24hInBtc
        case .percentage:
            return percentageTotal
        case .percentage24h:
            return percentage24h
        }
    }
}
