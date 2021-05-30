//
//  UserDefaultsManagement.swift
//  Arm Controller
//
//  Created by Erik Nordlund on 5/31/2019.
//  Copyright © 2019 Erik Nordlund. All rights reserved.
//
//  Arm Controller includes the following open-source components:
//      • swiftBluetoothSerial: https://github.com/hoiberg/SwiftBluetoothSerial
//      • peertalk-simple: https://github.com/kirankunigiri/peertalk-simple

import Foundation

func setDefaultUserDefaults() {
	let appDefaults = [kSavedENAppearanceDefaultsKey : "lightAppearance"]
	
	let now = Date()
	
	UserDefaults.standard.set(now, forKey: kSavedLastUpdatedDefaultsKey)
	
	UserDefaults.standard.register(defaults: appDefaults)
	
}
