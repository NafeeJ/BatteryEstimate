//
//  AppDelegate.swift
//  BatteryEstimate
//
//  Created by Nafee Jan on 11/14/19.
//  Copyright © 2019 Nafee Workshop. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var batteryEstimate = BatteryEstimate()
    var updateTimer: Timer?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        updateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateEstimate), userInfo: nil, repeats: true)
        
        RunLoop.current.add(updateTimer!, forMode: RunLoop.Mode.common)
        
        //⚡︎ official high voltage emoji
        //ϟ some symbol that looks like high voltage
        statusItem.button?.title = "⚡︎ " + batteryEstimate.getTimeRemaining()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
    
    @objc func updateEstimate() {
        statusItem.button?.title = "⚡︎ " + batteryEstimate.getTimeRemaining()
    }
}

