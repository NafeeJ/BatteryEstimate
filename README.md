# BatteryEstimate
Brings back the estimated battery time remaining to the menu bar for MacOS / OS X

### Draining
<img src="Images/BE_Draining_NoPercent.png" width=500>

<img src="Images/BE_Draining_Percent.png" width=500>

### Charging
<img src="Images/BE_Charging_NoPercent.png" width=500>

<img src="Images/BE_Charging_Percent.png" width=500>

### Features
* Shows battery time remaining when unplugged
* Shows time until fully charged when plugged in
* Can toggle displaying battery percent
* Symbols to represent power state

### Download
Download latest version from [here](https://github.com/NafeeJ/BatteryEstimate/releases)

### Points of Notice
* Drain estimate is derived directly from the MacOS API which I guess is calculated based off of the rate at which the computer is currently draining battery and is subject to fluctuation based on its workload, so take the estimate with a grain of salt and consider the work that your computer is doing and if it is accurate or not to your average workload.
* Charge estimate is also derived directly from the MacOS API which I guess is calculated based off of the rate of charge coming into the battery.

### Thanks
https://github.com/iglance/iGlance for development reference
https://github.com/sindresorhus/LaunchAtLogin for launch at login functionality
https://github.com/LinusU/node-appdmg for making the dmg
