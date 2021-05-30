//
//  SettingsNavigationController.swift
//  Arm Controller
//
//  Created by Erik Nordlund on 5/31/2019.
//  Copyright © 2019 Erik Nordlund. All rights reserved.
//
//  Arm Controller includes the following open-source components:
//      • swiftBluetoothSerial: https://github.com/hoiberg/SwiftBluetoothSerial
//      • peertalk-simple: https://github.com/kirankunigiri/peertalk-simple

import UIKit

class SettingsNavigationController: UINavigationController {
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		let appearance = ENAppearance(rawValue: UserDefaults.standard.object(forKey: kSavedENAppearanceDefaultsKey) as! String)!
		
		switch appearance {
		case .dark:
			return .lightContent
		default:
			return .default
		}
	}
	

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		setNeedsStatusBarAppearanceUpdate()
		
		self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: colors.navigationBarTitleColor]
		//self.navigationBar.barTintColor = colors.navigationBarTintColor
		
		self.navigationBar.barStyle = colors.navigationBarStyle
		
		
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
