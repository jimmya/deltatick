//
//  Device.swift
//  deltatick
//
//  Created by Jimmy Arts on 22/03/2018.
//  Copyright © 2018 Jimmy. All rights reserved.
//

import Foundation

struct Device: Codable, Equatable {
    
    let id: Int
    let userId: Int
    let deviceId: String
    let token: String
}
