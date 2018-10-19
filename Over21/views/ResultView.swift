//
//  ResultView.swift
//  Over21
//
//  Created by Chrishon Wyllie on 10/11/18.
//  Copyright © 2018 Socket Mobile. All rights reserved.
//

import UIKit

// Used to display a checkmark or error symbol when attempting to set or get a property
public enum ResultType {
    case success
    case failure
}

class ResultView: UIView {
    
    // MARK: - Variables
    
    private var didLayoutSubviews: Bool = false
    
    private var shapeLayer: CAShapeLayer?
    private var successPath: UIBezierPath?
    private var failurePath: UIBezierPath?
    private var shapeLineWidth: CGFloat = 6.5
    
    
    // MARK: - UI Elements
    
    
    
    
    
    // MARK: - Initializers
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    // MARK: - Functions
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if didLayoutSubviews == false {
            setupShapeLayers()
            didLayoutSubviews = true
        }
    }
    
    private func setupShapeLayers() {
        
        backgroundColor = .white
        
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
        
        shapeLayer = CAShapeLayer()
        shapeLayer?.fillColor = nil
        shapeLayer?.strokeColor = UIColor.clear.cgColor
        shapeLayer?.lineWidth = shapeLineWidth
        shapeLayer?.lineCap = CAShapeLayerLineCap.round
        
        // must have same number of control points
        
        successPath = UIBezierPath()
        successPath?.move(to: .init(x: bounds.width * 0.2, y: bounds.height * 0.5))
        successPath?.addLine(to: .init(x: bounds.width * 0.45, y: bounds.height * 0.7))
        successPath?.move(to: .init(x: bounds.width * 0.45, y: bounds.height * 0.7))
        successPath?.addLine(to: .init(x: bounds.width * 0.8, y: bounds.height * 0.3))
        
        failurePath = UIBezierPath()
        failurePath?.move(to: .init(x: bounds.width * 0.2, y: bounds.height * 0.2))
        failurePath?.addLine(to: .init(x: bounds.width * 0.8, y: bounds.height * 0.8))
        failurePath?.move(to: .init(x: bounds.width * 0.8, y: bounds.height * 0.2))
        failurePath?.addLine(to: .init(x: bounds.width * 0.2, y: bounds.height * 0.8))
        
        shapeLayer?.path = (failurePath?.cgPath)!
        shapeLayer?.frame = (failurePath?.cgPath.boundingBoxOfPath)!
        shapeLayer?.frame.origin = bounds.origin
        layer.addSublayer(shapeLayer!)
    }
    
    public func set(result: ResultType) {
        
        let animationDuration: TimeInterval = 0.4
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.duration = animationDuration
        pathAnimation.fromValue = (self.shapeLayer?.path)!
        pathAnimation.toValue = result == .failure ? (self.failurePath?.cgPath)! : (self.successPath?.cgPath)!
        pathAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        pathAnimation.delegate = self
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        self.shapeLayer?.add(pathAnimation, forKey: nil)
        self.shapeLayer?.path = result == .success ? (self.successPath?.cgPath)! : (self.failurePath?.cgPath)!
        
        UIView.animate(withDuration: animationDuration, animations: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.shapeLayer?.strokeColor = result == .success ? UIColor.green.cgColor : UIColor.red.cgColor
        }) { (_) in
            
        }
        
        CATransaction.commit()
    }
}

extension ResultView: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        //fade(anim: anim)
    }
    
    private func fade(anim: CAAnimation) {
        if (anim as? CABasicAnimation)?.keyPath == "path" {
            let fadeAnimation = CABasicAnimation(keyPath: "strokeColor")
            fadeAnimation.duration = 2.0
            fadeAnimation.fromValue = shapeLayer?.strokeColor
            fadeAnimation.toValue = UIColor.clear.cgColor
            fadeAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            fadeAnimation.fillMode = CAMediaTimingFillMode.forwards
            fadeAnimation.isRemovedOnCompletion = false
            shapeLayer?.add(fadeAnimation, forKey: nil)
        }
    }
}
