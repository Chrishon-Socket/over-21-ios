//
//  SettingsCell.swift
//  Over21
//
//  Created by Chrishon Wyllie on 11/13/18.
//  Copyright © 2018 Socket Mobile. All rights reserved.
//

import UIKit

protocol SettingsCellDelegate: class {
    func toggleButtonPressed()
}

class SettingsCell: UITableViewCell {
    
    // MARK: - Variables
    
    public weak var delegate: SettingsCellDelegate?
    
    
    
    
    // MARK: - UI Elements
    
    public lazy var toggleButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Restore Scanner Defaults", for: .normal)
        btn.setTitleColor(.red, for: .normal)
        btn.setTitleColor(.darkGray, for: UIControl.State.disabled)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        btn.layer.cornerRadius = 10
        btn.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        btn.layer.borderWidth = 1
        btn.addTarget(self, action: #selector(toggle), for: .touchUpInside)
        return btn
    }()
    
    
    
    
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUIElements()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    // MARK: - Functions
    
    private func setupUIElements() {
        addSubview(toggleButton)
        
        toggleButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        toggleButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        toggleButton.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
        toggleButton.widthAnchor.constraint(equalToConstant: 250.0).isActive = true
    }
    
    @objc private func toggle() {
        delegate?.toggleButtonPressed()
    }
}
