//
//  ViewController.swift
//  BatteryEstimate
//
//  Created by Nafee Jan on 11/14/19.
//  Copyright © 2019 Nafee Workshop. All rights reserved.
//

import Cocoa
import ServiceManagement
import LaunchAtLogin

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBOutlet var launchOnLogin: NSButton! {
        didSet {
            launchOnLogin.state = LaunchAtLogin.isEnabled ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }
    
    @IBAction func launchOnLoginClicked(_ checkbox: NSButton) {
        LaunchAtLogin.isEnabled = (checkbox.state == NSButton.StateValue.on)

//        AppDelegate.Preferences.autoLaunch = (checkbox.state == NSButton.StateValue.on)
//
//        if checkbox.state == NSButton.StateValue.on {
//            if SMLoginItemSetEnabled(AppDelegate.helperIdentifier as CFString, true) {
//                UserDefaults.standard.set(true, forKey: AppDelegate.Preferences.autoLaunchKey)
//            }
//            else {
//                checkbox.state = NSButton.StateValue.off
//            }
//        }
//        else {
//            if SMLoginItemSetEnabled(AppDelegate.helperIdentifier as CFString, false) {
//                UserDefaults.standard.set(false, forKey: AppDelegate.Preferences.autoLaunchKey)
//            }
//        }
    }
}

