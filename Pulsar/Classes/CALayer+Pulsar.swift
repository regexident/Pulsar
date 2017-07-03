//
//  CALayer+Pulsar.swift
//  Pulsar
//
//  Created by Vincent Esche on 2/6/15.
//  Copyright (c) 2015 Vincent Esche. All rights reserved.
//

import QuartzCore

extension CALayer {
	
	public func addPulse(_ closure: ((Pulse) -> ())? = nil) -> PulseLayer? {
		guard self.masksToBounds == false else {
			NSLog("Warning: CALayers with 'masksToBounds' set to YES cannot show pulse.")
			return nil
		}
		
		let pulse = Pulse(self)
		if let closure = closure {
			closure(pulse)
		}
		
		let pulseLayer = PulseLayer(pulse: pulse)
        pulseLayer.frame = self.bounds
        self.insertSublayer(pulseLayer, at:0)

        let animation = PulseLayer.pulseAnimation(from: pulse)
        animation.delegate = Delegate(pulseLayer: pulseLayer)
        pulseLayer.add(animation, forKey: "pulse")

        self.pulseLayers.append(pulseLayer)

		return pulseLayer
	}
	
    public func removePulse(_ pulse: CAShapeLayer) {
        if let index = self.pulseLayers.index(where: { $0 === pulse }) {
            pulse.removeAllAnimations()
            pulse.removeFromSuperlayer()
            self.pulseLayers.remove(at: index)
        }
    }

    public func removePulses() {
		for pulseLayer in self.pulseLayers {
			pulseLayer.removeAllAnimations()
			pulseLayer.removeFromSuperlayer()
		}
		self.pulseLayers = []
	}
	
	var pulseLayers: [PulseLayer] {
		set {
			self.setValue(newValue, forKey: PulsarConstants.layersKey)
		}
		get {
			return self.value(forKey: PulsarConstants.layersKey) as? [PulseLayer] ?? []
		}
	}
}

struct PulsarConstants {
	fileprivate static let keyPrefix: String = "Pulsar."
	static let layersKey: String = keyPrefix + "layers"
}

public typealias PulsarStartClosure = (TimeInterval) -> ()
public typealias PulsarStopClosure = (Bool) -> ()

public class PulseLayer: CAShapeLayer {
    private enum Key: String {
        case pulse
    }

    init(pulse: Pulse) {
        super.init()

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.fillColor = pulse.backgroundColors.first
        self.opacity = 0.0
        self.path = pulse.path
        self.strokeColor = pulse.borderColors.first
        self.lineWidth = pulse.lineWidth
        CATransaction.commit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    class func pulseAnimation(from pulse: Pulse) -> CAAnimation {
        let alphaAnimation = CABasicAnimation(keyPath: "opacity")
        alphaAnimation.fromValue = 1.0
        alphaAnimation.toValue = 0.0
        alphaAnimation.duration = max(pulse.duration, 0.0)

        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = NSValue(caTransform3D: pulse.transformBefore)
        scaleAnimation.toValue = NSValue(caTransform3D: pulse.transformAfter)
        scaleAnimation.duration = max(pulse.duration, 0.0)

        var animations: [CAAnimation] = [alphaAnimation, scaleAnimation]
        if pulse.borderColors.count > 1 {
            let colorAnimation = CAKeyframeAnimation(keyPath: "strokeColor")
            colorAnimation.values = pulse.borderColors
            animations.append(colorAnimation)
        }

        if pulse.backgroundColors.count > 1 {
            let colorAnimation = CAKeyframeAnimation(keyPath: "fillColor")
            colorAnimation.values = pulse.backgroundColors
            animations.append(colorAnimation)
        }

        let animationGroup = CAAnimationGroup()
        animationGroup.duration = max(pulse.duration, 0.0)
        if pulse.repeatCount > 0 {
            animationGroup.duration += max(pulse.repeatDelay, 0.0)
        }
        animationGroup.animations = animations
        animationGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animationGroup.repeatCount = min(Float(pulse.repeatCount), Float.greatestFiniteMagnitude)
        return animationGroup
    }
}

public class Pulse {
	public var borderColors: [CGColor]
	public var backgroundColors: [CGColor]
	public var path: CGPath
	public var duration: TimeInterval = 1.0
	public var repeatDelay: TimeInterval = 0.0
	public var repeatCount: Int = 0
	public var lineWidth: CGFloat = 3.0
	public var transformBefore: CATransform3D = CATransform3DIdentity
	public var transformAfter: CATransform3D = CATransform3DMakeScale(2.0, 2.0, 1.0)
	public var startBlock: PulsarStartClosure? = nil
	public var stopBlock: PulsarStopClosure? = nil
	
	init(_ layer: CALayer) {
		self.borderColors = Pulse.defaultBorderColorsForLayer(layer)
		self.backgroundColors = Pulse.defaultBackgroundColorsForLayer(layer)
		self.path = Pulse.defaultPathForLayer(layer)
	}

	class func defaultBackgroundColorsForLayer(_ layer: CALayer) -> [CGColor] {
		switch layer {
		case let shapeLayer as CAShapeLayer:
			if let fillColor = shapeLayer.fillColor {
				let halfAlpha = fillColor.alpha * 0.5
				return [fillColor.copy(alpha: halfAlpha)!]
			}
		default:
			if let backgroundColor = layer.backgroundColor {
				let halfAlpha = backgroundColor.alpha * 0.5
				return [backgroundColor.copy(alpha: halfAlpha)!]
			}
		}
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let components: [CGFloat] = [1.0, 0.0, 0.0, 0.0]
		return [CGColor(colorSpace: colorSpace, components: components)!]
	}
	
	class func defaultBorderColorsForLayer(_ layer: CALayer) -> [CGColor] {
		switch layer {
		case let shapeLayer as CAShapeLayer:
			if shapeLayer.lineWidth > 0.0 {
				if let strokeColor = shapeLayer.strokeColor {
					return [strokeColor]
				}
			} else {
				if let fillColor = shapeLayer.fillColor {
					return [fillColor]
				}
			}
		default:
			if layer.borderWidth > 0.0 {
				if let borderColor = layer.borderColor {
					return [borderColor]
				}
			} else {
				if let backgroundColor = layer.backgroundColor {
					return [backgroundColor]
				}
			}
		}
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let components: [CGFloat] = [1.0, 0.0, 0.0, 0.0]
		return [CGColor(colorSpace: colorSpace, components: components)!]
	}
	
	class func defaultPathForLayer(_ layer: CALayer) -> CGPath {
		switch layer {
		case let shapeLayer as CAShapeLayer:
			return shapeLayer.path!
		default:
			let rect = layer.bounds
			let minSize = min(rect.width, rect.height)
			let cornerRadius = min(max(0.0, layer.cornerRadius), minSize / 2.0)
			if cornerRadius > 0.0 {
				return CGPath(
                    roundedRect: rect,
                    cornerWidth: cornerRadius,
                    cornerHeight: cornerRadius,
                    transform: nil
                )
			} else {
				return CGPath(rect: rect, transform: nil)
			}
		}
	}
}

class Delegate: NSObject {
	let pulseLayer: PulseLayer
	let startBlock: PulsarStartClosure? = nil
	let stopBlock: PulsarStopClosure? = nil
	
	init(pulseLayer: PulseLayer) {
		self.pulseLayer = pulseLayer
	}
}

extension Delegate: CAAnimationDelegate {
	func animationDidStart(_ animation: CAAnimation) {
		if let startBlock = self.startBlock {
			startBlock(animation.duration)
		}
	}
	
	func animationDidStop(_ animation: CAAnimation, finished: Bool) {
        guard var pulseLayers = self.pulseLayer.superlayer?.pulseLayers else {
            return
        }
        if let index = pulseLayers.index(of: self.pulseLayer) {
            pulseLayers.remove(at: index)
            self.pulseLayer.removeFromSuperlayer()
            if let stopBlock = self.stopBlock {
                stopBlock(finished)
            }
        }
	}
}
