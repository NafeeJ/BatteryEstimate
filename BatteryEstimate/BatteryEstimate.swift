//
//  BatteryEstimate.swift
//  BatteryEstimate
//
//  Created by Nafee Jan on 11/14/19.
//  Copyright © 2019 Nafee Workshop. All rights reserved.
//

import Cocoa
import IOKit.ps

class BatteryEstimate {
    
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
