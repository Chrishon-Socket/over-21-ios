//
//  AgeIndicatorView.swift
//  Over21
//
//  Created by Chrishon Wyllie on 9/28/18.
//  Copyright © 2018 Socket Mobile. All rights reserved.
//

import UIKit

let noEntryAllowedColor = UIColor(red: 251/255, green: 119/255, blue: 119/255, alpha: 1.0)
let entryMAYBEAllowedColor = UIColor(red: 119/255, green: 183/255, blue: 251/255, alpha: 1.0)
let entryAllowedColor = UIColor(red: 120/255, green: 240/255, blue: 151/255, alpha: 1.0)

class AgeIndicatorView: UIView {
    
    // MARK: - UI Elements
    
    private var scanComplete: Bool = false
    
    
    
    public var scannerConnectionLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.medium)
        lbl.text = "No Scanner Connected"
        lbl.textColor = UIColor.darkGray
        lbl.textAlignment = .center
        lbl.layer.cornerRadius = 10
        
        return lbl
    }()
    public var printerConnectionLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.medium)
        lbl.text = "No Printer Connected"
        lbl.textColor = UIColor.darkGray
        lbl.textAlignment = .center
        lbl.layer.cornerRadius = 10
        
        return lbl
    }()
    
    private var extraInformationLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 17)
        lbl.text = ""
        lbl.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()
    
    // - - - - - - -
    
    private var resultView: ResultView = {
        let v = ResultView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.clipsToBounds = true
        v.layer.masksToBounds = true
        return v
    }()
    
    // - - - - - - -
    
    private var expiryLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 24)
        lbl.text = "------"
        lbl.textColor = UIColor.darkGray
        lbl.textAlignment = .center
        return lbl
    }()

    private var expiryIndicatorView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.clipsToBounds = true
        v.layer.cornerRadius = 10
        
        v.layer.masksToBounds = false
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.5
        v.layer.shadowOffset = CGSize(width: 2, height: 2)
        v.layer.shadowRadius = 1
        
        return v
    }()
    
    
    
    
    
    
    
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUIElements()
    }
    
    init() {
        super.init(frame: .zero)
        setupUIElements()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    // MARK: - Functions
    
    private func setupUIElements() {
        
        let resultViewDimension: CGFloat = 200.0
        let expiryIndicatorViewHeight: CGFloat = 60.0
        
        
        [scannerConnectionLabel, extraInformationLabel, resultView, expiryIndicatorView, printerConnectionLabel].forEach { addSubview($0) }
        
        
        scannerConnectionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30).isActive = true
        scannerConnectionLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 24).isActive = true
        scannerConnectionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30).isActive = true
        scannerConnectionLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        printerConnectionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30).isActive = true
        printerConnectionLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 54).isActive = true
        printerConnectionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30).isActive = true
        printerConnectionLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        extraInformationLabel.bottomAnchor.constraint(equalTo: resultView.topAnchor, constant: -60).isActive = true
        extraInformationLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24).isActive = true
        extraInformationLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24).isActive = true
        
        resultView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        resultView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        resultView.widthAnchor.constraint(equalToConstant: resultViewDimension).isActive = true
        resultView.heightAnchor.constraint(equalToConstant: resultViewDimension).isActive = true
        resultView.layer.cornerRadius = resultViewDimension / 2

        expiryIndicatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        expiryIndicatorView.topAnchor.constraint(equalTo: resultView.ageLimitContainerView.bottomAnchor, constant: 16).isActive = true
        expiryIndicatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        expiryIndicatorView.heightAnchor.constraint(equalToConstant: expiryIndicatorViewHeight).isActive = true
        
        [expiryLabel].forEach { expiryIndicatorView.addSubview($0) }
        
        expiryLabel.centerXAnchor.constraint(equalTo: expiryIndicatorView.centerXAnchor).isActive = true
        expiryLabel.centerYAnchor.constraint(equalTo: expiryIndicatorView.centerYAnchor).isActive = true
    }
    
    public func updateViews(with age: Age, and cardExpiryDate: Date) {
        
        scanComplete = true
        resultView.reset()
        
        // If the expiryDate is before (less than) the current date, it is expired
        let isExpired: Bool = cardExpiryDate < Date()
        if age.isOldEnoughToEnter() && isExpired == false {
            resultView.set(result: .success, withAgeThreshold: AgeLimitSelectionView.ageLimitThreshhold)
        } else if age.isOldEnoughToEnter() && isExpired == true {
            resultView.set(result: .failure, withAgeThreshold: AgeLimitSelectionView.ageLimitThreshhold)
            extraInformationLabel.text = "This person is old enough to enter but has an expired ID"
        } else {
            let dateComponents = age.timeUntil21YearsOld()
            
            if dateComponents.year == 0, dateComponents.month == 0 {
                if let days = dateComponents.day, days <= 10 {
                    // This person is within 10 days of 21 years old
                    extraInformationLabel.text = "This person is within 10 days of turning 21"
                }
            }
            
            resultView.set(result: .failure, withAgeThreshold: AgeLimitSelectionView.ageLimitThreshhold)
        }
        
        updateExpiry(isExpired: isExpired)
    }
    
    private func updateExpiry(isExpired: Bool) {
        expiryLabel.text = isExpired ? "Expired" : "NOT Expired"
        expiryIndicatorView.backgroundColor = isExpired ? noEntryAllowedColor : entryAllowedColor
    }
    
    public func reset() {
        extraInformationLabel.text = ""
        expiryIndicatorView.backgroundColor = UIColor.clear
        expiryLabel.text = "------"
        updateUserInterface(isScanning: false)
        resultView.reset()
        scanComplete = false
    }
    
    public func updateScannerConnection(isConnected: Bool) {
        scannerConnectionLabel.text = isConnected ? "Scanner is Connected" : "No Scanner Connected"
    }
    
    public func updatePrinterConnection(isConnected: Bool) {
        printerConnectionLabel.text = isConnected ? "Printer is Connected" : "No Printer Connected"
    }
    
    public func updateUserInterface(isScanning: Bool) {
        guard scanComplete == false else { return }
        expiryLabel.text = isScanning ? "SCANNING" : "------"
        
        if isScanning {
            resultView.startPulsingAnimation()
        } else {
            resultView.stopPulsingAnimation()
        }
        
    }
}
