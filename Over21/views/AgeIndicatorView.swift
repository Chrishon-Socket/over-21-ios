//
//  AgeIndicatorView.swift
//  Over21
//
//  Created by Chrishon Wyllie on 9/28/18.
//  Copyright © 2018 Socket Mobile. All rights reserved.
//

import UIKit

class AgeIndicatorView: UIView {
    
    // MARK: - UI Elements
    
    private let noEntryAllowedColor = UIColor(red: 251/255, green: 119/255, blue: 119/255, alpha: 1.0)
    private let entryMAYBEAllowedColor = UIColor(red: 119/255, green: 183/255, blue: 251/255, alpha: 1.0)
    private let entryAllowedColor = UIColor(red: 120/255, green: 240/255, blue: 151/255, alpha: 1.0)
    
    private var scannerConnectionLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.medium)
        //lbl.adjustsFontSizeToFitWidth = true
        lbl.text = "No Scanner Connected"
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
        return v
    }()
    
    // - - - - - - -
    
    private var colorIndicatorView: UIView = {
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
    
    // - - - - - - -
    
    private var expiryLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 24)
        lbl.text = "EXPIRED"
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
        
        let colorIndicatorViewHeight: CGFloat = 190.0
        let resultViewDimension: CGFloat = colorIndicatorViewHeight * 0.7
        let expiryIndicatorViewHeight: CGFloat = 60.0
        let expiryLabelVerticalOffset: CGFloat = 10.0
        
        
        [scannerConnectionLabel, extraInformationLabel, expiryIndicatorView, colorIndicatorView].forEach { addSubview($0) }
        colorIndicatorView.addSubview(resultView)
        
        scannerConnectionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30).isActive = true
        scannerConnectionLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 24).isActive = true
        scannerConnectionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30).isActive = true
        scannerConnectionLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        extraInformationLabel.bottomAnchor.constraint(equalTo: colorIndicatorView.topAnchor, constant: -16).isActive = true
        extraInformationLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24).isActive = true
        extraInformationLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24).isActive = true
        
        colorIndicatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        colorIndicatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        colorIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        colorIndicatorView.heightAnchor.constraint(equalToConstant: colorIndicatorViewHeight).isActive = true
        
        expiryIndicatorView.leadingAnchor.constraint(equalTo: colorIndicatorView.leadingAnchor, constant: 10).isActive = true
        expiryIndicatorView.topAnchor.constraint(equalTo: colorIndicatorView.bottomAnchor, constant: -expiryLabelVerticalOffset).isActive = true
        expiryIndicatorView.trailingAnchor.constraint(equalTo: colorIndicatorView.trailingAnchor, constant: -10).isActive = true
        expiryIndicatorView.heightAnchor.constraint(equalToConstant: expiryIndicatorViewHeight).isActive = true
        
        [expiryLabel].forEach { expiryIndicatorView.addSubview($0) }
        
        expiryLabel.centerXAnchor.constraint(equalTo: expiryIndicatorView.centerXAnchor).isActive = true
        expiryLabel.centerYAnchor.constraint(equalTo: expiryIndicatorView.centerYAnchor).isActive = true
        
        
        resultView.centerXAnchor.constraint(equalTo: colorIndicatorView.centerXAnchor).isActive = true
        resultView.centerYAnchor.constraint(equalTo: colorIndicatorView.centerYAnchor).isActive = true
        resultView.widthAnchor.constraint(equalToConstant: resultViewDimension).isActive = true
        resultView.heightAnchor.constraint(equalToConstant: resultViewDimension).isActive = true
        resultView.layer.cornerRadius = resultViewDimension / 2
        
        
        
    }
    
    public func updateScannerConnection(isConnected: Bool) {
        scannerConnectionLabel.text = isConnected ? "Connected" : "No Scanner Connected"
        if isConnected == false { reset() }
    }
    
   
    
    public func updateViews(with age: Age, and cardExpiryDate: Date) {
        
        // If the expiryDate is before (less than) the current date, it is expired
        let isExpired: Bool = cardExpiryDate < Date()
        if age.isOldEnoughToEnter() && isExpired == false {
            resultView.set(result: .success)
        } else if age.isOldEnoughToEnter() && isExpired == true {
            resultView.set(result: .failure)
            extraInformationLabel.text = "This person is old enough to enter but has an expired ID"
        } else {
            let dateComponents = age.timeUntil21YearsOld()
            
            if dateComponents.year == 0, dateComponents.month == 0 {
                if let days = dateComponents.day, days <= 10 {
                    // This person is within 10 days of 21 years old
                    extraInformationLabel.text = "This person is within 10 days of turning 21"
                }
            }
            
            resultView.set(result: .failure)
        }
        
        updateExpiry(isExpired: isExpired)
    }
    
    private func updateExpiry(isExpired: Bool) {
        expiryLabel.text = isExpired ? "Expired" : "NOT Expired"
        expiryIndicatorView.backgroundColor = isExpired ? noEntryAllowedColor : entryAllowedColor
    }
    
    private func reset() {
        extraInformationLabel.text = ""
        colorIndicatorView.backgroundColor = UIColor.clear
        expiryIndicatorView.backgroundColor = UIColor.clear
        expiryLabel.text = ""
    }
}
