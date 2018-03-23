//
//  AutoStartupHelper.swift
//  deltatick
//
//  Created by Jimmy Arts on 23/03/2018.
//  Copyright © 2018 Jimmy. All rights reserved.
//

import Foundation
import ServiceManagement

protocol AutoStartupHelperLogic {
    
    var autoStartupEnabled: Bool { get }
    
    func setAutoStartupEnabled(_ enabled: Bool)
}

final class AutoStartupHelper: AutoStartupHelperLogic {
    
    static let launcherAppId = "com.jimmy.deltatickLauncher"
    
    var autoStartupEnabled: Bool {
        guard let jobDicts = SMCopyAllJobDictionaries( kSMDomainUserLaunchd ).takeRetainedValue() as NSArray as? [[String: AnyObject]] else {
            return false
        }
        let label = AutoStartupHelper.launcherAppId
        return jobDicts.filter { $0["Label"] as? String == label }.isEmpty == false
    }
    
    func setAutoStartupEnabled(_ enabled: Bool) {
        SMLoginItemSetEnabled(AutoStartupHelper.launcherAppId as CFString, enabled)
    }
}
