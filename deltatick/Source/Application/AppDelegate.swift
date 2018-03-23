//
//  AppDelegate.swift
//  deltatick
//
//  Created by Jimmy Arts on 21/03/2018.
//  Copyright © 2018 Jimmy. All rights reserved.
//

import Cocoa
import ServiceManagement

extension Notification.Name {
    static let killLauncher = Notification.Name("killLauncher")
}

@NSApplicationMain
final class AppDelegate: NSObject {
    
    private let statusItemController = StatusItemController()
}

extension AppDelegate: NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItemController.fetchData()
        
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = !runningApps.filter { $0.bundleIdentifier == AutoStartupHelper.launcherAppId }.isEmpty
        if isRunning {
            DistributedNotificationCenter.default().post(name: .killLauncher,
                                                         object: Bundle.main.bundleIdentifier!)
        }
    }
}
