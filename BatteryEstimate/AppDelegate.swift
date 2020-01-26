//
//  AppDelegate.swift
//  BatteryEstimate
//
//  Created by Nafee Jan on 11/14/19.
//  Copyright © 2019 Nafee Workshop. All rights reserved.
//

import Cocoa
import IOKit.ps

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var updateTimer: Timer?
    var menu: NSMenu?
    var windowController: MainWindowController?
    
    static let mainIdentifier = "com.nafeeworkshop.BatteryEstimate"
    static let helperIdentifier = "com.nafeeworkshop.BatteryEstimate-Helper"
    
    //Prefereces and their respective keys
    struct Preferences {
        static var autoLaunch = false
        static let autoLaunchKey: String = "LaunchOnStartup"
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        //Create menu
        menu = NSMenu()
        menu?.addItem(NSMenuItem(title: "Preferences...", action: #selector(loadPrefsWindow), keyEquivalent: "p"))
        menu?.addItem(NSMenuItem(title: "Quit BatteryEstimate", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
        
        //Not show in Dock
        NSApp.setActivationPolicy(.accessory)
        
        //Update time remaining
        updateTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(updateEstimate), userInfo: nil, repeats: true)
        RunLoop.current.add(updateTimer!, forMode: RunLoop.Mode.common)
        
        loadPreferences()
        
        //initialize window
        windowController = (NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "mainWindow") as! MainWindowController)
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
                let psName = desc[kIOPSNameKey] as? String
                let isCharging = desc[kIOPSIsChargingKey] as? Bool
                if (psName != nil && psName == "InternalBattery-0" && isCharging != nil) { return isCharging! }
            }
        }
        
        return false;
    }
    
    func loadPreferences() {
        //Launch on startup
        if (UserDefaults.standard.value(forKey: Preferences.autoLaunchKey) != nil) {
            Preferences.autoLaunch = UserDefaults.standard.value(forKey: Preferences.autoLaunchKey) as! Bool
        }
    }
    
    @objc func loadPrefsWindow() {
        windowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

//Sets up the main window which will be for preferences
class MainWindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
    }
}
