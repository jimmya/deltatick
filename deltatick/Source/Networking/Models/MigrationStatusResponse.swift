//
//  MigrationStatusResponse.swift
//  deltatick
//
//  Created by Jimmy Arts on 22/03/2018.
//  Copyright © 2018 Jimmy. All rights reserved.
//

import Foundation

struct MigrationStatusResponse: Codable {
    
    enum Status: String, Codable {
        case started = "STARTED"
        case failed = "FAILED"
        case ended = "ENDED"
    }
    
    let status: Status
}
