//
//  WindowController.swift
//  Arm USB
//
//  Created by Erik Nordlund on 5/17/19.
//  Copyright © 2019 Erik Nordlund. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    @IBOutlet weak var toolbar: NSToolbar!
    @IBOutlet weak var toggleConnectionButton: NSButton!
    
    
    @IBAction func toggleConnection(_ sender: Any) {
        usbSerial.toggleConnection()
        
        if usbSerial.serialPort?.isOpen ?? false {
            toggleConnectionButton.title = "Close Connection"
        } else {
            toggleConnectionButton.title = "Open Connection"
        }
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        usbSerial.portDelegate = self
    }
    
}

extension WindowController: USBSerialPortDelegate {
    func portDidSet() {
        debugPrint("portDidChange")
        if usbSerial.serialPort?.isOpen ?? false {
            debugPrint("serialPort.isOpen")
            toggleConnectionButton.title = "Close Connection"
        } else {
            debugPrint("!serialPort.isOpen")
            toggleConnectionButton.title = "Open Connection"
        }
    }
    
    
}
