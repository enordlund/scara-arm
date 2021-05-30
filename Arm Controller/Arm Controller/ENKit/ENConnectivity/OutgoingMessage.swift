//
//  OutgoingMessage.swift
//  Arm Controller
//
//  Created by Erik Nordlund on 5/31/2019.
//  Copyright © 2019 Erik Nordlund. All rights reserved.
//
//  Arm Controller includes the following open-source components:
//      • swiftBluetoothSerial: https://github.com/hoiberg/SwiftBluetoothSerial
//      • peertalk-simple: https://github.com/kirankunigiri/peertalk-simple

import Foundation

class OutgoingMessage {
	
	func connectionRequest() -> String {
		return "c?"
	}
	
	func repeatRequest() -> String {
		return "?"
	}
	
	func statusRequest() -> String {
		return "s?"
	}
    
    func zStatusRequest() -> String {
        return "z?"
    }
	
    func usbDisconnectionCommand() -> String {
        return "d!"
    }
    
    func restartCommand() -> String {
        return "r!"
    }
    
    func xyCommand(x: Double, y: Double) -> String {
        let roundedX = Int(round(x*1000))
        let roundedY = Int(round(y*1000))
        
        
        var xString: String
        var yString: String
        
        if (roundedX < 10) {
            xString = "0000\(roundedX)"
        } else if (roundedX < 100) {
            xString = "000\(roundedX)"
        } else if (roundedX < 1000) {
            debugPrint("roundedX < 1000: ", roundedX)
            xString = "00\(roundedX)"
        } else if (roundedX < 10000) {
            debugPrint("roundedX < 10000: ", roundedX)
            xString = "0\(roundedX)"
        } else {
            xString = String(roundedX)
        }
        
        if (roundedY < 10) {
            yString = "0000\(roundedY)"
        } else if (roundedY < 100) {
            yString = "000\(roundedY)"
        } else if (roundedY < 1000) {
            debugPrint("roundedY < 1000: ", roundedY)
            yString = "00\(roundedY)"
        } else if (roundedY < 10000) {
            debugPrint("roundedY < 10000: ", roundedY)
            yString = "0\(roundedY)"
        } else {
            yString = String(roundedY)
        }
        
        let command = "xy:x\(xString)y\(yString)!"
        return command
    }
    
    func zCommand(z: Int) -> String {
        let command = "z:z\(z)!"
        return command
    }
    
    
	
	func colorCommand(red: Int, green: Int, blue: Int) -> String {
		let redString: String
		let greenString: String
		let blueString: String
		
		if (red < 10) {
			redString = "00\(red)"
		} else if (red < 100) {
			redString = "0\(red)"
		} else {
			redString = String(red)
		}
		
		if (green < 10) {
			greenString = "00\(green)"
		} else if (green < 100) {
			greenString = "0\(green)"
		} else {
			greenString = String(green)
		}
		
		if (blue < 10) {
			blueString = "00\(blue)"
		} else if (blue < 100) {
			blueString = "0\(blue)"
		} else {
			blueString = String(blue)
		}
		
		let command = "rgb:r\(redString)g\(greenString)b\(blueString)!"
		return command
	}
	
	func changeDeviceNameCommand(newName: String) -> String {
		return "config:name:\(newName)!"
	}
}
