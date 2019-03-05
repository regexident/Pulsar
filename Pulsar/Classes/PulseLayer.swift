//
//  PulseLayer.swift
//  Pulsar
//
//  Created by Vincent Esche on 3/5/19.
//  Copyright © 2019 Regexident. All rights reserved.
//

import QuartzCore

public class PulseLayer: CAShapeLayer {
    enum Constants {
        static let layersKey: String = "Pulsar.layers"
        static let animationKey: String = "Pulsar.animation"
        static let persistenceKey: String = "Pulsar.persistence"
    }
    
    fileprivate struct Persistence {
        let animations: [String: CAAnimation]
        let speed: Float
    }
    
    public var isAnimationsPaused: Bool {
        return self.speed == 0.0
    }
    
    fileprivate let pulse: Pulse
    fileprivate var persistence: Persistence?
    fileprivate let applicationObserver: ApplicationObserver = .init()

    init(pulse: Pulse) {
        self.pulse = pulse
        
        super.init()
        
        self.reset()
        
        self.applicationObserver.delegate = self
    }
    
    public override init(layer anyLayer: Any) {
        guard let layer = anyLayer as? PulseLayer else {
            fatalError("Expected \(PulseLayer.self), found \(type(of: anyLayer)).")
        }
        self.pulse = layer.pulse
        
        super.init(layer: layer)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func reset(animated: Bool = false) {
        CATransaction.begin()
        CATransaction.setDisableActions(!animated)
        self.frame = pulse.frame
        self.fillColor = pulse.backgroundColors.first
        self.opacity = 0.0
        self.path = pulse.path
        self.strokeColor = pulse.borderColors.first
        self.lineWidth = pulse.lineWidth
        CATransaction.commit()
    }
    
    class func pulseAnimation(from pulse: Pulse) -> CAAnimation {
        var animations: [CAAnimation] = []
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0.0
        opacityAnimation.duration = max(pulse.duration, 0.0)
        opacityAnimation.isRemovedOnCompletion = false
        animations.append(opacityAnimation)
        
        let transformAnimation = CABasicAnimation(keyPath: "transform")
        transformAnimation.fromValue = NSValue(caTransform3D: pulse.transformBefore)
        transformAnimation.toValue = NSValue(caTransform3D: pulse.transformAfter)
        transformAnimation.duration = max(pulse.duration, 0.0)
        transformAnimation.isRemovedOnCompletion = false
        animations.append(transformAnimation)
        
        if pulse.borderColors.count > 1 {
            let strokeColorAnimation = CAKeyframeAnimation(keyPath: "strokeColor")
            strokeColorAnimation.values = pulse.borderColors
            transformAnimation.duration = max(pulse.duration, 0.0)
            strokeColorAnimation.isRemovedOnCompletion = false
            animations.append(strokeColorAnimation)
        }
        
        if pulse.backgroundColors.count > 1 {
            let fillColorAnimation = CAKeyframeAnimation(keyPath: "fillColor")
            fillColorAnimation.values = pulse.backgroundColors
            transformAnimation.duration = max(pulse.duration, 0.0)
            fillColorAnimation.isRemovedOnCompletion = false
            animations.append(fillColorAnimation)
        }
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = max(pulse.duration, 0.0)
        if pulse.repeatCount > 0 {
            animationGroup.duration += max(pulse.repeatDelay, 0.0)
        }
        animationGroup.animations = animations
        animationGroup.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animationGroup.repeatCount = min(Float(pulse.repeatCount), Float.infinity)
        animationGroup.isRemovedOnCompletion = false
        
        return animationGroup
    }
    
    public func pauseAnimations() {
        // https://developer.apple.com/library/archive/qa/qa1673/_index.html
        
        let currentTime = CACurrentMediaTime()
        let pausedTime = self.convertTime(currentTime, from: nil)
        self.speed = 0.0
        self.timeOffset = pausedTime
    }
    
    public func resumeAnimations(speed: Float = 1.0) {
        // https://developer.apple.com/library/archive/qa/qa1673/_index.html
        
        let pausedTime = self.timeOffset
        self.speed = speed
        self.timeOffset = 0.0
        self.beginTime = 0.0
        let currentTime = CACurrentMediaTime()
        let timeSincePause = self.convertTime(currentTime, from: nil) - pausedTime
        self.beginTime = timeSincePause
    }
    
    fileprivate func restoreAnimations() -> Float {
        guard let persistence = self.persistence else {
            return self.speed
        }
        
        defer {
            self.persistence = nil
        }

        self.speed = persistence.speed
        
        for (key, animation) in persistence.animations {
            self.removeAnimation(forKey: key)
            self.add(animation, forKey: key)
        }
        
        return persistence.speed
    }
    
    fileprivate func persistAnimations() {
        guard self.persistence == nil else {
            return
        }
        
        let animationKeys = self.animationKeys() ?? []
        let animationsByKey = animationKeys.compactMap { key in
            self.animation(forKey: key).map { (key, $0) }
        }
        let animations = Dictionary(uniqueKeysWithValues: animationsByKey)
        
        self.persistence = Persistence(
            animations: animations,
            speed: speed
        )
    }
}

extension PulseLayer: ApplicationObserverDelegate {
    public func applicationWillEnterForeground() {
        let speed = self.restoreAnimations()
        self.resumeAnimations(speed: speed)
    }
    
    public func applicationDidEnterBackground() {
        self.persistAnimations()
        self.pauseAnimations()
    }
}
