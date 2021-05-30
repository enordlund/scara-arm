//
//  AppearanceTableViewController.swift
//  Arm Controller
//
//  Created by Erik Nordlund on 5/31/2019.
//  Copyright © 2019 Erik Nordlund. All rights reserved.
//
//  Arm Controller includes the following open-source components:
//      • swiftBluetoothSerial: https://github.com/hoiberg/SwiftBluetoothSerial
//      • peertalk-simple: https://github.com/kirankunigiri/peertalk-simple

import UIKit

class AppearanceTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
	
	override func viewWillAppear(_ animated: Bool) {
		refreshAppearance()
	}

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		switch section {
		case 0:
			return 2
		default:
			return 0
		}
    }
	
	
	
	var selectedIndexPath = IndexPath()
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell: UITableViewCell
		
		let section = indexPath.section
		let row = indexPath.row
		
		switch section {
		case 0:
			let appearance = ENAppearance(rawValue: UserDefaults.standard.object(forKey: kSavedENAppearanceDefaultsKey) as! String)
			switch row {
			case 0:
				cell = tableView.dequeueReusableCell(withIdentifier: "lightAppearanceCell", for: indexPath)
				if appearance == .light {
					cell.accessoryType = .checkmark
					selectedIndexPath = IndexPath(row: 0, section: 0)
				}
			case 1:
				cell = tableView.dequeueReusableCell(withIdentifier: "darkAppearanceCell", for: indexPath)
				if appearance == .dark {
					cell.accessoryType = .checkmark
					selectedIndexPath = IndexPath(row: 1, section: 0)
				}
			default:
				cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
			}
		default:
			cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
		}
		
		let colorView = UIView()
		colorView.backgroundColor = colors.tableViewCellHighlightColor
		
		cell.backgroundColor = colors.tableViewCellBackgroundColor
		
		cell.selectedBackgroundView = colorView
		
		cell.tintColor = colors.tableViewCellAccessoryColor
		
		cell.textLabel?.textColor = colors.tableViewCellTitleColor
		
		cell.detailTextLabel?.textColor = colors.tableViewCellDetailColor
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		(view as? UITableViewHeaderFooterView)?.textLabel?.textColor = colors.tableViewSectionHeaderTextLabelColor
	}
	
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
						UserDefaults.standard.set("lightAppearance", forKey: kSavedENAppearanceDefaultsKey)
					case 1:
						//appearance = .dark
						UserDefaults.standard.set("darkAppearance", forKey: kSavedENAppearanceDefaultsKey)
					default:
						//appearance = .light
						UserDefaults.standard.set("lightAppearance", forKey: kSavedENAppearanceDefaultsKey)
					}
					
					refreshAppearance()
				}
				
				
				
			default:
				return
			}
			
			// anything else you wanna do every time a cell is tapped
		}
		
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0:
			return nil//"Title"
		default:
			return nil
		}
	}
	
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        /*
		switch section {
		case 0:
			return "Dynamic Appearance synchronizes Light Appearance and Dark Appearance with local sunrise and sunset."
		default:
			return nil
		}*/
        return nil
	}
	
	func refreshAppearance() {
		
		if let appearance = ENAppearance(rawValue: UserDefaults.standard.object(forKey: kSavedENAppearanceDefaultsKey) as! String) {
			colors = ProjectColors(forAppearance: appearance)
			
			self.tableView.backgroundColor = colors.tableViewBackgroundColor
			self.tableView.separatorColor = colors.tableViewSeparatorColor
			
			self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: colors.navigationBarTitleColor]
			self.navigationController?.navigationBar.barStyle = colors.navigationBarStyle
			self.navigationController?.navigationBar.tintColor = colors.navigationBarButtonColor
			
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
