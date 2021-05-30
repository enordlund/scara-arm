//
//  ENConnectionButton.swift
//  Arm Controller
//
//  Created by Erik Nordlund on 45/31/2019.
//  Copyright © 2019 Erik Nordlund. All rights reserved.
//
//  Arm Controller includes the following open-source components:
//      • swiftBluetoothSerial: https://github.com/hoiberg/SwiftBluetoothSerial
//      • peertalk-simple: https://github.com/kirankunigiri/peertalk-simple

import UIKit
import CoreBluetooth

class ENConnectivityButton: ENButton, MessageHandlerDelegate {
    func usbDidConnect() {
        connectedState()
    }
    
    func usbDidDisconnect() {
        disconnectedState()
    }
    
    
    var discoveryManagement = true
    
    
    private func connectedState() {
        self.setTitle("Disconnect", for: .normal)
        
        if discoveryManagement {
            self.disableDiscoverability()
        }
    }
    
    private func disconnectedState() {
        self.setTitle("Connect", for: .normal)
        
        if discoveryManagement {
            self.enableDiscoverability(delay: 10.0, animationDuration: 1.0, repeatInterval: 4.0)
        }
    }
    
    
    func updateState() {
        if messageHandler.bluetoothIsConnected {
            connectedState()
        } else {
            disconnectedState()
        }
    }
    
    func statusDidRefresh() {
        return
    }
    
    func deviceNameDidChange(_ name: String) {
        return
    }
    
    func messageWasReceived(_ message: String) {
        return
    }
    
    func messageWasSent(_ message: String) {
        return
    }
    
    func peripheralDidDisconnect() {
        disconnectedState()
    }
    
    func connectionDidChangeState(_ poweredOn: Bool) {
        return
    }
    
    func peripheralDiscovered(_ isDuplicate: Bool, _ peripherals: [(peripheral: CBPeripheral, RSSI: Float)]) {
        return
    }
    
    func peripheralConnectionSuccessful() {
        self.setTitle("Connecting", for: .normal)
        
        if discoveryManagement {
            self.disableDiscoverability()
        }
    }
    
    func peripheralConnectionFailed() {
        disconnectedState()
    }
    
    func peripheralConnectionReady(_ peripheral: CBPeripheral) {
        connectedState()
    }
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    // Could create a hyper-integrated button that automatically refreshes when a connection status changes.
    
}
