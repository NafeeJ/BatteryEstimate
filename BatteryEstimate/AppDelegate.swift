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
    
    //power values
    var remainingSeconds: Double = -1
    var isCharged: Bool = false
    var timeToFullCharge: Double = -1
    var batteryPercentage: String = "Error"
    
    //user Preferences
    static let showPercentageKey: String = "ShowPercentageKey"
    static var showPercentage: Bool = false
    static let updateIntervalKey: String = "UpdateIntervalKey"
    static var updateInterval: Double = 2
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        //create menu
        menu = NSMenu()
        menu?.addItem(NSMenuItem(title: "Preferences...", action: #selector(loadPrefsWindow), keyEquivalent: "p"))
        menu?.addItem(NSMenuItem(title: "Quit BatteryEstimate", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
        
        loadPreferences()
        updateAll()
        
        //initialize window
        windowController = (NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "mainWindow") as! MainWindowController)
        
        updateTimer = Timer.scheduledTimer(timeInterval: AppDelegate.updateInterval, target: self, selector: #selector(updateAll), userInfo: nil, repeats: true)
        RunLoop.current.add(updateTimer!, forMode: RunLoop.Mode.common)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
    
    //update power values then status
    @objc func updateAll() {
        //if user changed interval preference then stop timer and make new one
        if AppDelegate.changeInterval() {
            updateTimer?.invalidate()
            updateTimer = Timer.scheduledTimer(timeInterval: AppDelegate.updateInterval, target: self, selector: #selector(updateAll), userInfo: nil, repeats: true)
            RunLoop.current.add(updateTimer!, forMode: RunLoop.Mode.common)
            AppDelegate.currentInterval = AppDelegate.updateInterval
        }
        
        updatePowerValues()
        if (AppDelegate.showPercentage) { statusItem.button?.title = getTimeRemaining() + " | " + batteryPercentage}
        else { statusItem.button?.title = getTimeRemaining() }
    }
    
    //checks if user changed update interval preference
    static func changeInterval() -> Bool {
        return AppDelegate.currentInterval != AppDelegate.updateInterval
    }
    
    //loads user preferences from UserDefaults into AppDelegate values
    func loadPreferences() {
        if (UserDefaults.standard.value(forKey: AppDelegate.showPercentageKey) != nil) {
            AppDelegate.showPercentage = UserDefaults.standard.value(forKey: AppDelegate.showPercentageKey) as! Bool
        }
        if (UserDefaults.standard.value(forKey: AppDelegate.updateIntervalKey) != nil) {
            AppDelegate.updateInterval = UserDefaults.standard.value(forKey: AppDelegate.updateIntervalKey) as! Double
        }
    }
    
    //returns estimated battery remaining, calculating, time until charged, charged, or not charging
    func getTimeRemaining() -> String {
        //if macOS returns a positive battery estimate then return it
        if (remainingSeconds > 0.0) { return "↓ " + secondsFormatter(seconds: remainingSeconds) }
        //if the estimate is unknown or if device is plugged in and time until charged is unknown then return calculating
        else if (remainingSeconds == kIOPSTimeRemainingUnknown || timeToFullCharge == -1) { return "Calculating" }
        //if macOS returns positive charge estimate then return it
        else if (timeToFullCharge > 0.0) { return "⚡︎ " + secondsFormatter(seconds: timeToFullCharge * 60) } //ϟ
        //check if the battery is charged
        else if (isCharged) { return "⚡︎ Charged" }
        //fell through estimate and charging checks, must not be charging
        return "✗ Not Charging"
    }
    
    //updates power values
    func updatePowerValues() {
        //update remaining seconds of battery life as defined by macOS function
        remainingSeconds = IOPSGetTimeRemainingEstimate()
        
        let psInfo = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let psList = IOPSCopyPowerSourcesList(psInfo).takeRetainedValue() as Array
        
        for ps in psList {
            if let psDesc = IOPSGetPowerSourceDescription(psInfo, ps).takeUnretainedValue() as? [String: Any] {
                if (psDesc[kIOPSNameKey] != nil && psDesc[kIOPSNameKey] as? String == "InternalBattery-0") {
                    
                    //update timeToFullCharge with -1 as default value in case nil is returned
                    timeToFullCharge = psDesc[kIOPSTimeToFullChargeKey] as? Double ?? -1
                    
                    //update isCharged with false as default value in case nil is returned
                    isCharged = psDesc[kIOPSIsChargedKey] as? Bool ?? false
                    
                    //only update batteryPercentage if the user wants the percentage
                    if (AppDelegate.showPercentage) {
                        //divide current capacity by max capacity (must do this since different power sources have differently defined values)
                        let currentCapacity = psDesc[kIOPSCurrentCapacityKey] as? Double ?? -1
                        let maxCapacity = psDesc[kIOPSMaxCapacityKey] as? Double ?? 1
                        batteryPercentage = String(format: "%.0f", (currentCapacity / maxCapacity) * 100) + "%"
                        //Int((currentCapacity / maxCapacity) * 100)
                    }
                    return
                }
            }
        }
        //default power values
        remainingSeconds = -1
        isCharged = false
        timeToFullCharge = -1
        batteryPercentage = "Error"
    }
    
    //formats seconds into HH:MM
    func secondsFormatter(seconds: Double) -> String {
        let formattedHours: Int = Int(floor(seconds / 3600))
        let formattedMinutes: Int = Int(seconds / 60) % 60
        
        if (formattedMinutes < 10) { return String(formattedHours) + ":" + "0" + String(formattedMinutes) }
        
        return String(formattedHours) + ":" + String(formattedMinutes)
    }
    
    @objc func loadPrefsWindow() {
        windowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

//sets up the main window which will be for preferences
class MainWindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
    }
}
