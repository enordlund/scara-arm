//
//  ViewController.swift
//  Arm Controller
//
//  Created by Erik Nordlund on 5/31/2019.
//  Copyright © 2019 Erik Nordlund. All rights reserved.
//
//  Arm Controller includes the following open-source components:
//      • swiftBluetoothSerial: https://github.com/hoiberg/SwiftBluetoothSerial
//      • peertalk-simple: https://github.com/kirankunigiri/peertalk-simple

import UIKit
import CoreBluetooth
import SpriteKit

/// The option to add a \n or \r or \r\n to the end of the send message
enum MessageOption: Int {
	case noLineEnding,
	newline,
	carriageReturn,
	carriageReturnAndNewline
}

/// The option to add a \n to the end of the received message (to make it more readable)
enum ReceivedMessageOption: Int {
	case none,
	newline
}

let boundsPoint = Point2D(x: 8.5, y: 11)

let defaultPen = Pen(name: "Fine Black Sharpie", color: UIColor.black, dryTime: 1.0, widthMillimeters: 2.0)


class ViewController: UIViewController {
	
    @IBOutlet weak var draftTitleLabel: UILabel!
    @IBOutlet weak var editorTitleLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    
    @IBOutlet weak var addLineButton: ENButton!
    
    @IBOutlet weak var draftSprite: SKView!
    
    @IBOutlet weak var clearDraftButton: ENButton!
    
    @IBOutlet weak var livePreviewTitle: UILabel!
    @IBOutlet weak var livePreviewSprite: SKView!
    
    @IBOutlet weak var exitDrawingLabel: ENButton!
    
    @IBOutlet weak var consoleTitleLabel: UILabel!
    
    @IBOutlet weak var pointAX: UITextField!
    @IBOutlet weak var pointAY: UITextField!
    
    @IBOutlet weak var pointBX: UITextField!
    @IBOutlet weak var pointBY: UITextField!
    
    @IBOutlet weak var undoPreviewLineButton: ENButton!
    
    @IBOutlet weak var drawingProgressView: UIProgressView!
    
    @IBOutlet weak var drawDraftButton: ENButton!
    @IBOutlet weak var startDrawingButton: ENButton!
    @IBOutlet weak var stopDrawingButton: ENButton!
    
    @IBOutlet weak var exitDrawingButton: ENButton!
    
    @IBOutlet weak var drawingSetupActivityIndicator: UIActivityIndicatorView!
    
    
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var connectionStatusLabel: UILabel!
    @IBOutlet weak var connectedDeviceOptionsButton: UIButton!
    
    @IBOutlet weak var settingsButton: ENButton!
    
    @IBOutlet weak var connectionButton: ENButton!
    
    
    
    
    
    @IBAction func previewLine(_ sender: Any) {
        if let line = generateManualLineFromTextFields() {
            
            if clearDraftButton.isHidden {
                clearDraftButton.apparate()
            }
            
            if undoPreviewLineButton.isHidden {
                undoPreviewLineButton.apparate()
                undoPreviewLineButton.isVanishing = false
            }
            
            if drawDraftButton.isHidden {
                drawDraftButton.apparate()
            }
            
            // add line to output
            drawDraftLine(fromPath: Path2D(asLine: line, pen: defaultPen))
            undoPreviewLineButton.isEnabled = true
            // draw line in preview
            
            
            var pointBXText = pointBX.text
            var pointBYText = pointBY.text
            
            if pointBXText == "" {
                debugPrint("pointBX.placeholder = ", pointBX.placeholder as Any)
                pointBXText = pointBX.placeholder
            }
            
            if pointBYText == "" {
                pointBYText = pointBY.placeholder
            }
            
            pointAX.text = nil
            pointAX.placeholder = pointBXText
            
            pointAY.text = nil
            pointAY.placeholder = pointBYText
            
            pointBX.text = nil
            pointBX.placeholder = "X"
            pointBY.text = nil
            pointBY.placeholder = "Y"
            
            pointBX.becomeFirstResponder()
            
        }
    }
    
    @IBAction func undoPreviewLine(_ sender: Any) {
        undoLine()
    }
    
    func undoLine() {
        debugPrint("undoPreviewLine()")
        if let lastChild = draftSpriteChildren.last {
            debugPrint("proceeding with undo")
            
            // setting placeholder for current line
            if let lastAX = draftPaths.paths.last?.segments.last?.pointA.x {
                if let lastAY = draftPaths.paths.last?.segments.last?.pointA.y {
                    pointAX.placeholder = String(lastAX)
                    pointAY.placeholder = String(lastAY)
                }
            }
            
            if draftPaths.paths.count != 0 {
                if let lastBX = draftPaths.paths.last?.segments.last?.pointB.x {
                    if let lastBY = draftPaths.paths.last?.segments.last?.pointB.y {
                        pointBX.placeholder = String(lastBX)
                        pointBY.placeholder = String(lastBY)
                    }
                }
            }
            
            
            
            
            draftSpriteChildren.removeLast()
            draftPaths.removeLastPath()
            draftSprite.scene?.removeChildren(in: [lastChild])
            if draftSpriteChildren.count < 1 {
                undoPreviewLineButton.isEnabled = false;
            }
            
            if draftPaths.paths.count == 0 {
                undoPreviewLineButton.isVanishing = true
                clearDraftButton.vanish()
                drawDraftButton.vanish()
                
                pointAX.placeholder = "X"
                pointAY.placeholder = "Y"
                pointBX.placeholder = "X"
                pointBY.placeholder = "Y"
                
                if pointAX.text == "" && pointAY.text == "" && pointBX.text == "" && pointBY.text == "" {
                    self.view.endEditing(true)
                }
                
            }
            
            
        } else {
            debugPrint("ERROR: Undo failed. No children to undo.")
        }
    }
    
    @IBAction func drawDraft(_ sender: Any) {
        
        if messageHandler.bluetoothIsConnected || messageHandler.usbMode {
            
            drawDraftButton.isVanishing = true
            // setup
            drawingSetupActivityIndicator.startAnimating()
            
            clearDraftButton.vanish()
            
            // after setup...
            livePreviewTitle.isHidden = false
            livePreviewSprite.isHidden = false
            startDrawingButton.isHidden = false
            drawingProgressView.isHidden = true
            stopDrawingButton.isHidden = true
            exitDrawingButton.isHidden = false
            
            self.view.endEditing(true)
        } else {
            drawDraftButton.isVanishing = false
            let alert: UIAlertController = UIAlertController(title: "No Connection", message: "Press the Connect button to search for connections.", preferredStyle: UIAlertController.Style.alert)
            let defaultAction = UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.cancel, handler: {(alert: UIAlertAction!) in print("Arm not connected")})
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        }
        
        
        
    }
    
    @IBAction func clearDraft(_ sender: Any) {
        
        let alert: UIAlertController = UIAlertController(title: "Erase Draft", message: "This will erase your current draft.", preferredStyle: UIAlertController.Style.alert)
        let confirmationAction = UIAlertAction(title: "Erase", style: UIAlertAction.Style.destructive, handler: {(alert: UIAlertAction!) in
            debugPrint("clearing draft")
            self.draftSprite.scene?.removeChildren(in: self.draftSpriteChildren)
            self.draftPaths = PathSet2D()
            
            self.pointAX.placeholder = "X"
            self.pointAY.placeholder = "Y"
            
            self.pointBX.text = ""
            self.pointBY.text = ""
            
            self.undoPreviewLineButton.vanish()
            self.clearDraftButton.vanish()
            self.drawDraftButton.vanish()
            
            self.view.endEditing(true)
            
        })
        alert.addAction(confirmationAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {(alert: UIAlertAction!) in
            debugPrint("canceling clearing draft")
            
        })
        alert.addAction(cancelAction)
        alert.preferredAction = cancelAction
        self.present(alert, animated: true, completion: nil)
        
        
        
        
    }
    
    @IBAction func startDrawing(_ sender: Any) {
        // update UI elements to display drawing UI
        startDrawingButton.isHidden = true
        stopDrawingButton.apparate()
        drawingProgressView.isHidden = false
        drawingProgressView.progress = 0
        exitDrawingButton.isHidden = true
        
        // start drawing
        startDrawing(pathSet: draftPaths)
    }
    
    @IBAction func stopDrawing(_ sender: Any) {
        // clear the command pipeline
        commands.removeAll()
        
        // update the UI
        drawingProgressView.isHidden = true
        exitDrawingButton.isHidden = false
        drawingSetupActivityIndicator.stopAnimating()
        
    }
    
    @IBAction func exitDrawing(_ sender: Any) {
        messageHandler.sendRestartCommand()
        
        // clear the command pipeline
        commands.removeAll()
        
        // update the UI
        livePreviewSprite.scene?.removeChildren(in: livePreviewSpriteChildren)
        
        clearDraftButton.apparate()
        drawDraftButton.apparate()
        
        livePreviewTitle.isHidden = true
        livePreviewSprite.isHidden = true
        startDrawingButton.isHidden = true
        drawingProgressView.isHidden = true
        stopDrawingButton.isHidden = true
        exitDrawingButton.isHidden = true
        
        drawingSetupActivityIndicator.stopAnimating()
        
        
    }
    
    @IBAction func sendTestCoordinate(_ sender: Any) {
        // sends the second coordinate to the arduino for testing
        
        let xValue = Double(pointBX.text!)!
        let yValue = Double(pointBY.text!)!
        
        debugPrint("Sending test coordinates: ", xValue, yValue)
        
        messageHandler.setNewXYStatus(newX: xValue, newY: yValue)
    }
    
    @IBAction func toggleZ(_ sender: Any) {
        // toggles the height of the pen between up and down
        
        debugPrint("toggling z")
        
        if messageHandler.status.z == 1 {
            messageHandler.setNewZStatus(newZ: 0)
        } else if messageHandler.status.z == 0 {
            messageHandler.setNewZStatus(newZ: 1)
        } else {
            messageHandler.setNewZStatus(newZ: 1)
        }
    }
    
    
    var draftPaths = PathSet2D()
    var draftSpriteChildren = [SKNode()]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        // Initialize messageHandler
        messageHandler = MessageHandler(delegate: self)
        
        self.pointAX.delegate = self
        self.pointAY.delegate = self
        self.pointBX.delegate = self
        self.pointBY.delegate = self
        
        //peripheralActionSheet.addAction(peripheralActionSheetCancelAction)
        draftSprite.layer.shadowRadius = 4.0
        draftSprite.layer.shadowOpacity = 0.2
        draftSprite.layer.shadowOffset = CGSize(width: 0.0, height: 0.6)
        
        let firstScene = SKScene(size: draftSprite.frame.size)
        firstScene.backgroundColor = UIColor.white
        draftSprite.presentScene(firstScene)
        
        
        livePreviewSprite.layer.shadowRadius = 4.0
        livePreviewSprite.layer.shadowOpacity = 0.2
        livePreviewSprite.layer.shadowOffset = CGSize(width: 0.0, height: 0.6)
        
        let livePreviewScene = SKScene(size: livePreviewSprite.frame.size)
        livePreviewScene.backgroundColor = UIColor.white
        livePreviewSprite.presentScene(livePreviewScene)
        
        clearDraftButton.isHidden = true
        
        undoPreviewLineButton.isHidden = true
        drawDraftButton.isHidden = true
        drawDraftButton.isVanishing = true
        
        livePreviewTitle.isHidden = true
        livePreviewSprite.isHidden = true
        startDrawingButton.isHidden = true
        drawingProgressView.isHidden = true
        stopDrawingButton.isHidden = true
        exitDrawingButton.isHidden = true
        
        
        
        stopDrawingButton.isVanishing = true
        
        drawingSetupActivityIndicator.stopAnimating()
        
        connectionButton.enableDiscoverability(delay: 10.0, animationDuration: 1.0, repeatInterval: 4.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshAppearance()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = event?.allTouches?.first
        
        if !(touch?.view is UITextField) {
            self.view.endEditing(true)
        }
        
        super.touchesBegan(touches, with: event)
    }
    
    // adding undo keyboard shortcut
    /*
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "z", modifierFlags: .command, action: #selector(self.undoLineCommand(sender:)), discoverabilityTitle: "Undo Line")
        ]
    }
    */
    
    var commands = [CoordinateCommand]()
    
    
    func startDrawing(pathSet: PathSet2D) {
        
        
        // creating coordinate commands
        commands = pathSet.getCommands()
        
        
        // send the first command to kick the message handler into sending the commands
        let firstCommand = commands.removeFirst()
        
        if firstCommand is ZCommand {
            messageHandler.setNewZStatus(newZ: (firstCommand as! ZCommand).z)
        } else if firstCommand is XYCommand {
            messageHandler.setNewXYStatus(newX: (firstCommand as! XYCommand).x, newY: (firstCommand as! XYCommand).y)
        } else {
            debugPrint("ERROR: command type unrecognized: ", firstCommand)
        }
    }
    
    
    
    var livePreviewPaths = PathSet2D()
    var livePreviewSpriteChildren = [SKNode()]
    
    func refreshLivePreview() {
        if previousStatus != nil {
            if previousStatus!.z == 0 && messageHandler.status.z == 0 {
                let newLine = SKShapeNode()
                let drawingPath = CGMutablePath()
                
                let scaledStartPointX = scaleToPoints(fromInches: previousStatus!.x!)
                let scaledStartPointY = scaleToPoints(fromInches: previousStatus!.y!)
                let scaledStartPoint = CGPoint(x: scaledStartPointX, y: scaledStartPointY)
                drawingPath.move(to: scaledStartPoint)
                
                let scaledEndPointX = scaleToPoints(fromInches: messageHandler.status.x!)
                let scaledEndPointY = scaleToPoints(fromInches: messageHandler.status.y!)
                let scaledEndPoint = CGPoint(x: scaledEndPointX, y: scaledEndPointY)
                drawingPath.addLine(to: scaledEndPoint)
                
                newLine.path = drawingPath
                newLine.strokeColor = SKColor(cgColor: currentPen.color.cgColor)
                newLine.lineWidth = CGFloat(scaleToPoints(fromInches: currentPen.widthInches))
                
                if livePreviewSprite.scene?.addChild(newLine) != nil {
                    debugPrint("adding line to live preview")
                    livePreviewSpriteChildren.append(newLine)
                    debugPrint("line successful")
                    
                } else {
                    debugPrint("line failed")
                }
            }
        } else {
            
        }
        drawingProgressView.progress = 1 / Float(commands.count + 1)
        previousStatus = messageHandler.status
    }
    
    var previousStatus: Status?
    var currentPen: Pen = defaultPen
    
    func drawDraftLine(fromPath: Path2D) {
        debugPrint("trying to draw line")
        if let startPoint = fromPath.segments.first?.pointA {
            if let endPoint = fromPath.segments.first?.pointB {
                // adding path to path set
                draftPaths.append(path: fromPath)
                
                
                let newLine = SKShapeNode()
                let drawingPath = CGMutablePath()
                
                let scaledStartPointX = scaleToPoints(fromInches: startPoint.x)
                let scaledStartPointY = scaleToPoints(fromInches: startPoint.y)
                let scaledStartPoint = CGPoint(x: scaledStartPointX, y: scaledStartPointY)
                drawingPath.move(to: scaledStartPoint)
                
                let scaledEndPointX = scaleToPoints(fromInches: endPoint.x)// - startPoint.x
                let scaledEndPointY = scaleToPoints(fromInches: endPoint.y)// - startPoint.y
                let scaledEndPoint = CGPoint(x: scaledEndPointX, y: scaledEndPointY)
                drawingPath.addLine(to: scaledEndPoint)
                
                newLine.path = drawingPath
                newLine.strokeColor = SKColor(cgColor: fromPath.pen.color.cgColor)
                newLine.lineWidth = CGFloat(scaleToPoints(fromInches: fromPath.pen.widthInches))
                
                if draftSprite.scene?.addChild(newLine) != nil {
                    debugPrint("adding line to draft")
                    draftSpriteChildren.append(newLine)
                    debugPrint("line successful")
                    
                } else {
                    debugPrint("line failed")
                }
            } else {
                debugPrint("endPoint failed")
            }
        } else {
            debugPrint("startPoint failed")
        }
    }
    
    func scaleToPoints(fromInches: Double) -> Double {
        // (width of previewScene in points)/8.5 = scale
        let scaleFactor = Double(draftSprite.frame.width / 8.5)
        
        debugPrint("scaleFactor = ", scaleFactor)
        
        return fromInches * scaleFactor
    }
    
    func generateManualLineFromTextFields() -> Line2D? {
        var pointA: Point2D!
        var pointB: Point2D!
        var errorString: String? = nil
        
        
        do {
            var pointAXText = pointAX.text
            var pointAYText = pointAY.text
            
            if pointAXText == "" {
                debugPrint("pointAX.placeholder = ", pointAX.placeholder as Any)
                pointAXText = pointAX.placeholder
            }
            
            if pointAYText == "" {
                pointAYText = pointAY.placeholder
            }
            
            pointA = try getPointFromStrings2D(xString: pointAXText, yString: pointAYText)
            
            do {
                
                var pointBXText = pointBX.text
                var pointBYText = pointBY.text
                
                if pointBXText == "" {
                    debugPrint("pointBX.placeholder = ", pointBX.placeholder as Any)
                    pointBXText = pointBX.placeholder
                }
                
                if pointBYText == "" {
                    pointBYText = pointBY.placeholder
                }
                
                pointB = try getPointFromStrings2D(xString: pointBXText, yString: pointBYText)
                
                do {
                    
                    
                    let line = try getLine2D(withBoundsFromZeroTo: boundsPoint, fromPoint: pointA, toPoint: pointB)
                    
                    debugPrint("Points A and B:")
                    debugPrint(pointA)
                    debugPrint(pointB)
                    
                    // proceed to draw preview line
                    return line
                    
                } catch {
                    // this is where I can handle the error UI Alerts
                    debugPrint("ERROR: \(error)")
                    errorString = getLineErrorString(forError: error)
                }
                
            } catch {
                debugPrint("ERROR (Point B): \(error)")
                errorString = getPointErrorString(forError: error)
            }
            
        } catch {
            debugPrint("ERROR (Point A): \(error)")
            errorString = getPointErrorString(forError: error)
        }
        
        // create UIAlert if errorString != nil
        if errorString != nil {
            let alert: UIAlertController = UIAlertController(title: "Invalid Line", message: errorString, preferredStyle: UIAlertController.Style.alert)
            let defaultAction = UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.cancel, handler: {(alert: UIAlertAction!) in print("Point entry error alert")})
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        }
        
        return nil
    }
    
    
    
    var peripheralActionSheet: UIAlertController? = nil
	
	func dismiss(_ segue: UIStoryboardSegue) {
		self.dismiss(animated: true, completion: nil)
	}
	
	func roundViews() {
		view.layer.cornerRadius = 14
		view.clipsToBounds = true
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		let appearance = ENAppearance(rawValue: UserDefaults.standard.object(forKey: kSavedENAppearanceDefaultsKey) as! String)
		
		switch appearance {
		case .dark?:
			return .lightContent
		default:
			return .default
		}
	}

	
	
	func refreshAppearance() {
		
		if let appearance = ENAppearance(rawValue: UserDefaults.standard.object(forKey: kSavedENAppearanceDefaultsKey) as! String) {
			colors = ProjectColors(forAppearance: appearance)
			
			self.view.backgroundColor = colors.viewBackgroundColor
			
			self.setNeedsStatusBarAppearanceUpdate()
			
			connectionButton.backgroundColor = colors.buttonColor
			settingsButton.backgroundColor = colors.buttonColor
			
			connectedDeviceOptionsButton.titleLabel?.textColor = colors.detailLabelColor
			
			connectionStatusLabel.textColor = colors.detailLabelColor
			
			textView.backgroundColor = colors.viewBackgroundColor
			textView.textColor = colors.bodyTextColor
            
            draftTitleLabel.textColor = colors.headerLabelColor
            editorTitleLabel.textColor = colors.headerLabelColor
            livePreviewTitle.textColor = colors.headerLabelColor
            fromLabel.textColor = colors.bodyTextColor
            toLabel.textColor = colors.bodyTextColor
            
            addLineButton.backgroundColor = colors.buttonColor
            undoPreviewLineButton.titleLabel?.textColor = colors.destructiveButtonColor
            
            clearDraftButton.backgroundColor = colors.destructiveButtonColor
            drawDraftButton.backgroundColor = colors.buttonColor
            
            exitDrawingButton.titleLabel?.textColor = colors.buttonColor
            stopDrawingButton.backgroundColor = colors.destructiveButtonColor
            
            pointAX.keyboardAppearance = colors.keyboardAppearance
            pointAY.keyboardAppearance = colors.keyboardAppearance
            pointBX.keyboardAppearance = colors.keyboardAppearance
            pointBY.keyboardAppearance = colors.keyboardAppearance
			
		} else {
			/// error handling
		}
		
		
	}
    
    func updateViewWhileConnecting(_ peripheralName: String) {
        connectionButton.setTitle("Connecting", for: .normal)
        
        connectionButton.disableDiscoverability()
        
        connectionButton.isEnabled = false
        
        connectionStatusLabel.text = "Connecting..."
        
        connectedDeviceOptionsButton.setTitle(peripheralName, for: .normal)
    }
    
    func updateViewAfterConnected(_ peripheralName: String) {
        connectionButton.setTitle("Disconnect", for: .normal)
        
        connectionButton.disableDiscoverability()
        
        connectionButton.isEnabled = true
        
        connectionButton.tintColor = UIColor.red
        
        connectionStatusLabel.text = "Connected"
        
        connectedDeviceOptionsButton.setTitle(peripheralName, for: .normal)
        
        connectedDeviceOptionsButton.isHidden = false
    }
    
    func updateViewAfterDisconnected() {
        connectionButton.setTitle("Connect", for: .normal)
        
        connectionButton.enableDiscoverability(delay: 10.0, animationDuration: 1.0, repeatInterval: 4.0)
        
        connectionStatusLabel.text = "Disconnected"
        
        connectedDeviceOptionsButton.isHidden = true
    }
	
	func textViewScrollToBottom() {
		let range = NSMakeRange(NSString(string: textView.text).length - 1, 1)
		textView.scrollRangeToVisible(range)
	}
	
	
    @IBAction func manageConnection(_ sender: AnyObject) {
		
        
		
		if btSerial.connectedPeripheral == nil && messageHandler.usbMode == false {
            connectionButton.disableDiscoverability()
            /// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ This needs work
            peripheralActionSheet = UIAlertController(title: "Searching for Connections", message: "Connections appear below as they are discovered.", preferredStyle: .actionSheet)
            peripheralActionSheet?.modalPresentationStyle = UIModalPresentationStyle.popover
            
            peripheralActionSheet?.popoverPresentationController?.delegate = self
            peripheralActionSheet?.popoverPresentationController?.sourceView = self.connectionButton
            peripheralActionSheet?.popoverPresentationController?.sourceRect = CGRect(x: self.connectionButton.bounds.midX, y: self.connectionButton.bounds.maxY, width: 0, height: 0)
            
            
            
            
            if messageHandler.ptManager.isConnected {
                debugPrint("found USB")
                let usbAction = UIAlertAction(title: "USB", style: .default, handler: {(usbAction: UIAlertAction!) in
                    if messageHandler.ptManager.isConnected {
                        self.updateViewWhileConnecting("USB")
                        
                        messageHandler.connectToUSB()
                        
                    } else {
                        let alert: UIAlertController = UIAlertController(title: "USB Disconnected", message: "The USB connection disconnected since detection. Please try again.", preferredStyle: UIAlertController.Style.alert)
                        let defaultAction = UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.cancel, handler: {(alert: UIAlertAction!) in print("USB disconnected after detection")})
                        alert.addAction(defaultAction)
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                })
                peripheralActionSheet?.addAction(usbAction)
            } else {
                debugPrint("USB not found")
            }
            
            
			btSerial.startScan()
			
			Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: {_ in
				messageHandler.scanTimeOut()
			})
			
			
			if peripheralActionSheet != nil {
                self.present(peripheralActionSheet!, animated: true, completion: {
                    messageHandler.peripherals = []
                })
            }
			
            
			
		} else {
			messageHandler.disconnectUSB()
            btSerial.disconnect()
            
            updateViewAfterDisconnected()
		}
		
		
		
	}
    
    
	@IBAction func requestStatus(_ sender: Any) {
		messageHandler.requestStatusUpdate()
	}
	
	var newDeviceName: String?
	
	@IBAction func connectedDeviceOptions(_ sender: Any) {
		let deviceOptionsActionSheet = UIAlertController(title: "Device Options", message: "Select an option to change.", preferredStyle: .actionSheet)
		let deviceOptionsActionSheetCancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(alert: UIAlertAction!) in print("Foo")})
		
		// Normally this might check what could be changed, if it would vary per device.
		let nameChangeAction = UIAlertAction(title: "Change Device Name", style: .default, handler: {(alert: UIAlertAction!) in let nameChangeAlert = UIAlertController(title: "Change Device Name", message: "Enter a new device name, or cancel.", preferredStyle: .alert)
			nameChangeAlert.addTextField(configurationHandler: {(textField: UITextField!) -> Void in textField.placeholder = btSerial.connectedPeripheral?.name//************************************ This is the current name of the device.
			})
			let changeNameAction = UIAlertAction(title: "Change", style: .destructive, handler: {(changeAction: UIAlertAction!) in
				messageHandler.changePeripheralName(newName: nameChangeAlert.textFields![0].text!)
				})
			nameChangeAlert.addAction(changeNameAction)
			let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(alert: UIAlertAction!) in print("Foo")})
			nameChangeAlert.addAction(cancelAction)
			self.present(nameChangeAlert, animated: true, completion: nil)
		})
		
		deviceOptionsActionSheet.addAction(nameChangeAction)
		deviceOptionsActionSheet.addAction(deviceOptionsActionSheetCancelAction)
		self.present(deviceOptionsActionSheet, animated: true, completion: nil)
		
		
	}
	
    @IBAction func unwindToViewController(segue: UIStoryboardSegue) {
        
    }
}



extension ViewController: MessageHandlerDelegate {
    func statusDidRefresh() {
        
        let currentXValue = messageHandler.status.x
        let currentYValue = messageHandler.status.y
        let currentZValue = messageHandler.status.z
        debugPrint("statusDidRefresh()")
        debugPrint("x: ", currentXValue as Any)
        debugPrint("y: ", currentYValue as Any)
        debugPrint("z: ", currentZValue as Any)
        
        // sending next command
        if commands.count > 0 {
            
            let nextCommand = commands.removeFirst()
            
            if nextCommand is ZCommand {
                messageHandler.setNewZStatus(newZ: (nextCommand as! ZCommand).z)
            } else if nextCommand is XYCommand {
                messageHandler.setNewXYStatus(newX: (nextCommand as! XYCommand).x, newY: (nextCommand as! XYCommand).y)
            } else {
                debugPrint("ERROR: command type unrecognized: ", nextCommand)
            }
            
            refreshLivePreview()
        } else if !livePreviewSprite.isHidden {
            // updating UI
            drawingSetupActivityIndicator.stopAnimating()
            drawingProgressView.isHidden = true
            exitDrawingButton.isHidden = false
            stopDrawingButton.vanish()
        }
        
        
    }
    
    func deviceNameDidChange(_ name: String) {
        connectedDeviceOptionsButton.setTitle(name, for: .normal)
    }
    
    func messageWasReceived(_ message: String) {
        // add the received text to the textView, optionally with a line break at the end
        textView.text! += "Inbox: \(message)"
        let pref = UserDefaults.standard.integer(forKey: ReceivedMessageOptionKey)
        if pref != ReceivedMessageOption.newline.rawValue { textView.text! += "\n" }
        textViewScrollToBottom()
        
        // update UI for successful connection
        if message == "c." {
            if messageHandler.usbMode {
                updateViewAfterConnected("USB")
            } else if btSerial.isReady {
                if let peripheral = btSerial.connectedPeripheral {
                    if let peripheralName = peripheral.name {
                        updateViewAfterConnected(peripheralName)
                    }
                }
                
            }
            connectionButton.disableDiscoverability()
        }
    }
    
    func messageWasSent(_ message: String) {
        textView.text! += "Outbox: \(message)"
        let pref = UserDefaults.standard.integer(forKey: ReceivedMessageOptionKey)
        if pref != ReceivedMessageOption.newline.rawValue { textView.text! += "\n" }
        textViewScrollToBottom()
    }
    
    func peripheralDiscovered(_ isDuplicate: Bool,_ peripherals: [(peripheral: CBPeripheral, RSSI: Float)]) {
        textView.text! += "peripheralDiscovered"
        
        //tableView.reloadData()
        textView.text! += String(peripherals.count)
        
        var i = 0;
        while (i < peripherals.count) {
            let indexPath = IndexPath(row: i, section: 0)
            let peripheralAction = UIAlertAction(title: peripherals[(indexPath as IndexPath).row].peripheral.name, style: .default, handler: {(peripheralAction: UIAlertAction!)
                in
                
                //self.connectionStatusLabel.text = "Connecting..."
                
                // the user has selected a peripheral
                let peripheral = peripherals[(indexPath as IndexPath).row].peripheral
                
                
                
                if let peripheralName = peripheral.name {
                    debugPrint("found peripheral name: ", peripheralName)
                    self.updateViewWhileConnecting(peripheralName)
                } else {
                    debugPrint("ERROR: peripheral has no name. view did not update.")
                }
                
                
                
                messageHandler.connectToPeripheral(peripheral: peripheral)
                
                //self.performSegue(withIdentifier: "NewVehicleSegue", sender: self)
                
            })
            peripheralActionSheet?.addAction(peripheralAction)
            i = i + 1
        }
    }
    
    func peripheralConnectionSuccessful() {
        // this is handled by receiving a "c." message from the peripheral.
    }
    
    func peripheralConnectionFailed() {
        updateViewAfterDisconnected()
        
        
        let alert = UIAlertController(title: "Connection Failed", message: "Please try again.", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: {(alert: UIAlertAction!) in print("Foo")})
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    func peripheralConnectionReady(_ peripheral: CBPeripheral) {
        
        self.textView.text += peripheral.identifier.uuidString
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadStartViewController"), object: self)
        dismiss(animated: true, completion: nil)
    }
    
    func peripheralDidDisconnect() {
        updateViewAfterDisconnected()
        
        let alert: UIAlertController = UIAlertController(title: "Disconnected", message: "The Bluetooth device has been disconnected.", preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: {(alert: UIAlertAction!) in print("Foo")})
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func connectionDidChangeState(_ poweredOn: Bool) {
        if !poweredOn {
            let alert: UIAlertController = UIAlertController(title: "Bluetooth Off", message: "System Bluetooth settings are turned off.", preferredStyle: UIAlertControllerStyle.alert)
            let defaultAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: {(alert: UIAlertAction!) in print("Foo")})
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func usbDidConnect() {
        debugPrint("usbDidConnect() in ViewController")
        let usbAction = UIAlertAction(title: "USB", style: .default, handler: {(usbAction: UIAlertAction!)
            in
            
            if messageHandler.ptManager.isConnected {
                self.updateViewWhileConnecting("USB")
                
                
                messageHandler.connectToUSB()
                
            } else {
                let alert: UIAlertController = UIAlertController(title: "USB Disconnected", message: "The USB connection disconnected since detection. Please try again.", preferredStyle: UIAlertController.Style.alert)
                let defaultAction = UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.cancel, handler: {(alert: UIAlertAction!) in print("USB disconnected after detection")})
                alert.addAction(defaultAction)
                self.present(alert, animated: true, completion: nil)
                
            }
            // the user has selected a peripheral
            
            
            //self.performSegue(withIdentifier: "NewVehicleSegue", sender: self)
            
        })
        peripheralActionSheet?.addAction(usbAction)
    }
    
    func usbDidDisconnect() {
        debugPrint("usbDidDisconnect() in ViewController")
        
        // handle case of USB disconnecting while "connected"
        if messageHandler.usbMode == true {
            updateViewAfterDisconnected()
            
            let disconnectionAlertAction = UIAlertAction(title: "Dismiss", style: .default) { (disconnectionAlert) in
                debugPrint("ACTION: User dismissed USB disconnection alert.")
                messageHandler.disconnectUSB()
            }
            let disconnectionAlertController = UIAlertController(title: "USB Disconnected", message: "The USB connection disconnected unexpectedly.", preferredStyle: .alert)
            
            disconnectionAlertController.addAction(disconnectionAlertAction)
            
            self.present(disconnectionAlertController, animated: true, completion: nil)
        }
    }
}


extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == pointAX || textField == pointAY || textField == pointBX || textField == pointBY {
            previewLine(self)
            //textField.resignFirstResponder()
            return false
        }
        return true
    }
}

extension ViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: {_ in
            if btSerial.connectedPeripheral == nil && messageHandler.usbMode == false {
                self.connectionButton.enableDiscoverability(delay: 5.0, animationDuration: 1.0, repeatInterval: 4.0)
            }
        })
        
        
    }
}
