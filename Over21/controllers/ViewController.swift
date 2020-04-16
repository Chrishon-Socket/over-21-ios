//
//  ViewController.swift
//  Over21
//
//  Created by Chrishon Wyllie on 9/28/18.
//  Copyright © 2018 Socket Mobile. All rights reserved.
//

import UIKit
import SKTCapture

protocol ContainerDelegate: class {
    func didScan()
    func deviceConnectionStatusChanged(isConnected: Bool)
}

class ViewController: UIViewController {
    
    // MARK: - Variables
    
    var capture = CaptureHelper.sharedInstance
    
    var map: [String: String] = [:]
    
    var dateFormatter = DateFormatter()
    let shortDateFormatter = DateFormatter()
    let calendar = Calendar.current
    
    // Some devices do not support the notification: scanButtonRelease
    // If setting this notification fails, this Boolean will save the state
    private var buttonReleaseIsSupported: Bool = true
    private var animationTimer: Timer?
    
    public weak var delegate: ContainerDelegate?
    
    
    //Printer variables
    private var printerCon: UPOSPrinterController?
    private var printerList: UPOSPrinters?
    private var printerDevice: UPOSPrinter?
    
    // MARK: - UI Elements
    
    private var appVersionLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.text = "version"
        lbl.textColor = UIColor.lightGray
        lbl.textAlignment = .center
        return lbl
    }()
    
    private var ageIndicatorView: AgeIndicatorView = {
        let v = AgeIndicatorView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    public var ageLimitSelectionView: AgeLimitSelectionView = {
        let v = AgeLimitSelectionView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 7
        v.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        v.layer.borderWidth = 0.5
        v.clipsToBounds = true
        return v
    }()
    
    private var notificationsView: NotificationsView = {
        let v = NotificationsView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        return v
    }()
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupCapture()
        
        setupUIElements()
        initUPOS()
        btLookup()
    }
    
    private func setupCapture() {
        let AppInfo = SKTAppInfo();
        AppInfo.appKey = "MC0CFG6XvIijqYms9BwonSNZ85ATqotZAhUA+Rb+Paoxq3FdjFAu/ciXvOobatw=";
        AppInfo.appID = "ios:com.socketmobile.Over21";
        AppInfo.developerID = "bb57d8e1-f911-47ba-b510-693be162686a";
        
        
        // open Capture Helper only once in the application
        capture.dispatchQueue = DispatchQueue.main
        capture.pushDelegate(self)
        capture.openWithAppInfo(AppInfo) { (result) in
            print("Result of Capture initialization: \(result.rawValue)")
        }
    }
    
    private func setupUIElements() {
        view.backgroundColor = .white
        view.addSubview(ageIndicatorView)
        view.addSubview(ageLimitSelectionView)
        
        view.addSubview(appVersionLabel)
        view.addSubview(notificationsView)
        
        ageIndicatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        ageIndicatorView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        ageIndicatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        ageIndicatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        appVersionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -48).isActive = true
        appVersionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        appVersionLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        appVersionLabel.text = getAppVersion()
        
        ageLimitSelectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        ageLimitSelectionView.topAnchor.constraint(equalTo: ageIndicatorView.scannerConnectionLabel.bottomAnchor, constant: 12).isActive = true
        ageLimitSelectionView.widthAnchor.constraint(equalToConstant: 160.0).isActive = true
        
        notificationsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        notificationsView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        notificationsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        notificationsView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        dateFormatter.dateFormat = "MMddyyyy"
        shortDateFormatter.dateFormat = "yyMMdd"
    }
    
    private func getAppVersion() -> String {
        let kVersion = "CFBundleShortVersionString"
        
        if let dictionary = Bundle.main.infoDictionary {
            guard let version = dictionary[kVersion] as? String else {
                return "--"
            }
            return "\(version)"
        }
        return ""
    }
}

extension ViewController: CaptureHelperDevicePresenceDelegate {
    
    func didNotifyArrivalForDevice(_ device: CaptureHelperDevice, withResult result: SKTResult) {
        print("scanner arrived")
        
        delegate?.deviceConnectionStatusChanged(isConnected: true)
        
        ageIndicatorView.updateScannerConnection(isConnected: true)
        
        device.dispatchQueue = DispatchQueue.main
        
        getDataSource(with: device) { [weak self] (result) in
            guard let strongSelf = self else { return }
            
            if result == SKTResult.E_NOTSUPPORTED {
                strongSelf.notificationsView.setMessage(to: "This scanner is not able to scan the driver license barcode (PDF417)")
                strongSelf.notificationsView.animate(shouldShow: true)
            } else if result == SKTResult.E_NOERROR {
                strongSelf.setScanButtonNotifications(with: device)
            }
        }
    
    }
    
    func didNotifyRemovalForDevice(_ device: CaptureHelperDevice, withResult result: SKTResult) {
        print("scanner removed")
        delegate?.deviceConnectionStatusChanged(isConnected: false)
        ageIndicatorView.updateScannerConnection(isConnected: false)
        ageIndicatorView.reset()
        notificationsView.reset()
    }
    
    private func getDataSource(with device: CaptureHelperDevice, completionHandler: @escaping (_ result: SKTResult) -> ()) {
        
        device.getDataSourceInfoFromId(SKTCaptureDataSourceID.symbologyPdf417) { (result, captureDataSource) in
    
            if (result == SKTResult.E_NOERROR) && (captureDataSource?.status == SKTCaptureDataSourceStatus.disable) {
                
                guard let captureDataSource = captureDataSource else {
                    // Result == No_Error, but SKTCaptureDataSource is nil. Possible issue with Capture?
                    return
                }
                
                // Enable PDF417, then send result to completion handler
                captureDataSource.status = .enable
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
}

extension ViewController: CaptureHelperDeviceButtonsDelegate {
    func didChangeButtonsState(_ buttonsState: SKTCaptureButtonsState, forDevice device: CaptureHelperDevice) {
        print("button state changed: \(buttonsState) for device: \(device)\n")
        
        if buttonReleaseIsSupported == false {
            if buttonsState == .middle {
                notificationsView.reset()
                resetAnimationTimer()
                ageIndicatorView.reset()
                ageIndicatorView.updateUserInterface(isScanning: true)
                return
            }
        } else {
            if buttonsState == .middle {
                notificationsView.reset()
                ageIndicatorView.reset()
                ageIndicatorView.updateUserInterface(isScanning: true)
            } else {
                ageIndicatorView.updateUserInterface(isScanning: false)
            }
        }
       
    }
    
    private func resetAnimationTimer() {
        animationTimer?.invalidate()
        let delayBeforeResettingAnimation: TimeInterval = 3
        // After 3 seconds, the "Scanning" animation will stop.
        // This is about the same duration as the scanner's trigger timeout for the light/laser
        animationTimer = Timer.scheduledTimer(timeInterval: delayBeforeResettingAnimation, target: self, selector: #selector(stopScanningAnimation), userInfo: nil, repeats: false)
    }
    
    @objc private func stopScanningAnimation() {
        ageIndicatorView.reset()
        ageIndicatorView.updateUserInterface(isScanning: false)
    }
}



extension ViewController: CaptureHelperDeviceDecodedDataDelegate {
    
    func didReceiveDecodedData(_ decodedData: SKTCaptureDecodedData?, fromDevice device: CaptureHelperDevice, withResult result: SKTResult) {
        if result == SKTCaptureErrors.E_NOERROR {
            
            delegate?.didScan()
            
            // Stop the timer for devices that do not support scanButtonRelease
            if buttonReleaseIsSupported == false {
                animationTimer?.invalidate()
            }

            
            if let data = decodedData?.stringFromDecodedData() {
                parseDecodedBarCode(data)
                
                checkIfUserIsOver21()
                
                //test()
            }
        }
    }
    
    private func parseDriverLicense(_ data: String) {
        let words = data.components(separatedBy: "\n")
        
        for word in words {
            //print("word: \(word)")
            let offset: Int = 3
            
            guard word.count > offset else { continue }
            
            let upperIndex = word.index(word.startIndex, offsetBy: offset - 1)
            
            let dataType = String(word[...upperIndex])
            
            let lowerIndex = word.index(word.startIndex, offsetBy: offset)
            let dataFromWord = String(word[lowerIndex...])
            
            map[dataType] = dataFromWord
            
            print("\(dataType) - \(dataFromWord)")
        }
    }
    private func parseTravelID(_ data: String) {
        let trimmedData = data.replacingOccurrences(of: "\n", with: "")
        if trimmedData.count == 90 {
            let dateOfBirth = String(trimmedData[trimmedData.index(trimmedData.startIndex, offsetBy: 30)..<trimmedData.index(trimmedData.startIndex, offsetBy: 36)])
            let expiryDate = String(trimmedData[trimmedData.index(trimmedData.startIndex, offsetBy: 38)..<trimmedData.index(trimmedData.startIndex, offsetBy: 44)])
            let name = String(trimmedData[trimmedData.index(trimmedData.startIndex, offsetBy: 60)..<trimmedData.index(trimmedData.startIndex, offsetBy: 90)])
            
            let surnameEndIndex = name.range(of: "<<")
            let surname = String(name.prefix(surnameEndIndex?.lowerBound.encodedOffset ?? 0))
            let givenname = String(name.suffix(30 - (surnameEndIndex?.upperBound.encodedOffset ?? 1) + 1)).replacingOccurrences(of: "<", with: " ").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            map["DBB"] = dateOfBirth
            map["DBA"] = expiryDate
            map["DAB"] = surname
            map["DAC"] = givenname
        } else {
            notificationsView.setMessage(to: "Scanned wrong barcode.")
            notificationsView.animate(shouldShow: true)
        }
    }
    private func parseDecodedBarCode(_ data: String) {
        if data.starts(with: "@") {
            parseDriverLicense(data)
        } else {
            parseTravelID(data)
        }
    }
    private func checkIfUserIsOver21() {
        if let dateOfBirth = map["DBB"], let expiryDate = map["DBA"] {
            var expiryDateObj: Date?
            var dateOfBirthObj: Date?
            if dateOfBirth.count == 6 {
                dateOfBirthObj = shortDateFormatter.date(from: dateOfBirth)
                expiryDateObj =  shortDateFormatter.date(from: expiryDate)
            } else {
                dateOfBirthObj = dateFormatter.date(from: dateOfBirth)
                expiryDateObj =  dateFormatter.date(from: expiryDate)
            }
            if dateOfBirthObj != nil && expiryDateObj != nil {
                let currentDate = Date()
                let components = calendar.dateComponents([.month, .year, .day], from: dateOfBirthObj!, to: currentDate)
                
                guard
                    let years = components.year,
                    let months = components.month,
                    let days = components.day
                    else { return }
                
                let age = Age(birthday: dateOfBirthObj!, years: years, months: months, days: days)
                
                ageIndicatorView.updateViews(with: age, and: expiryDateObj!)
                
                if age.years >= AgeLimitSelectionView.ageLimitThreshhold {
                    printData()
                }
            }
        }
    }
    
    private func test() {
        
        let currentDate = Date()
        
        let birthMonth = Int.random(in: 8...10)
        let birthDay = Int.random(in: 1...30)
        let birthYear = Int.random(in: 1997...1999)
        
        let formattedMonthAsString = (birthMonth < 10) ? "0\(birthMonth)" : "\(birthMonth)"
        let formattedDayAsString = (birthDay < 10) ? "0\(birthDay)" : "\(birthDay)"
        
        let testDOB = "\(formattedMonthAsString)\(formattedDayAsString)\(birthYear)"
        
        let testDate = dateFormatter.date(from: testDOB)!
        //print("test date of birth: \(testDate)")
        
        let testComponents = calendar.dateComponents([.month, .year, .day], from: testDate, to: currentDate)
        let testAge = Age(birthday: testDate, years: testComponents.year!, months: testComponents.month!, days: testComponents.day!)
        
        
        
        
        let expiryMonth = Int.random(in: 8...11)
        let expiryDay = Int.random(in: 1...30)
        let expiryYear = Int.random(in: 2018...2019)
        let formattedExpiryMonthAsString = (expiryMonth < 10) ? "0\(expiryMonth)" : "\(expiryMonth)"
        let formattedExpiryDayAsString = (expiryDay < 10) ? "0\(expiryDay)" : "\(expiryDay)"
        
        let testExpiryDateString = "\(formattedExpiryMonthAsString)\(formattedExpiryDayAsString)\(expiryYear)"
        
        let testExpiryDate = dateFormatter.date(from: testExpiryDateString)!
        
        ageIndicatorView.updateViews(with: testAge, and: testExpiryDate)
    }
    
}

extension ViewController: UPOSDeviceControlDelegate {
    
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
            notificationsView.setMessage(to: "Cannot connect to printer. Reason: " + (UPOS_ERROR_STRINGS[result!] ?? UPOS_UNKOWN_ERROR_STRING))
            notificationsView.animate(shouldShow: true)
            return
        }
        
        result = printerCon?.claim(5000)
        if result == nil || result != 0 {
            notificationsView.setMessage(to: "Cannot connect to printer. Reason: " + (UPOS_ERROR_STRINGS[result!] ?? UPOS_UNKOWN_ERROR_STRING))
            notificationsView.animate(shouldShow: true)
            return
        }
        
        Thread.sleep(forTimeInterval: 0.1)
        printerCon?.deviceEnabled = true
        ageIndicatorView.updatePrinterConnection(isConnected: true)
    }
    
    func disconnect() {
        printerCon?.deviceEnabled = false
        let result = printerCon?.releaseDevice()
        
        if result == nil || result != 0 {
            return
        }
        
        Thread.sleep(forTimeInterval: 0.1)
        printerCon?.close()
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
        printerCon?.printBarcode(Int(__UPOS_PRINTER_STATION.PTR_S_RECEIPT.rawValue), data: data, symbology: PTR_BCS_EAN13, height: 60, width: 200, alignment: PTR_BC_CENTER, textPostion: PTR_BC_TEXT_BELOW)
    }
}
