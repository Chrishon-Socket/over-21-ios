//
//  MainViewController.swift
//  Over21
//
//  Created by gold on 2019/3/6.
//  Copyright © 2019 Socket Mobile. All rights reserved.
//

import UIKit
import SKTCapture

class MainViewController: UIViewController, CaptureHelperDevicePresenceDelegate, CaptureHelperDeviceButtonsDelegate {
    
    var capture = CaptureHelper.sharedInstance
    
    private var buttonReleaseIsSupported: Bool = true
    private var animationTimer: Timer?
    
    var map: [String: String] = [:]
    
    //Printer variables
    private var printerCon: UPOSPrinterController?
    private var printerList: UPOSPrinters?
    private var printerDevice: UPOSPrinter?
    
    @IBOutlet weak var docTypeSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var printerLabel: UILabel!
    @IBOutlet weak var scannerLabel: UILabel!
    @IBOutlet weak var ageLimitSegmentedControl: UISegmentedControl!
    @IBOutlet weak var resultView: ResultView!
    @IBOutlet weak var expiryLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).numberOfLines = 0
        
        setupCapture()
        initUPOS()
        btLookup()
        
        updatePrinterConnection(false)
        updateScannerConnection(nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //map = parseDoc("DBB01011980\nDBA12312050\nDACABC", TYPE_DRIVER_LICENSE_INDEX, SKTCaptureDataSourceID.symbologyPdf417) ?? [:]
        //map = parseDoc("P<UT0ERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<\nL898902C36UT07408122F1904159ZE184226B<<<<<10", TYPE_PASSPORT_INDEX, SKTCaptureDataSourceID.symbologyPdf417) ?? [:]
        //map = parseDoc("C1USA0427797024MSC1380273242\n<<6010014M2405193IRL<<<<<<<<<<<4MILLS<<KEVIN<JAMES<<<<<<<<<<<<", TYPE_TRAVEL_ID_INDEX, SKTCaptureDataSourceID.symbologyPdf417) ?? [:]

        //checkIfUserIsOver21()
    }
    @IBAction func onDocTypeChanged(_ sender: Any) {
        for device in capture.getDevices() {
            configScanner(device)
        }
    }
    func didNotifyArrivalForDevice(_ device: CaptureHelperDevice, withResult result: SKTResult) {
        print("scanner arrived")
        updateScannerConnection(device.deviceInfo.name)
        
        device.dispatchQueue = DispatchQueue.main
        
        configScanner(device)
    }
    
    func didNotifyRemovalForDevice(_ device: CaptureHelperDevice, withResult result: SKTResult) {
        print("scanner removed")
        updateScannerConnection(nil)
        resultView.reset()
    }
    
    func didChangeButtonsState(_ buttonsState: SKTCaptureButtonsState, forDevice device: CaptureHelperDevice) {
        print("button state changed: \(buttonsState) for device: \(device)\n")
        
        if buttonReleaseIsSupported == false {
            if buttonsState == .middle {
                resetAnimationTimer()
                resultView.reset()
                updateScanning(true)
                return
            }
        } else {
            if buttonsState == .middle {
                resultView.reset()
                updateScanning(true)
            } else {
                updateScanning(false)
            }
        }
    }
    
    
    func didReceiveDecodedData(_ decodedData: SKTCaptureDecodedData?, fromDevice device: CaptureHelperDevice, withResult result: SKTResult) {
        if result == SKTCaptureErrors.E_NOERROR {
            
            // Stop the timer for devices that do not support scanButtonRelease
            if buttonReleaseIsSupported == false {
                animationTimer?.invalidate()
            }
            map = parseDoc(decodedData, docTypeSegmentedControl.selectedSegmentIndex)
            checkIfUserIsOver21()
        }
    }
    
    private func checkIfUserIsOver21() {
        if let dateOfBirth = map["DBB"], let expiryDate = map["DBA"] {
            var expiryDateObj: Date?
            var dateOfBirthObj: Date?
            if dateOfBirth.count == 6 {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyMMdd"
                
                dateOfBirthObj = dateFormatter.date(from: dateOfBirth)
                expiryDateObj =  dateFormatter.date(from: expiryDate)
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMddyyyy"
                
                dateOfBirthObj = dateFormatter.date(from: dateOfBirth)
                expiryDateObj =  dateFormatter.date(from: expiryDate)
            }
            if dateOfBirthObj != nil && expiryDateObj != nil {
                let currentDate = Date()
                let components = Calendar.current.dateComponents([.month, .year, .day], from: dateOfBirthObj!, to: currentDate)
                
                guard
                    let years = components.year,
                    let months = components.month,
                    let days = components.day
                    else { return }
                
                let age = Age(birthday: dateOfBirthObj!, years: years, months: months, days: days)
                
                updateScannedResult(with: age, and: expiryDateObj!)
                
                if age.years >= AgeLimitSelectionView.ageLimitThreshhold {
                    printData()
                }
            } else {
                showWrongBarCode()
            }
        } else {
            showWrongBarCode()
        }
    }
    private func configScanner(_ device: CaptureHelperDevice) {
        if docTypeSegmentedControl.selectedSegmentIndex == TYPE_DRIVER_LICENSE_INDEX {
            configScannerForDriverLicense(device)
        } else if docTypeSegmentedControl.selectedSegmentIndex == TYPE_PASSPORT_INDEX {
            configScannerForPassport(device)
        } else if docTypeSegmentedControl.selectedSegmentIndex == TYPE_TRAVEL_ID_INDEX {
            configScannerForTravelID(device)
        }
    }
    private func configScannerForPassport(_ device: CaptureHelperDevice) {
        let commandArray: [[UInt8]] = [
            [0x08, 0xC6, 0x04, 0x00, 0xFF, 0xF1, 0xA9, 0x01],
            [0x08, 0xC6, 0x04, 0x00, 0xFF, 0xF1, 0xAD, 0x04]
        ]
        sendCommand(device, withCommandList: commandArray) { (result, data) in
            if result != SKTResult.E_NOERROR {
                self.showNotification("Error on config scanner for Passport.")
            }
        }
    }
    private func configScannerForTravelID(_ device: CaptureHelperDevice) {
        let commandArray: [[UInt8]] = [
            [0x08, 0xC6, 0x04, 0x00, 0xFF, 0xF1, 0xA9, 0x01],
            [0x08, 0xC6, 0x04, 0x00, 0xFF, 0xF1, 0xAD, 0x14]
        ]
        sendCommand(device, withCommandList: commandArray) { (result, data) in
            if result != SKTResult.E_NOERROR {
                self.showNotification("Error on config scanner for Travel ID.")
            }
        }
    }
    private func configScannerForDriverLicense(_ device: CaptureHelperDevice) {
        self.getDataSource(with: device) { [weak self] (result) in
            guard let strongSelf = self else { return }
            
            if result == SKTResult.E_NOTSUPPORTED {
                strongSelf.showNotification("This scanner is not able to scan the driver license barcode (PDF417)")
            } else if result == SKTResult.E_NOERROR {
                strongSelf.setScanButtonNotifications(with: device)
            }
        }
    }
    private func sendCommand(_ device: CaptureHelperDevice, withCommandList commandList: [[UInt8]], withCompletionHandler completion: @escaping(_ result: SKTResult, _ commandResult: Data?)->Void) {
        if commandList.count > 0 {
            let command = commandList[0]
            device.getDeviceSpecificCommand(Data(command)) { (result, data) in
                if result != SKTResult.E_NOERROR || commandList.count == 1 {
                    completion(result, data)
                } else {
                    let remaining = Array(commandList[1...commandList.count])
                    self.sendCommand(device, withCommandList: remaining, withCompletionHandler: completion)
                }
            }
        }
    }
    private func getDataSource(with device: CaptureHelperDevice, completionHandler: @escaping (_ result: SKTResult) -> ()) {
        device.getDataSourceInfoFromId(SKTCaptureDataSourceID.symbologyPdf417) { (result, captureDataSource) in
            
            if (result == SKTResult.E_NOERROR) && (captureDataSource?.status == SKTCaptureDataSourceStatus.disabled) {
                
                guard let captureDataSource = captureDataSource else {
                    // Result == No_Error, but SKTCaptureDataSource is nil. Possible issue with Capture?
                    return
                }
                
                // Enable PDF417, then send result to completion handler
                captureDataSource.status = .enabled
                device.setDataSourceInfo(captureDataSource, withCompletionHandler: { (result) in
                    if result != SKTResult.E_NOERROR {
                        print("Error setting DataSource symbology. Result: \(result)")
                    }
                    completionHandler(result)
                })
            } else {
                // Return completionHandler in any other case.
                completionHandler(result)
            }
        }
    }
    
    private func setScanButtonNotifications(with device: CaptureHelperDevice) {
        device.getNotificationsWithCompletionHandler { (result, notifications) in
            if let notifications = notifications {
                if notifications.contains([SKTCaptureNotifications.scanButtonPress, SKTCaptureNotifications.scanButtonRelease]) {
                    // Do nothing. These notifications are already set.
                } else {
                    
                    // These notifications have not been set. Set them now
                    
                    device.setNotifications([SKTCaptureNotifications.scanButtonPress, SKTCaptureNotifications.scanButtonRelease], withCompletionHandler: { (result) in
                        if result == SKTResult.E_NOTSUPPORTED {
                            // Older devices such as the D740 do not support scanButtonRelease. So just set the scanButtonPress
                            
                            device.setNotifications(SKTCaptureNotifications.scanButtonPress, withCompletionHandler: { [weak self] (result) in
                                if result != SKTResult.E_NOERROR {
                                    print("Error setting notifications for device. Result: \(result)")
                                    return
                                }
                                guard let strongSelf = self else { return }
                                strongSelf.buttonReleaseIsSupported = false
                            })
                            
                        } else {
                            // This device DOES support scanButtonRelease. No further action required.
                        }
                    })
                }
            }
        }
    }
    
    public func updateScannedResult(with age: Age, and cardExpiryDate: Date) {
        resultView.reset()
        
        // If the expiryDate is before (less than) the current date, it is expired
        let isExpired: Bool = cardExpiryDate < Date()
        if age.isOldEnoughToEnter() && isExpired == false {
            resultView.set(result: .success, withAgeThreshold: AgeLimitSelectionView.ageLimitThreshhold)
        } else if age.isOldEnoughToEnter() && isExpired == true {
            resultView.set(result: .failure, withAgeThreshold: AgeLimitSelectionView.ageLimitThreshhold)
            //extraInformationLabel.text = "This person is old enough to enter but has an expired ID"
        } else {
            let dateComponents = age.timeUntil21YearsOld()
            
            if dateComponents.year == 0, dateComponents.month == 0 {
                if let days = dateComponents.day, days <= 10 {
                    // This person is within 10 days of 21 years old
                    //extraInformationLabel.text = "This person is within 10 days of turning 21"
                }
            }
            
            resultView.set(result: .failure, withAgeThreshold: AgeLimitSelectionView.ageLimitThreshhold)
        }
        
        expiryLabel.text = isExpired ? "Expired" : "NOT Expired"
        //expiryIndicatorView.backgroundColor = isExpired ? noEntryAllowedColor : entryAllowedColor
    }
    
    private func resetAnimationTimer() {
        animationTimer?.invalidate()
        let delayBeforeResettingAnimation: TimeInterval = 3
        // After 3 seconds, the "Scanning" animation will stop.
        // This is about the same duration as the scanner's trigger timeout for the light/laser
        animationTimer = Timer.scheduledTimer(timeInterval: delayBeforeResettingAnimation, target: self, selector: #selector(stopScanningAnimation), userInfo: nil, repeats: false)
    }
    
    @objc private func stopScanningAnimation() {
        resultView.reset()
        updateScanning(false)
    }
    
    private func updateScannerConnection(_ deviceName: String?) {
        if deviceName == nil {
            scannerLabel.text = "No Scanner Connected."
        } else {
            scannerLabel.text = deviceName
        }
    }
    
    private func updatePrinterConnection(_ connected: Bool) {
        if connected {
            printerLabel.text = "Printer Connected."
        } else {
            printerLabel.text = "No Printer Connected."
        }
    }
    
    private func updateScanning(_ isScanning: Bool) {
        if isScanning {
            resultView.startPulsingAnimation()
        } else {
            resultView.stopPulsingAnimation()
        }
    }
    
    private func setupCapture() {
        let AppInfo = SKTAppInfo();
        AppInfo.appKey = "MC0CFG6XvIijqYms9BwonSNZ85ATqotZAhUA+Rb+Paoxq3FdjFAu/ciXvOobatw=";
        AppInfo.appID = "ios:com.socketmobile.Over21";
        AppInfo.developerID = "bb57d8e1-f911-47ba-b510-693be162686a";
        
        // open Capture Helper only once in the application
        capture.delegateDispatchQueue = DispatchQueue.main
        capture.pushDelegate(self)
        capture.openWithAppInfo(AppInfo) { (result) in
            print("Result of Capture initialization: \(result.rawValue)")
        }
    }
    
    private func showWrongBarCode() {
        showNotification("Wrong barcode scanned.")
    }
    private func showNotification(_ message: String) {
        let alertController = UIAlertController(title: "Notification", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

extension MainViewController: UPOSDeviceControlDelegate {
    
    func initUPOS() {
        printerCon = UPOSPrinterController()
        printerList = UPOSPrinters()
        
        //printerCon?.setLogLevel(LOG_SHOW_NEVER)
        printerCon?.delegate = self
        printerCon?.setTextEncoding(String.Encoding.ascii.rawValue)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBTDeviceList(notification:)), name: NSNotification.Name(rawValue: __NOTIFICATION_NAME_BT_FOUND_PRINTER_), object: nil)
    }
    
    func btLookup() {
        printerCon?.refreshBTLookup()
    }
    
    @objc func didBTDeviceList(notification: NSNotification) {
        if let _ = notification.userInfo {
            if let lookupDevice = notification.userInfo?[__NOTIFICATION_NAME_BT_FOUND_PRINTER_] as! UPOSPrinter? {
                printerList?.addDevice(lookupDevice)
                printerList?.save()
                connect()
            }
        }
    }
    
    // function of UPOSDeviceControlDelegate.
    // it's called from Bixilon library.
    func statusUpdateEvent(_ status: NSNumber!) {
        
    }
    
    func connect() {
        let target = printerList?.getList()?.last as? UPOSPrinter
        if target == nil {
            return
        }
        
        printerDevice = target
        
        var result = printerCon?.open(target?.modelName)
        if result == nil || result! != 0 {
            showNotification("Cannot connect to printer. Reason: \(UPOS_ERROR_STRINGS[result!] ?? UPOS_UNKOWN_ERROR_STRING)")
            return
        }
        
        result = printerCon?.claim(5000)
        if result == nil || result != 0 {
            showNotification("Cannot connect to printer. Reason: \(UPOS_ERROR_STRINGS[result!] ?? UPOS_UNKOWN_ERROR_STRING)")
            return
        }
        
        Thread.sleep(forTimeInterval: 0.1)
        printerCon?.deviceEnabled = true
        updatePrinterConnection(true)
    }
    
    func disconnect() {
        printerCon?.deviceEnabled = false
        let result = printerCon?.releaseDevice()
        
        if result == nil || result != 0 {
            return
        }
        
        Thread.sleep(forTimeInterval: 0.1)
        printerCon?.close()
        updatePrinterConnection(false)
    }
    
    func printData() {
        let givenName = map["DAC"] ?? ""
        printToPrinter(data: "Age verified\n\n")
        printToPrinter(data: "Hi \(givenName),\n" )
        printToPrinter(data: "Please enjoy your 10% off\ncoupon for your\ndrink.\n\n")
        printBarCodeToPrinter(data: "1234567890123")
        printToPrinter(data: "\n\n\n\n\n")
        printToPrinter(data: "\u{1B}")
    }
    
    func printToPrinter(data: String) {
        print(data)
        printerCon?.printNormal(Int(__UPOS_PRINTER_STATION.PTR_S_RECEIPT.rawValue), data: data)
    }
    
    func printBarCodeToPrinter(data: String) {
        print(data)
        printerCon?.printBarcode(Int(__UPOS_PRINTER_STATION.PTR_S_RECEIPT.rawValue), data: data, symbology: PTR_BCS_PDF417, height: 75, width: 200, alignment: PTR_BC_CENTER, textPostion: PTR_BC_TEXT_BELOW)
    }
}
