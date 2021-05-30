//
//  ProjectColors.swift
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

/// Global variable to be initialized for appearance
var colors: ProjectColors!



struct ProjectColors {
	
	init(forAppearance: ENAppearance) {
		if forAppearance == .light {
			red = ENColor().redLush
			viewBackgroundColor = ENColor().whiteChalk
            logTextViewBackgroundColor = ENColor().whiteTusk
			navigationBarTintColor = viewBackgroundColor
			navigationBarTitleColor = UIColor.black
			navigationBarButtonColor = ENColor().blueVelvet
			tableViewBackgroundColor = ENColor().whiteChalk
			tableViewCellTitleColor = UIColor.black
			tableViewCellDetailColor = ENColor().grayLightNavy
			tableViewCellAccessoryColor = ENColor().blueVelvet
			tableViewCellHighlightColor = UITableView().separatorColor!
            tableViewCellBackgroundColor = UIColor.white
			tableViewSeparatorColor = UITableView().separatorColor!
			tableViewSectionHeaderTextLabelColor = ENColor().grayLightNavy
			headerLabelColor = ENColor().navyDark
			detailLabelColor = ENColor().grayLightNavy
            fullScreenTextViewBackgroundColor = ENColor().whiteChalk
			bodyTextColor = UIColor.black
            textViewTintColor = ENColor().blueVelvet
            textFieldBackgroundColor = ENColor().whiteTusk
            textFieldPlaceholderColor = ENColor().grayLight
			buttonColor = ENColor().navyLight
            highlightedButtonColor = ENColor().navyLight
            destructiveButtonColor = ENColor().redLush
			shadowColor = UIColor.black
			
			navigationBarStyle = .default
            keyboardAppearance = .light
		} else if forAppearance == .dark {
			red = ENColor().redLush
			viewBackgroundColor = UIColor.black
            logTextViewBackgroundColor = ENColor().grayLightNavy
			navigationBarTintColor = viewBackgroundColor
			navigationBarTitleColor = ENColor().whiteChalk
			navigationBarButtonColor = ENColor().blueEnergy
			tableViewBackgroundColor = UIColor.black
			tableViewCellTitleColor = ENColor().whiteChalk
			tableViewCellDetailColor = ENColor().grayLightNavy
			tableViewCellAccessoryColor = ENColor().blueEnergy
			tableViewCellHighlightColor = ENColor().navyDark
            tableViewCellBackgroundColor = UIColor.black
			tableViewSeparatorColor = ENColor().navyDark
			tableViewSectionHeaderTextLabelColor = ENColor().grayLightNavy
			headerLabelColor = ENColor().whiteChalk
			detailLabelColor = ENColor().whiteChalk//maybe whiteTusk?
			fullScreenTextViewBackgroundColor = UIColor.black
            bodyTextColor = UIColor.white
            textViewTintColor = ENColor().blueEnergy
            textFieldBackgroundColor = ENColor().navyDark
            textFieldPlaceholderColor = ENColor().whiteChalk
			buttonColor = ENColor().navyLight
            highlightedButtonColor = ENColor().navyLight
            destructiveButtonColor = ENColor().redLush
			shadowColor = UIColor.darkGray
			
			navigationBarStyle = .black
            keyboardAppearance = .dark
		} else {
			// default values as a fallback
			red = UIColor.red
			viewBackgroundColor = UIColor.white
            logTextViewBackgroundColor = UIColor.white
			navigationBarTintColor = viewBackgroundColor
			navigationBarTitleColor = UIColor.black
			navigationBarButtonColor = UIColor.blue
			tableViewBackgroundColor = UITableView().backgroundColor!
			tableViewCellTitleColor = UIColor.black
			tableViewCellDetailColor = UIColor.gray
			tableViewCellAccessoryColor = UIColor.blue
			tableViewCellHighlightColor = UITableView().separatorColor!
            tableViewCellBackgroundColor = UIColor.white
			tableViewSeparatorColor = UITableView().separatorColor!
			tableViewSectionHeaderTextLabelColor = UIColor.gray
			headerLabelColor = UIColor.black
			detailLabelColor = UIColor.gray
			fullScreenTextViewBackgroundColor = UIColor.white
            bodyTextColor = UIColor.black
            textViewTintColor = UIColor.blue
            textFieldBackgroundColor = UIColor.white
            textFieldPlaceholderColor = UIColor.gray
			buttonColor = UIColor.gray
            highlightedButtonColor = UIColor.blue
            destructiveButtonColor = UIColor.red
			shadowColor = UIColor.black
			
			navigationBarStyle = .default
            keyboardAppearance = .default
		}
	}
	
	var red: UIColor
	var viewBackgroundColor: UIColor
    var logTextViewBackgroundColor: UIColor
	var navigationBarTintColor: UIColor
	var navigationBarTitleColor: UIColor
	var navigationBarButtonColor: UIColor
	var tableViewBackgroundColor: UIColor
	var tableViewCellTitleColor: UIColor
	var tableViewCellDetailColor: UIColor
	var tableViewCellAccessoryColor: UIColor
	var tableViewCellHighlightColor: UIColor
    var tableViewCellBackgroundColor: UIColor
	var tableViewSeparatorColor: UIColor
	var tableViewSectionHeaderTextLabelColor: UIColor
	var headerLabelColor: UIColor
	var detailLabelColor: UIColor
    var fullScreenTextViewBackgroundColor: UIColor
	var bodyTextColor: UIColor
    var textViewTintColor: UIColor
    var textFieldBackgroundColor: UIColor
    var textFieldPlaceholderColor: UIColor
	var buttonColor: UIColor
    var highlightedButtonColor: UIColor
    var destructiveButtonColor: UIColor
	var shadowColor: UIColor
	
	var navigationBarStyle: UIBarStyle
    var keyboardAppearance: UIKeyboardAppearance
}
