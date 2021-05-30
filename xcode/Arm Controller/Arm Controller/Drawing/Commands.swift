//
//  Commands.swift
//  Arm Controller
//
//  Created by Erik Nordlund on 5/31/2019.
//  Copyright © 2019 Erik Nordlund. All rights reserved.
//
//  Arm Controller includes the following open-source components:
//      • swiftBluetoothSerial: https://github.com/hoiberg/SwiftBluetoothSerial
//      • peertalk-simple: https://github.com/kirankunigiri/peertalk-simple

import Foundation



protocol CoordinateCommand {
    var pauseWhenReached: Bool {get set}
}

struct XYCommand: CoordinateCommand {
    init(x: Double, y: Double, pauseWhenReached: Bool) {
        self.x = x
        self.y = y
        self.pauseWhenReached = pauseWhenReached
    }
    
    var x: Double
    var y: Double
    var pauseWhenReached: Bool
}

struct ZCommand: CoordinateCommand {
    init(z: Int, pauseWhenReached: Bool) {
        self.z = z
        self.pauseWhenReached = pauseWhenReached
    }
    
    var z: Int
    var pauseWhenReached: Bool
}
