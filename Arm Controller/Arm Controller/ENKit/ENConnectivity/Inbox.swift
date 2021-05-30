//
//  Inbox.swift
//  Arm Controller
//
//  Created by Erik Nordlund on 5/31/2019.
//  Copyright © 2019 Erik Nordlund. All rights reserved.
//
//  Arm Controller includes the following open-source components:
//      • swiftBluetoothSerial: https://github.com/hoiberg/SwiftBluetoothSerial
//      • peertalk-simple: https://github.com/kirankunigiri/peertalk-simple

import Foundation

class Inbox {
	let incomingMessage = IncomingMessage()
	
	var expectedMessage: String?
	var message: String?
	
	
	func getExpectedMessage() -> String? {
		return expectedMessage
	}
	
	func getMessage() -> String? {
		return message
	}
	
	func setExpectedMessage(newExpectedMessage: String?) {
		expectedMessage = newExpectedMessage
	}
	
	func setMessage(newMessage: String) {
		message = newMessage
	}
	
	
	func messageIsExpected() -> Bool {
		if messageIsConnectionVerifier() && expectedMessageIsConnectionVerifier() {
			return true
		} else if messageIsXYCommandVerifier() && expectedMessageIsXYCommandVerifier() {
			return true
        } else if messageIsZCommandVerifier() && expectedMessageIsZCommandVerifier() {
            return true
        } else if messageIsStatusMessage() && expectedMessageIsStatusMessage() {
			// -------------------------------- This should be expanded to check correct values, and throw useful errors. This requires setting a more accurate expected status message when sending color change.
			return true
        } else if messageIsRestartVerifier() && expectedMessageIsRestartVerifier() {
            return true
        } else if messageIsConfigurationNameChangeVerifier() && expectedMessageIsConfigurationNameChangeVerifier() {
			return true
		} else {
            debugPrint("ERROR: incoming message unexpected")
			return false
		}
	}
	
	
	
	
	func messageIsConnectionVerifier() -> Bool {
		if message == incomingMessage.connectionVerifier() {
			return true
		} else {
			return false
		}
	}
	
	func messageIsXYCommandVerifier() -> Bool {
		if message == incomingMessage.xyCommandVerifier() {
			return true
		} else {
			return false
		}
	}
    
    func messageIsRestartVerifier() -> Bool {
        if message == incomingMessage.restartVerifier() {
            return true
        } else {
            return false
        }
    }
    
    func messageIsZCommandVerifier() -> Bool {
        if message == incomingMessage.zCommandVerifier() {
            return true
        } else {
            return false
        }
    }
	
	func messageIsStatusMessage() -> Bool {
		if (message?.prefix(3) == incomingMessage.statusMessage(x: 00000, y: 00000, z: 0).prefix(3)) && (message?.suffix(1) == incomingMessage.statusMessage(x: 00000, y: 00000, z: 0).suffix(1)) {
			return true
		} else {
			return false
		}
	}
	
	func messageIsConfigurationNameChangeVerifier() -> Bool {
		if message == incomingMessage.configurationNameChangeVerifier() {
			return true
		} else {
			return false
		}
	}
	
	
	func expectedMessageIsConnectionVerifier() -> Bool {
		if expectedMessage == incomingMessage.connectionVerifier() {
			return true
		} else {
			return false
		}
	}
	
	func expectedMessageIsXYCommandVerifier() -> Bool {
		if expectedMessage == incomingMessage.xyCommandVerifier() {
			return true
		} else {
			return false
		}
	}
    
    func expectedMessageIsZCommandVerifier() -> Bool {
        if expectedMessage == incomingMessage.zCommandVerifier() {
            return true
        } else {
            return false
        }
    }
    
    func expectedMessageIsRestartVerifier() -> Bool {
        if expectedMessage == incomingMessage.restartVerifier() {
            return true
        } else {
            return false
        }
    }
	
	func expectedMessageIsStatusMessage() -> Bool {
		if (expectedMessage?.prefix(3) == incomingMessage.statusMessage(x: 00000, y: 00000, z: 0).prefix(3)) && (expectedMessage?.suffix(1) == incomingMessage.statusMessage(x: 00000, y: 00000, z: 0).suffix(1)) {
			return true
		} else {
			return false
		}
	}
	
	func expectedMessageIsConfigurationNameChangeVerifier() -> Bool {
		if expectedMessage == incomingMessage.configurationNameChangeVerifier() {
			return true
		} else {
			return false
		}
	}
	
	
}
