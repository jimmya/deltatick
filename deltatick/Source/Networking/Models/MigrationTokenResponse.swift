//
//  MigrationTokenResponse.swift
//  deltatick
//
//  Created by Jimmy Arts on 22/03/2018.
//  Copyright © 2018 Jimmy. All rights reserved.
//

import Foundation

struct MigrationTokenResponse: Codable {
    
    let token: String
    let expiresAt: Date
}
