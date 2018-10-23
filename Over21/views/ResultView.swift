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
    private var scanningLayer: CAShapeLayer?
    private var successPath: UIBezierPath?
    private var failurePath: UIBezierPath?
    private var shapeLineWidth: CGFloat = 6.5
    
    
    // MARK: - UI Elements
    
    private var outerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        return v
    }()
    private var centerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        return v
    }()
    private var pulsingAnimation: CABasicAnimation = {
        let pulsingAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulsingAnimation.duration = 1
        pulsingAnimation.fromValue = 1
        pulsingAnimation.toValue = 1.25
        pulsingAnimation.autoreverses = true
        pulsingAnimation.repeatCount = Float.infinity
        return pulsingAnimation
    }()
    
    
    
    
    
    
    
    
    
    // MARK: - Initializers
    
    init() {
        super.init(frame: .zero)
        setupUIElements()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
    
    
    // MARK: - Functions
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if didLayoutSubviews == false {
            outerView.layer.cornerRadius = self.bounds.size.width / 2
            setupShapeLayers()
            didLayoutSubviews = true
        }
    }
    
    private func setupUIElements() {
        let centerViewDimension: CGFloat = 180.0
        
        addSubview(outerView)
        addSubview(centerView)
        
        outerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        outerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        outerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        outerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        centerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        centerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        centerView.widthAnchor.constraint(equalToConstant: centerViewDimension).isActive = true
        centerView.heightAnchor.constraint(equalToConstant: centerViewDimension).isActive = true
        centerView.layer.cornerRadius = centerViewDimension / 2
        
        
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
        
        scanningLayer = CAShapeLayer()
        scanningLayer?.fillColor = entryMAYBEAllowedColor.cgColor
        scanningLayer?.lineWidth = shapeLineWidth * 2
        let circlePath = UIBezierPath(roundedRect: outerView.bounds, byRoundingCorners: .allCorners, cornerRadii: outerView.bounds.size)
        scanningLayer?.path = circlePath.cgPath
        scanningLayer?.frame = circlePath.cgPath.boundingBoxOfPath
        outerView.layer.addSublayer(scanningLayer!)
        
        setupPaths(with: centerView)
    }
    
    private func setupPaths(with view: UIView) {
        // must have same number of control points
        
        let width = view.bounds.width
        let height = view.bounds.height
        let origin = view.bounds.origin
        
        successPath = UIBezierPath()
        successPath?.move(to: .init(x: width * 0.2, y: height * 0.5))
        successPath?.addLine(to: .init(x: width * 0.45, y: height * 0.7))
        successPath?.move(to: .init(x: width * 0.45, y: height * 0.7))
        successPath?.addLine(to: .init(x: width * 0.8, y: height * 0.3))
        
        failurePath = UIBezierPath()
        failurePath?.move(to: .init(x: width * 0.2, y: height * 0.2))
        failurePath?.addLine(to: .init(x: width * 0.8, y: height * 0.8))
        failurePath?.move(to: .init(x: width * 0.8, y: height * 0.2))
        failurePath?.addLine(to: .init(x: width * 0.2, y: height * 0.8))
        
        shapeLayer?.path = (failurePath?.cgPath)!
        shapeLayer?.frame = (failurePath?.cgPath.boundingBoxOfPath)!
        shapeLayer?.frame.origin = origin
        view.layer.addSublayer(shapeLayer!)
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
            strongSelf.shapeLayer?.strokeColor = result == .success ? entryAllowedColor.cgColor : noEntryAllowedColor.cgColor
        }) { (_) in
            
        }
        
        CATransaction.commit()
    }
    
    public func reset() {
        shapeLayer?.strokeColor = UIColor.clear.cgColor
        stopPulsingAnimation()
    }
    public func startPulsingAnimation() {
        scanningLayer?.add(pulsingAnimation, forKey: "pulsing")
    }
    public func stopPulsingAnimation() {
        scanningLayer?.removeAnimation(forKey: "pulsing")
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
