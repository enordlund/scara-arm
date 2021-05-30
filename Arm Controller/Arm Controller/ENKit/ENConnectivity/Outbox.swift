//
//  Outbox.swift
//  Arm Controller
//
//  Created by Erik Nordlund on 5/31/2019.
//  Copyright © 2019 Erik Nordlund. All rights reserved.
//
//  Arm Controller includes the following open-source components:
//      • swiftBluetoothSerial: https://github.com/hoiberg/SwiftBluetoothSerial
//      • peertalk-simple: https://github.com/kirankunigiri/peertalk-simple

import Foundation


class Outbox {
	let outgoingMessage = OutgoingMessage()
	
	
	var message: String?
	
	func getMessage() -> String? {
		return message
	}
	
	func setMessage(newMessage: String) {
		message = newMessage
	}
	
	func clearMessage() {
		message = nil
	}
	
	
	
	func isConnectionRequest() -> Bool {
		if message == outgoingMessage.connectionRequest() {
			return true
		} else {
			return false
		}
	}
	
	func isStatusRequest() -> Bool {
		if message == outgoingMessage.statusRequest() {
			return true
		} else {
			return false
		}
	}
    
    func isUSBDisconnectionCommand() -> Bool {
        if message == outgoingMessage.usbDisconnectionCommand() {
            return true
        } else {
            return false
        }
    }
	
	func isXYCommand() -> Bool {
		let beginning = "xy:x"
		let end = "!"
		
		if (message!.prefix(4) == beginning) && (message!.suffix(1) == end) && (message!.count == 16) {
			return true
		} else {
			return false
		}
	}
    
    func isZCommand() -> Bool {
        let beginning = "z:z"
        let end = "!"
        
        if (message!.prefix(3) == beginning) && (message!.suffix(1) == end) && (message!.count == 5) {
            return true
        } else {
            return false
        }
    }
    
    func isRestartCommand() -> Bool {
        if message == outgoingMessage.restartCommand() {
            return true
        } else {
            return false
        }
    }
	
	// configuration commands
	func isConfigurationCommand() -> Bool {
		let end: Character = "!"
		
		if (message!.prefix(7) == "config:") && (message![message!.endIndex] == end) {
			return true
		} else {
			return false
		}
	}
	
	func isConfigurationNameCommand() -> Bool {
		let end: Character = "!"
		
		if (message!.prefix(12) == "config:name:") && (message![message!.endIndex] == end) {
			return true
		} else {
			return false
		}
	}
}
