//
//  AboutViewController.swift
//  Arm Controller
//
//  Created by Erik Nordlund on 5/31/2019.
//  Copyright © 2019 Erik Nordlund. All rights reserved.
//
//  Arm Controller includes the following open-source components:
//      • swiftBluetoothSerial: https://github.com/hoiberg/SwiftBluetoothSerial
//      • peertalk-simple: https://github.com/kirankunigiri/peertalk-simple

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        refreshAppearance()
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func refreshAppearance() {
        
        if let appearance = ENAppearance(rawValue: UserDefaults.standard.object(forKey: kSavedENAppearanceDefaultsKey) as! String) {
            colors = ProjectColors(forAppearance: appearance)
            
            //self.tableView.backgroundColor = colors.tableViewBackgroundColor
            //self.tableView.separatorColor = colors.tableViewSeparatorColor
            
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: colors.navigationBarTitleColor]
            self.navigationController?.navigationBar.barStyle = colors.navigationBarStyle
            self.navigationController?.navigationBar.tintColor = colors.navigationBarButtonColor
            
            self.view.backgroundColor = colors.viewBackgroundColor
            
            self.textView.backgroundColor = colors.fullScreenTextViewBackgroundColor
            self.textView.textColor = colors.bodyTextColor
            self.textView.tintColor = colors.textViewTintColor
            
            //tableView.reloadData()
        } else {
            /// error handling
        }
        
        
    }

}
