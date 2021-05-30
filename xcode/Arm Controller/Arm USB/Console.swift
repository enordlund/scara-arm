//
//  Console.swift
//  Arm USB
//
//  Created by Erik Nordlund on 5/17/19.
//  Copyright © 2019 Erik Nordlund. All rights reserved.
//
//  Arm USB includes the following open-source components:
//      • peertalk-simple: https://github.com/kirankunigiri/peertalk-simple
//      • ORSSerialPort: https://github.com/armadsen/ORSSerialPort

import Foundation

var console: Console!

protocol ConsoleDelegate {
    func connectionDidChange()
}

struct Console {
    var delegate: ConsoleDelegate!
    
    init(delegate: ConsoleDelegate) {
        self.delegate = delegate
    }
}
