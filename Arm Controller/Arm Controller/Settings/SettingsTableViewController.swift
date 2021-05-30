//
//  SettingsTableViewController.swift
//  Arm Controller
//
//  Created by Erik Nordlund on 5/31/2019.
//  Copyright © 2019 Erik Nordlund. All rights reserved.
//
//  Arm Controller includes the following open-source components:
//      • swiftBluetoothSerial: https://github.com/hoiberg/SwiftBluetoothSerial
//      • peertalk-simple: https://github.com/kirankunigiri/peertalk-simple

import UIKit

class SettingsTableViewController: UITableViewController {
	
	@IBOutlet weak var doneButton: UIBarButtonItem!
	
	@IBAction func done(_ sender: Any) {
		performSegue(withIdentifier: "unwindToViewController", sender: self)
	}
	
	var selectedIndexPath = IndexPath()
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
		
		
		
		
    }
	
	override func viewWillAppear(_ animated: Bool) {
		refreshAppearance()
	}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		
		switch section {
		case 0:
			return 1
		case 1:
			return 1
		default:
			return 0
		}
    }
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell: UITableViewCell
		
		
		switch indexPath.section {
		case 0:
			switch indexPath.row {
			case 0:
				cell = tableView.dequeueReusableCell(withIdentifier: "appearanceCell", for: indexPath)
				
				let appearance = ENAppearance(rawValue: UserDefaults.standard.object(forKey: kSavedENAppearanceDefaultsKey) as! String)
				
				if appearance == .light {
					cell.detailTextLabel?.text = "Light"
				} else if appearance == .dark {
					cell.detailTextLabel?.text = "Dark"
				} else if appearance == .dynamic {
					cell.detailTextLabel?.text = "Dynamic"
				} else {
					cell.detailTextLabel?.text = "?"
				}
				
			case 1:
				cell = tableView.dequeueReusableCell(withIdentifier: "notificationsCell", for: indexPath)
			default:
				cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
			}
		case 1:
            switch indexPath.row {
            case 0:
                cell = tableView.dequeueReusableCell(withIdentifier: "privacyInformationCell", for: indexPath)
            default:
                cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            }
		default:
			cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
		}
		
		
        // Configure the cell...
		//cell.selectionStyle = .none
		
		let colorView = UIView()
		colorView.backgroundColor = colors.tableViewCellHighlightColor
		
		cell.backgroundColor = colors.tableViewCellBackgroundColor
		
		cell.selectedBackgroundView = colorView
		
		cell.tintColor = colors.tableViewCellAccessoryColor
		
		cell.textLabel?.textColor = colors.tableViewCellTitleColor
		
		cell.detailTextLabel?.textColor = colors.tableViewCellDetailColor
		
        return cell
    }
	
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0:
			return "Settings"
		case 1:
			return "Information"
		default:
			return nil
		}
	}
	
	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		(view as? UITableViewHeaderFooterView)?.textLabel?.textColor = colors.tableViewSectionHeaderTextLabelColor
	}
	/*
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if let cell = tableView.cellForRow(at: indexPath) {
			
			switch indexPath.section {
			case 0:
				tableView.deselectRow(at: indexPath, animated: true)
				
				if indexPath != selectedIndexPath {
					
					cell.accessoryType = .checkmark
					
					tableView.cellForRow(at: selectedIndexPath)?.accessoryType = .none
					
					selectedIndexPath = indexPath
					
					
					switch indexPath.row {
					case 0:
						//appearance = .light
						UserDefaults.standard.set("lightAppearance", forKey: kSavedAppearanceDefaultsKey)
					case 1:
						//appearance = .dark
						UserDefaults.standard.set("darkAppearance", forKey: kSavedAppearanceDefaultsKey)
					case 2:
						//appearance = .dynamic
						UserDefaults.standard.set("dynamicAppearance", forKey: kSavedAppearanceDefaultsKey)
					default:
						//appearance = .light
						UserDefaults.standard.set("lightAppearance", forKey: kSavedAppearanceDefaultsKey)
					}
					
					refreshAppearance()
				}
				
				
				
			default:
				return
			}
			
			// anything else you wanna do every time a cell is tapped
		}
		
	}
	
	*/
	func refreshAppearance() {
		
		if let appearance = ENAppearance(rawValue: UserDefaults.standard.object(forKey: kSavedENAppearanceDefaultsKey) as! String) {
			colors = ProjectColors(forAppearance: appearance)
			
			doneButton.tintColor = colors.navigationBarButtonColor
			self.tableView.backgroundColor = colors.tableViewBackgroundColor
			self.tableView.separatorColor = colors.tableViewSeparatorColor
			
			
			tableView.reloadData()
		} else {
			/// error handling
		}
		
		
	}
	

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
