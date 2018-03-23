//
//  DelayHelper.swift
//  deltatick
//
//  Created by Jimmy Arts on 23/03/2018.
//  Copyright © 2018 Jimmy. All rights reserved.
//

import Foundation

protocol DelayHelperLogic {
    
    func delay(_ delay: Double, closure: @escaping () -> ())
}

final class DelayHelper: DelayHelperLogic {
    
    func delay(_ delay: Double, closure: @escaping () -> ()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
}
