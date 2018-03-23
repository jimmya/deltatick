//
//  MigrationTokenRequest.swift
//  deltatick
//
//  Created by Jimmy Arts on 22/03/2018.
//  Copyright © 2018 Jimmy. All rights reserved.
//

import Foundation

struct MigrationTokenRequest: Codable {
    
    enum MigrationTokenRequestType: String, Codable {
        case sync = "SYNC"
    }
    
    let type: MigrationTokenRequestType
}
