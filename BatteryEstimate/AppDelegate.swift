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
    var updateTimer: Timer?
    var menu: NSMenu?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        //Create menu
        menu = NSMenu()
        menu!.addItem(NSMenuItem(title: "Quit BatteryEstimate", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
        
        //Not show in Dock
        NSApp.setActivationPolicy(.accessory)
        
        //Update time remaining
        updateTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(updateEstimate), userInfo: nil, repeats: true)
        RunLoop.current.add(updateTimer!, forMode: RunLoop.Mode.common)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
    
    //Set menu bar title to current time remaining
    @objc func updateEstimate() {
        
        //⚡︎ official high voltage emoji
        //ϟ some symbol that looks like high voltage
        statusItem.button?.title = "⚡︎ " + getTimeRemaining()
    }
    
    //returns esimated battery remaining as String in format HH:MM or other status
    @objc func getTimeRemaining() -> String {
        let remainingSeconds: Double = IOPSGetTimeRemainingEstimate()
        
        if (remainingSeconds == kIOPSTimeRemainingUnknown) {
            return "Calculating"
        }
        
        //Later add feature that tells if its charging or plugged in and not charging
        if (remainingSeconds == kIOPSTimeRemainingUnlimited) {
            return "AC"
        }
        
        if (remainingSeconds > 0.0) {
            let remainingMinutes: Double = remainingSeconds / 60
            let formattedHours: Int = Int(floor(remainingMinutes / 60))
            let formattedMinutes: Int = Int(remainingMinutes) % 60
            
            if (formattedMinutes < 10) {
                return String(formattedHours) + ":" + "0" + String(formattedMinutes)
            }
            
            return String(formattedHours) + ":" + String(formattedMinutes)
        }
        
        return "Broken"
    }
}

