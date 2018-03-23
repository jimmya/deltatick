//
//  RegisterRequest.swift
//  deltatick
//
//  Created by Jimmy Arts on 21/03/2018.
//  Copyright © 2018 Jimmy. All rights reserved.
//

import Foundation

struct RegisterRequest: Codable {
    
    let deviceId: String
    let name: String
    let systemName: String
    let appVersion: String
    let currency: String
    let timezone: String
}
