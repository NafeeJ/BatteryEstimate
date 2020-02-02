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
    static var currentInterval = AppDelegate.updateInterval
    var menu: NSMenu?
    var windowController: MainWindowController?
    
    //Power values
    var isCharging: Bool!
    var batteryPercentage: String!
    
    //User Preferences
    static let showPercentageKey: String = "ShowPercentage"
    static var showPercentage: Bool = false
    static let updateIntervalKey: String = "UpdateIntervalKey"
    static var updateInterval: Double = 2
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        //Create menu
        menu = NSMenu()
        menu?.addItem(NSMenuItem(title: "Preferences...", action: #selector(loadPrefsWindow), keyEquivalent: "p"))
        menu?.addItem(NSMenuItem(title: "Quit BatteryEstimate", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
        
        //load user preferences
        loadPreferences()
        
        //Update time remaining
        updateAll()
        
        //initialize window
        windowController = (NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "mainWindow") as! MainWindowController)
        
        updateTimer = Timer.scheduledTimer(timeInterval: AppDelegate.updateInterval, target: self, selector: #selector(updateAll), userInfo: nil, repeats: true)
        RunLoop.current.add(updateTimer!, forMode: RunLoop.Mode.common)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
    
    //Set menu bar title to current time remaining
    @objc func updateAll() {
        if AppDelegate.changeInterval() {
            updateTimer?.invalidate()
            updateTimer = Timer.scheduledTimer(timeInterval: AppDelegate.updateInterval, target: self, selector: #selector(updateAll), userInfo: nil, repeats: true)
            RunLoop.current.add(updateTimer!, forMode: RunLoop.Mode.common)
            AppDelegate.currentInterval = AppDelegate.updateInterval
        }
        
        updatePowerValues()
        if (!AppDelegate.showPercentage) { statusItem.button?.title = getTimeRemaining() }
        else { statusItem.button?.title = getTimeRemaining() + " | " + batteryPercentage}
    }
    
    static func changeInterval() -> Bool {
        return AppDelegate.currentInterval != AppDelegate.updateInterval
    }
    
    func loadPreferences() {
        if (UserDefaults.standard.value(forKey: AppDelegate.showPercentageKey) != nil) {
            AppDelegate.showPercentage = UserDefaults.standard.value(forKey: AppDelegate.showPercentageKey) as! Bool
        }
        if (UserDefaults.standard.value(forKey: AppDelegate.updateIntervalKey) != nil) {
            AppDelegate.updateInterval = UserDefaults.standard.value(forKey: AppDelegate.updateIntervalKey) as! Double
        }
    }
    
    //returns esimated battery remaining as String in format HH:MM or other status
    func getTimeRemaining() -> String {
        let remainingSeconds: Double = IOPSGetTimeRemainingEstimate()
        
        //most likely condition so test first for optimization
        if (remainingSeconds > 0.0) {
            let formattedHours: Int = Int(floor(remainingSeconds / 3600))
            let formattedMinutes: Int = Int(remainingSeconds / 60) % 60
            
            if (formattedMinutes < 10) { return "↓ " + String(formattedHours) + ":" + "0" + String(formattedMinutes) }
            
            return "↓ " + String(formattedHours) + ":" + String(formattedMinutes)
        }
        
        //if its not greater than 0 then check if its unknown, if so just say that its being calculated
        else if (remainingSeconds == kIOPSTimeRemainingUnknown) { return "Calculating" }
            
        //remainingSeconds fell through its checks so device must be plugged in, check if its charging and return so
        else if (isCharging) { return "⚡︎ Charging" } //ϟ
        
        //fell through charging check, must not be charging
        return "✗ Not Charging"
    }
    
    //updates power values
    func updatePowerValues() {
        let info = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let list = IOPSCopyPowerSourcesList(info).takeRetainedValue() as Array
        
        for ps in list {
            if let desc = IOPSGetPowerSourceDescription(info, ps).takeUnretainedValue() as? [String: Any] {
                //if the powersource is the battery, return if it is charging or not
                let psName = desc[kIOPSNameKey] as? String
                
                //if the power source is nil or isn't the internal battery then set error values for power values
                if (psName != nil && psName == "InternalBattery-0") {
                    
                    //update isCharging
                    let isCharging = desc[kIOPSIsChargingKey] as? Bool
                    if (isCharging != nil) { self.isCharging = isCharging! }
                    else { self.isCharging = false }
                    
                    //only update batteryPercentage if the user wants the percentage
                    if (AppDelegate.showPercentage) {
                        let currentCapacity = desc[kIOPSCurrentCapacityKey] as! Double
                        let maxCapacity = desc[kIOPSMaxCapacityKey] as! Double
                        self.batteryPercentage = String(format: "%.0f", (currentCapacity / maxCapacity) * 100) + "%"
                    }
                }
                else {
                    self.isCharging = false
                    batteryPercentage = "Error"
                }
            }
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
