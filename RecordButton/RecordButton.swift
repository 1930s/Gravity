//
//  RecordButton.swift
//  Instant
//
//  Created by Samuel Beek on 21/06/15.
//  Copyright (c) 2015 Samue Beek. All rights reserved.
//

import UIKit

@objc enum RecordButtonState : Int {
    case Recording, Idle
}

@IBDesignable
@objc class RecordButton : UIButton {
    
    @IBInspectable
    internal var buttonColor: UIColor! = .white {
        didSet {
            circleLayer.backgroundColor = buttonColor.cgColor
            circleBorder.borderColor = UIColor.white.cgColor
        }
    }
    @IBInspectable
    internal var progressColor: UIColor!  = .red {
        didSet {
            gradientMaskLayer.colors = [progressColor.cgColor, progressColor.cgColor]
        }
    }
    public var recordingStateDidChange: (RecordButton) -> Void = { _ in }
    
    private var circleLayer: CALayer!
    private var circleBorder: CALayer!
    private var progressLayer: CAShapeLayer!
    private var gradientMaskLayer: CAGradientLayer!
    private var currentProgress: CGFloat! = 0
    private var shouldPauseRecordingOnTouchUp: Bool = false
    internal var buttonState : RecordButtonState = .Idle {
        didSet {
            switch buttonState {
            case .Idle:
                currentProgress = 0
                setProgress(newProgress: 0)
                setRecording(recording: false)
            case .Recording:
                setRecording(recording: true)
            }
            if buttonState != oldValue {
                recordingStateDidChange(self)
            }
        }
        
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.addTarget(self, action: #selector(RecordButton.didTouchDown), for: .touchDown)
        self.addTarget(self, action: #selector(RecordButton.didTouchUp), for: .touchUpInside)
        self.addTarget(self, action: #selector(RecordButton.didTouchUp), for: .touchUpOutside)
        
        self.drawButton()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.addTarget(self, action: #selector(RecordButton.didTouchDown), for: .touchDown)
        self.addTarget(self, action: #selector(RecordButton.didTouchUp), for: .touchUpInside)
        self.addTarget(self, action: #selector(RecordButton.didTouchUp), for: .touchUpOutside)
        
        self.drawButton()
    }
    
    
    private func drawButton() {
        
        self.backgroundColor = UIColor.clear
        let layer = self.layer
        circleLayer = CALayer()
        circleLayer.backgroundColor = buttonColor.cgColor
        
        let size: CGFloat = self.frame.size.width / 1.5
        circleLayer.bounds = CGRect(x: 0, y: 0, width: size, height: size)
        circleLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        circleLayer.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        circleLayer.cornerRadius = size / 2
        layer.insertSublayer(circleLayer, at: 0)
        
        circleBorder = CALayer()
        circleBorder.backgroundColor = UIColor.clear.cgColor
        circleBorder.borderWidth = 1
        circleBorder.borderColor = UIColor.white.cgColor
        circleBorder.bounds = CGRect(x: 0, y: 0, width: self.bounds.size.width - 1.5, height: self.bounds.size.height - 1.5)
        circleBorder.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        circleBorder.position = CGPoint(x: self.bounds.midX,y: self.bounds.midY)
        circleBorder.cornerRadius = self.frame.size.width / 2
        layer.insertSublayer(circleBorder, at: 0)
        
        let startAngle: CGFloat = .pi + .pi / 2
        let endAngle: CGFloat = .pi * 3 + .pi / 2
        let centerPoint: CGPoint = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        gradientMaskLayer = self.gradientMask()
        progressLayer = CAShapeLayer()
        progressLayer.path = UIBezierPath(arcCenter: centerPoint, radius: self.frame.size.width / 2 - 2, startAngle: startAngle, endAngle: endAngle, clockwise: true).cgPath
        progressLayer.backgroundColor = UIColor.clear.cgColor
        progressLayer.fillColor = nil
        progressLayer.strokeColor = UIColor.black.cgColor
        progressLayer.lineWidth = 4.0
        progressLayer.strokeStart = 0.0
        progressLayer.strokeEnd = 0.0
        gradientMaskLayer.mask = progressLayer
        layer.insertSublayer(gradientMaskLayer, at: 0)
    }
    
    private func setRecording(recording: Bool) {
        
        let duration: TimeInterval = 0.15
        circleLayer.contentsGravity = "center"
        
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = recording ? 1.0 : 0.88
        scale.toValue = recording ? 0.88 : 1
        scale.duration = duration
        scale.fillMode = kCAFillModeForwards
        scale.isRemovedOnCompletion = false
        
        let color = CABasicAnimation(keyPath: "backgroundColor")
        color.duration = duration
        color.fillMode = kCAFillModeForwards
        color.isRemovedOnCompletion = false
        color.toValue = recording ? progressColor.cgColor : buttonColor.cgColor
        
        let circleAnimations = CAAnimationGroup()
        circleAnimations.isRemovedOnCompletion = false
        circleAnimations.fillMode = kCAFillModeForwards
        circleAnimations.duration = duration
        circleAnimations.animations = [scale, color]
        
        let borderColor: CABasicAnimation = CABasicAnimation(keyPath: "borderColor")
        borderColor.duration = duration
        borderColor.fillMode = kCAFillModeForwards
        borderColor.isRemovedOnCompletion = false
        borderColor.toValue = recording ? UIColor(red: 0.83, green: 0.86, blue: 0.89, alpha: 1).cgColor : buttonColor
        
        let borderScale = CABasicAnimation(keyPath: "transform.scale")
        borderScale.fromValue = recording ? 1.0 : 0.88
        borderScale.toValue = recording ? 0.88 : 1.0
        borderScale.duration = duration
        borderScale.fillMode = kCAFillModeForwards
        borderScale.isRemovedOnCompletion = false
        
        let borderAnimations = CAAnimationGroup()
        borderAnimations.isRemovedOnCompletion = false
        borderAnimations.fillMode = kCAFillModeForwards
        borderAnimations.duration = duration
        borderAnimations.animations = [borderColor, borderScale]
        
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = recording ? 0.0 : 1.0
        fade.toValue = recording ? 1.0 : 0.0
        fade.duration = duration
        fade.fillMode = kCAFillModeForwards
        fade.isRemovedOnCompletion = false
        
        circleLayer.add(circleAnimations, forKey: "circleAnimations")
        progressLayer.add(fade, forKey: "fade")
        circleBorder.add(borderAnimations, forKey: "borderAnimations")
        
    }
    
    private func gradientMask() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.locations = [0.0, 1.0]
        let topColor = progressColor
        let bottomColor = progressColor
        gradientLayer.colors = [topColor?.cgColor as Any, bottomColor?.cgColor as Any]
        return gradientLayer
    }
    
    override func layoutSubviews() {
        circleLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        circleLayer.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        circleBorder.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        circleBorder.position = CGPoint(x: self.bounds.midX, y:self.bounds.midY)
        super.layoutSubviews()
    }
    
    
    @objc internal func didTouchDown(){
        guard buttonState != .Recording else { return }
        shouldPauseRecordingOnTouchUp = false
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { (timer) in
            self.shouldPauseRecordingOnTouchUp = true
        }
        self.buttonState = .Recording
    }
    
    @objc internal func didTouchUp() {
        if shouldPauseRecordingOnTouchUp {
            self.buttonState = .Idle
        }
    }
    
    
    internal func setProgress(newProgress: CGFloat) {
        progressLayer.strokeEnd = newProgress
    }
    
    
}

