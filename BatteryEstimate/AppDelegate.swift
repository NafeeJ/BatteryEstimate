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
        
        //most likely condition so test first for optimization
        if (remainingSeconds > 0.0) {
            let formattedHours: Int = Int(floor(remainingSeconds / 3600))
            let formattedMinutes: Int = Int(remainingSeconds / 60) % 60
            
            if (formattedMinutes < 10) { return String(formattedHours) + ":" + "0" + String(formattedMinutes) }
            
            return String(formattedHours) + ":" + String(formattedMinutes)
        }
        
        //if its not greater than 0 then check if its unknown, if so just say that its being calculated
        else if (remainingSeconds == kIOPSTimeRemainingUnknown) { return "Calculating" }
            
        //remainingSeconds fell through its checks so device must be plugged in, check if its charging and return so
        else if (isCharging()) { return "Charging" }
        
        //fell through charging check, must not be charging
        return "Not Charging"
    }
    
    //checks if the battery is charging
    func isCharging() -> Bool {
        let info = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let list = IOPSCopyPowerSourcesList(info).takeRetainedValue() as Array
        
        for ps in list {
            if let desc = IOPSGetPowerSourceDescription(info, ps).takeUnretainedValue() as? [String: Any] {
                //if the powersource is the battery, return if it is charging or not
                if (desc[kIOPSNameKey] as? String == "InternalBattery-0") { return desc[kIOPSIsChargingKey] as! Bool }
            }
        }
        
        return false;
    }
}

