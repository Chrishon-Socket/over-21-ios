//
//  NotificationsView.swift
//  Over21
//
//  Created by Chrishon Wyllie on 11/6/18.
//  Copyright © 2018 Socket Mobile. All rights reserved.
//

import UIKit

class NotificationsView: UIView {
    
    // MARK: - Variables
    
    public var isShowing: Bool = false
    
    private let visibleConstant: CGFloat = 0
    private let invisibleConstant: CGFloat = 500 // Some arbitrarily large number. Just to hide the messageLabel
    
    
    
    
    
    
    
    // MARK - UI Elements
    
    private lazy var containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor(red: 0.125, green: 0.125, blue: 0.125, alpha: 1.0)
        v.isUserInteractionEnabled = true
        v.alpha = 0.0 // hidden initially
        v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(animate)))
        return v
    }()
    
    private var messageLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.textColor = UIColor.white
        lbl.numberOfLines = 0
        lbl.font = UIFont.systemFont(ofSize: 36, weight: UIFont.Weight.medium)
        return lbl
    }()
    
    private var messageLabelCenterYAnchor: NSLayoutConstraint?
    
    
    
    
    
    
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
        addSubview(containerView)
        addSubview(messageLabel)
        
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        messageLabelCenterYAnchor = messageLabel.bottomAnchor.constraint(equalTo: centerYAnchor, constant: invisibleConstant)
        messageLabelCenterYAnchor?.isActive = true
    }
    
    public func setMessage(to newMessage: String) {
        messageLabel.text = newMessage
    }
    
    @objc public func animate() {
        self.isHidden = false
        let animationDuration: TimeInterval = 0.75
        self.isShowing = !self.isShowing
        
        messageLabelCenterYAnchor?.constant = isShowing ? visibleConstant: invisibleConstant
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.alpha = self.isShowing ? 0.65 : 0.0
            self.layoutIfNeeded()
        }) { (_) in
            if self.isShowing == false {
                self.isHidden = true
            }
        }
    }
    
}
