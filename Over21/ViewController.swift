//
//  ViewController.swift
//  Over21
//
//  Created by Chrishon Wyllie on 9/28/18.
//  Copyright © 2018 Socket Mobile. All rights reserved.
//

import UIKit
import SKTCapture

class ViewController: UIViewController {
    
    // MARK: - Variables
    
    var capture = CaptureHelper.sharedInstance
    
    var map: [String: String] = [:]
    
    var dateFormatter = DateFormatter()
    
    let calendar = Calendar.current
    
    // Some devices do not support the notification: scanButtonRelease
    // If setting this notification fails, this Boolean will svae the state
    private var buttonReleaseIsSupported: Bool = true
    private var animationTimer: Timer?
    
    
    
    // MARK: - UI Elements
    
    private var ageIndicatorView: AgeIndicatorView = {
        let v = AgeIndicatorView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupCapture()
        
        setupUIElements()
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
    
    private func setupUIElements() {
        view.addSubview(ageIndicatorView)
        ageIndicatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        ageIndicatorView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        ageIndicatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        ageIndicatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        
        dateFormatter.dateFormat = "MMddyyyy"
    }
}

extension ViewController: CaptureHelperDeviceManagerPresenceDelegate {
    
    func didNotifyArrivalForDeviceManager(_ device: CaptureHelperDeviceManager, withResult result: SKTResult) {
        print("device manager has arrived")
    }
    
    func didNotifyRemovalForDeviceManager(_ device: CaptureHelperDeviceManager, withResult result: SKTResult) {
        print("device manager removed")
    }
}


extension ViewController: CaptureHelperDevicePresenceDelegate {
    
    func didNotifyArrivalForDevice(_ device: CaptureHelperDevice, withResult result: SKTResult) {
        print("scanner arrived")
        ageIndicatorView.updateScannerConnection(isConnected: true)
        
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
    
    func didNotifyRemovalForDevice(_ device: CaptureHelperDevice, withResult result: SKTResult) {
        print("scanner removed")
        ageIndicatorView.updateScannerConnection(isConnected: false)
    }
}

extension ViewController: CaptureHelperDeviceButtonsDelegate {
    func didChangeButtonsState(_ buttonsState: SKTCaptureButtonsState, forDevice device: CaptureHelperDevice) {
        print("button state changed: \(buttonsState) for device: \(device)\n")
        
        if buttonReleaseIsSupported == false {
            if buttonsState == .middle {
                resetAnimationTimer()
                ageIndicatorView.reset()
                ageIndicatorView.updateUserInterface(isScanning: true)
                return
            }
        } else {
            if buttonsState == .middle {
                ageIndicatorView.reset()
                ageIndicatorView.updateUserInterface(isScanning: true)
            } else {
                ageIndicatorView.updateUserInterface(isScanning: false)
            }
        }
       
    }
    
    private func resetAnimationTimer() {
        animationTimer?.invalidate()
        let delayBeforeResettingAnimation: TimeInterval = 5
        // After 5 seconds, the "Scanning" animation will stop
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
            
            if let data = decodedData?.stringFromDecodedData() {
                
                //print("decoded data: \(data)")
                
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
                
                checkIfUserIsOver21()
                
                //test()
            }
        }
    }
    
    private func checkIfUserIsOver21() {
        if let dateOfBirth = map["DBB"], let expiryDate = map["DBA"] {
            if let cardExpiryDate = dateFormatter.date(from: expiryDate) {
                
                let currentDate = Date()
                
                guard let dateOfBirth = dateFormatter.date(from: dateOfBirth) else { return }
                
                let components = calendar.dateComponents([.month, .year, .day], from: dateOfBirth, to: currentDate)
                
                guard
                    let years = components.year,
                    let months = components.month,
                    let days = components.day
                    else { return }
                
                let age = Age(birthday: dateOfBirth, years: years, months: months, days: days)
                
                ageIndicatorView.updateViews(with: age, and: cardExpiryDate)
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
        //print("test date of expiry: \(testExpiryDate)")
        
        ageIndicatorView.updateViews(with: testAge, and: testExpiryDate)
    }
    
}

