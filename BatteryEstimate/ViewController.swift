//
//  ViewController.swift
//  BatteryEstimate
//
//  Created by Nafee Jan on 11/14/19.
//  Copyright © 2019 Nafee Workshop. All rights reserved.
//

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
    }
    
    @IBOutlet var showPercentage: NSButton! {
        didSet {
            showPercentage.state = AppDelegate.showPercentage ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }
    
    @IBAction func showPercentageClicked(_ checkbox: NSButton) {
        AppDelegate.showPercentage = checkbox.state == NSButton.StateValue.on
        UserDefaults.standard.set(checkbox.state == NSButton.StateValue.on, forKey: AppDelegate.showPercentageKey)
    }
    
    @IBOutlet var updateInterval: NSPopUpButton! {
        didSet {
            updateInterval.selectItem(at: Int(AppDelegate.updateInterval - 1))
        }
    }
    
    @IBAction func updateIntervalClicked(_ menuItem: NSPopUpButton) {
        AppDelegate.updateInterval = Double(menuItem.indexOfSelectedItem + 1)
        UserDefaults.standard.set(AppDelegate.updateInterval, forKey: AppDelegate.updateIntervalKey)
    }
}

