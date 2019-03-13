//
//  AgeLimitSelectionView.swift
//  Over21
//
//  Created by Chrishon Wyllie on 11/6/18.
//  Copyright © 2018 Socket Mobile. All rights reserved.
//

import UIKit

/*
 This view is used to select the age that is accepted.
 18, 21 and 60 are the current options
 */

class AgeLimitSelectionView: UIView {
    
    // MARK: - Variables
    
    public static var ageLimitThreshhold: Int = 21 // 21 by default
    
    public let buttonHeight: CGFloat = 30

    
    
    // MARK - UI Elements
    
    private var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.boldSystemFont(ofSize: 16)
        lbl.text = "Select an age limit"
        lbl.textColor = UIColor.darkGray
        lbl.textAlignment = .center
        return lbl
    }()

    private var stackView: UIStackView!
    private var selectAgeButton: UIButton!
    private var eighteenButton: UIButton!
    private var twentyOneButton: UIButton!
    private var sixtyButton: UIButton!
    
    
    
    
    
    
    
    // MARK: - Initializers
    
    init() {
        super.init(frame: .zero)
        setupUIElements()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    // MARK: - Functions
    
    private func setupUIElements() {
        
        addSubview(titleLabel)
        
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        
        selectAgeButton = createAgeOption(withTitle: "Tap to select")
        selectAgeButton.backgroundColor = UIColor.groupTableViewBackground
        
        eighteenButton = createAgeOption(withTitle: "18")
        twentyOneButton = createAgeOption(withTitle: "21")
        sixtyButton = createAgeOption(withTitle: "60")
        
        stackView = {
            let sv = UIStackView(arrangedSubviews: [selectAgeButton, eighteenButton, twentyOneButton, sixtyButton])
            sv.translatesAutoresizingMaskIntoConstraints = false
            sv.axis = .vertical
            sv.spacing = 0
            sv.distribution = .fillEqually
            return sv
        }()
        
        addSubview(stackView)
        
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        [selectAgeButton, eighteenButton, twentyOneButton, sixtyButton].forEach { (button) in
            button?.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
            button?.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
            button?.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        }
        
        selectAgeButton.addTarget(self, action: #selector(toggleSelectionMenu), for: .touchUpInside)
        
        [eighteenButton, twentyOneButton, sixtyButton].forEach { (button) in
            button?.isHidden = true
            button?.addTarget(self, action: #selector(handleSelection(_:)), for: .touchUpInside)
        }
    }
    
    private func createAgeOption(withTitle title: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .white
        btn.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        btn.layer.borderWidth = 0.5
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.setTitleColor(UIColor.darkGray, for: .normal)
        return btn
    }
    
    private enum AgeThreshhold: String {
        case eighteen = "18"
        case twentyOne = "21"
        case sixty = "60"
    }
    
    @objc private func toggleSelectionMenu() {
        [eighteenButton, twentyOneButton, sixtyButton].forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button?.isHidden = !(button?.isHidden)!
                self.layoutIfNeeded()
            })
        }
    }
    
    @objc private func handleSelection(_ sender: UIButton) {
        guard let buttonTitle = sender.currentTitle, let ageLimit = AgeThreshhold(rawValue: buttonTitle) else { return }
        
        if let ageLimitAsInt = Int(ageLimit.rawValue) {
            AgeLimitSelectionView.ageLimitThreshhold = ageLimitAsInt
        }
        selectAgeButton.setTitle(ageLimit.rawValue, for: .normal)
        
        toggleSelectionMenu()
    }
}
