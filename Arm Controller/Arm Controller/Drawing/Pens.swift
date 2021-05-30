//
//  Pens.swift
//  Arm Controller
//
//  Created by Erik Nordlund on 5/31/2019.
//  Copyright © 2019 Erik Nordlund. All rights reserved.
//
//  Arm Controller includes the following open-source components:
//      • swiftBluetoothSerial: https://github.com/hoiberg/SwiftBluetoothSerial
//      • peertalk-simple: https://github.com/kirankunigiri/peertalk-simple

import Foundation
import UIKit


enum PenWidthUnits {
    case inches
    case millimeters
}

struct Pen {
    init(name: String, color: UIColor, dryTime: Double, widthMillimeters: Double) {
        self.name = name
        self.color = color
        self.dryTime = dryTime
        self.widthInches = widthMillimeters / 254
        self.widthMillimeters = widthMillimeters
        
        widthUnitPreference = PenWidthUnits.millimeters
    }
    init(name: String, color: UIColor, dryTime: Double, widthInches: Double) {
        self.name = name
        self.color = color
        self.dryTime = dryTime
        self.widthInches = widthInches
        self.widthMillimeters = widthInches * 254
        
        widthUnitPreference = PenWidthUnits.inches
    }
    
    static func ==(lhs: Pen, rhs: Pen) -> Bool {
        if lhs.widthInches == rhs.widthInches {
            if lhs.widthMillimeters == rhs.widthMillimeters {
                if lhs.color == rhs.color {
                    if lhs.dryTime == rhs.dryTime {
                        if lhs.name == rhs.name {
                            return true
                        }
                    }
                }
            }
        }
        return false
    }
    
    
    var widthInches: Double
    var widthMillimeters: Double
    var widthUnitPreference: PenWidthUnits
    var color: UIColor
    var dryTime: Double
    var name: String
}
