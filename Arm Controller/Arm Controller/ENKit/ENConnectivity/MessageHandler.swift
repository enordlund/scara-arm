//
//  MessageManager.swift
//  Arm Controller
//
//  Created by Erik Nordlund on 5/31/2019.
//  Copyright © 2019 Erik Nordlund. All rights reserved.
//
//  Arm Controller includes the following open-source components:
//      • swiftBluetoothSerial: https://github.com/hoiberg/SwiftBluetoothSerial
//      • peertalk-simple: https://github.com/kirankunigiri/peertalk-simple

import Foundation
import CoreBluetooth

/// Global handler variable, initialize with .init(delegate: ). delegate should be self in view controller.
var messageHandler: MessageHandler!

protocol MessageHandlerDelegate {
	func statusDidRefresh()
	func deviceNameDidChange(_ name: String)
	func messageWasReceived(_ message: String)
	func messageWasSent(_ message: String)
	
	func peripheralDidDisconnect()
	func connectionDidChangeState(_ poweredOn: Bool)
	func peripheralDiscovered(_ isDuplicate: Bool,_ peripherals: [(peripheral: CBPeripheral, RSSI: Float)])
	func peripheralConnectionSuccessful()
	func peripheralConnectionFailed()
	func peripheralConnectionReady(_ peripheral: CBPeripheral)
    
    func usbDidConnect()
    func usbDidDisconnect()
}

struct Status {
	var x: Double?
	var y: Double?
	var z: Int?
}

class MessageHandler {
	var delegate: MessageHandlerDelegate!
	
	init(delegate: MessageHandlerDelegate) {
		//super.init()
		self.delegate = delegate
		
		
		// Initialize serial
		btSerial = BluetoothSerial(delegate: self)
        
		
		// start scanning and schedule the time out
		btSerial.startScan()
		Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: {_ in
			self.scanTimeOut()
		})
        
        // Setup the PTManager
        ptManager.delegate = self
        ptManager.connect(portNumber: PORT_NUMBER)
	}
    
    let ptManager = PTManager.instance
	
    var bluetoothIsConnected: Bool {
        get {
            if btSerial.connectedPeripheral != nil {
                return true
            } else {
                return false
            }
        }
    }
	
	
	
	private let outbox = Outbox()
	
	private let inbox = Inbox()
	
	var status = Status()
    
	var usbMode = false
	
	private func setOutboxMessage(_ message: String?) {
		outbox.message = message
		
	}
	
	private func setExpectedInboxMessage(message: String) {
		inbox.setExpectedMessage(newExpectedMessage: message)
	}
	
	
	private func getOutboxMessage() -> String? {
		return outbox.message
	}
	
	private func getExpectedInboxMessage() -> String? {
		return inbox.getExpectedMessage()
	}
	
	private func setInboxMessage(_ message: String) {
		inbox.setMessage(newMessage: message)
	}
	
	private func sendOutgoingMessage(message: String?) {
		setOutboxMessage(message)
		
		updateExpectedInboxMessage()
		
		if outbox.message != nil {
            if usbMode == true {
                // send via peertalk
                debugPrint("sending via peertalk: ", message as Any)
                ptManager.sendObject(object: message as Any, type: PTType.string.rawValue)
                delegate.messageWasSent(message!)
            } else if bluetoothIsConnected {
                btSerial.sendMessageToDevice(message!)
                delegate.messageWasSent(message!)
            } else {
                debugPrint("ERROR: no devices connected.")
            }
			
		} else {
			print("ERROR: Outbox empty. Send failed.")
		}
	}
	
	
	private func updateExpectedInboxMessage() {
		if outbox.isConnectionRequest() {
			inbox.setExpectedMessage(newExpectedMessage: inbox.incomingMessage.connectionVerifier())
		} else if outbox.isStatusRequest() {
			//---------------------------------- This is where an accurate expectedMessage will be constructed
			inbox.setExpectedMessage(newExpectedMessage: inbox.incomingMessage.statusMessage(x: 00000, y: 00000, z: 0))
		} else if outbox.isXYCommand() {
			//inbox.setExpectedMessage(newExpectedMessage: inbox.incomingMessage.xyCommandVerifier())
            inbox.setExpectedMessage(newExpectedMessage: inbox.incomingMessage.statusMessage(x: 00000, y: 00000, z: 0))
        } else if outbox.isZCommand() {
            //inbox.setExpectedMessage(newExpectedMessage: inbox.incomingMessage.zCommandVerifier())
            inbox.setExpectedMessage(newExpectedMessage: inbox.incomingMessage.statusMessage(x: 00000, y: 00000, z: 0))
        } else if outbox.isRestartCommand() {
            inbox.setExpectedMessage(newExpectedMessage: inbox.incomingMessage.restartVerifier())
        } else if outbox.isConfigurationNameCommand() {
			inbox.setExpectedMessage(newExpectedMessage: inbox.incomingMessage.configurationNameChangeVerifier())
		} else {
			inbox.setExpectedMessage(newExpectedMessage: nil)
		}
		// ------------------------------------------------------ should also handle case of repeat request
	}
	
	private func handleIncomingMessage(message: String) {
		delegate.messageWasReceived(message)
		
		setInboxMessage(message)
		
		if inbox.messageIsExpected() {
			if inbox.messageIsConnectionVerifier() {
				sendOutgoingMessage(message: outbox.outgoingMessage.statusRequest())
			} else if inbox.messageIsStatusMessage() {
				let statusMessage = inbox.getMessage()!
				// parse message to update status struct
                // s:x00000y00000z0.
                if let statusX = Double(statusMessage[statusMessage.index(statusMessage.startIndex, offsetBy: 3)..<statusMessage.index(statusMessage.startIndex, offsetBy: 8)]) {
                    status.x = statusX / 1000
                } else {
                    debugPrint("ERROR: x status parse failed")
                }
                
                if let statusY = Double(statusMessage[statusMessage.index(statusMessage.startIndex, offsetBy: 9)..<statusMessage.index(statusMessage.startIndex, offsetBy: 14)]) {
                    status.y = statusY / 1000
                } else {
                    debugPrint("ERROR: y status parse failed")
                }
                
                if let statusZ = Int(statusMessage[statusMessage.index(statusMessage.startIndex, offsetBy: 15)..<statusMessage.index(statusMessage.startIndex, offsetBy: 16)]) {
                    status.z = statusZ
                } else {
                    debugPrint("ERROR: z status parse failed")
                }
                
				
                // Call statusDidChange() for UI refresh
				delegate.statusDidRefresh()
				setOutboxMessage(nil)
			} else if inbox.messageIsXYCommandVerifier() {
				setOutboxMessage(nil)
            } else if inbox.messageIsZCommandVerifier() {
                setOutboxMessage(nil)
            } else if inbox.messageIsRestartVerifier() {
                setOutboxMessage(nil)
            }
            else if inbox.messageIsConfigurationNameChangeVerifier() {
				// Call deviceNameDidChange() for UI refresh
				// ---------------------------------- Will need to get the new name and pass it to deviceNameDidChange()
				let name = "New Name"
				delegate.deviceNameDidChange(name)
				setOutboxMessage(nil)
			}
		} else if inbox.getMessage() == "?" {
			sendOutgoingMessage(message: outbox.message)
		} else {
			// ---------------------------------------------- need a better way to handle asking for a repeat without risking infinite loop
			sendOutgoingMessage(message: outbox.outgoingMessage.repeatRequest())
		}
	}
	
	
	
	/// BluetoothSerialDelegate stuff
	
	/// The peripherals that have been discovered (no duplicates and sorted by asc RSSI)
	var peripherals: [(peripheral: CBPeripheral, RSSI: Float)] = []
	
	
    /// Should be called 10s after we've begun scanning
	func scanTimeOut() {
		// timeout has occurred, stop scanning and give the user the option to try again
		btSerial.stopScan()
	}
	
	/// Should be called 10s after we've begun connecting
	func connectionFailed() {
		
		// don't if we've already connected
		if let _ = btSerial.connectedPeripheral {
			return
		}
		
        delegate.peripheralConnectionFailed()
	}
	
	
	
	
    // added functionality
	func connectToPeripheral(peripheral: CBPeripheral) {
		btSerial.stopScan()//-------------------------------- this duplicates the completion block for the peripheralActionSheet in the ViewController
		btSerial.connectToPeripheral(peripheral)
        
	}
	
	
	
    func setNewXYStatus(newX: Double, newY: Double) {
		sendOutgoingMessage(message: outbox.outgoingMessage.xyCommand(x: newX, y: newY))
	}
    
    func setNewZStatus(newZ: Int) {
        sendOutgoingMessage(message: outbox.outgoingMessage.zCommand(z: newZ))
    }
	
	func requestStatusUpdate() {
		sendOutgoingMessage(message: outbox.outgoingMessage.statusRequest())
	}
    
    func sendRestartCommand() {
        sendOutgoingMessage(message: outbox.outgoingMessage.restartCommand())
    }
	
	func changePeripheralName(newName: String) {
		sendOutgoingMessage(message: outbox.outgoingMessage.changeDeviceNameCommand(newName: newName))
	}
	
    func connectToUSB() {
        usbMode = true
        sendOutgoingMessage(message: outbox.outgoingMessage.connectionRequest())
    }
    
    func disconnectUSB() {
        if usbMode {
            sendOutgoingMessage(message: outbox.outgoingMessage.usbDisconnectionCommand())
            usbMode = false
        }
    }
    
}



extension MessageHandler: BluetoothSerialDelegate {
    func serialDidReceiveString(_ message: String) {
        handleIncomingMessage(message: message)
    }
    
    func serialDidSendString(_ message: String) {
        //delegate.messageWasSent(message)
    }
    
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        delegate.peripheralDidDisconnect()
    }
    
    func serialDidChangeState() {
        let bluetoothPowerState: Bool = (btSerial.centralManager.state == .poweredOn)
        delegate.connectionDidChangeState(bluetoothPowerState)
    }
    
    func serialDidDiscoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber?) {
        var isDuplicate = false
        
        for existing in peripherals {
            if existing.peripheral.identifier == peripheral.identifier {
                isDuplicate = true
            }
        }
        
        if !isDuplicate {
            let RSSI = RSSI?.floatValue ?? 0.0
            peripherals.append((peripheral: peripheral, RSSI: RSSI))
            peripherals.sort { $0.RSSI < $1.RSSI }
        }
        
        delegate.peripheralDiscovered(isDuplicate, peripherals)
    }
    
    
    func serialDidConnect(_ peripheral: CBPeripheral) {
        delegate.peripheralConnectionSuccessful()
    }
    
    func serialDidFailToConnect(_ peripheral: CBPeripheral, error: NSError?) {
        self.connectionFailed()
    }
    
    func serialIsReady(_ peripheral: CBPeripheral) {
        // Notify Arduino of complete connection
        sendOutgoingMessage(message: outbox.outgoingMessage.connectionRequest())
        
        
        delegate.peripheralConnectionReady(peripheral)
    }
}


extension MessageHandler: PTManagerDelegate {
    
    
    func peertalk(shouldAcceptDataOfType type: UInt32) -> Bool {
        return true
    }
    
    func peertalk(didReceiveData data: Data, ofType type: UInt32) {
        
        if let message = String(data: data, encoding: .utf8) {
            handleIncomingMessage(message: message)
        } else {
            debugPrint("ERROR: Failed to convert incoming data to String")
        }
        
    }
    
    func peertalk(didChangeConnection connected: Bool) {
        print("PT Connection: \(connected)")
        
        if connected {
            // Notify Arduino of complete connection
            delegate.usbDidConnect()
        } else {
            delegate.usbDidDisconnect()
            usbMode = false
        }
    }
    
}
