//
//  CALayer+Pulsar.swift
//  Pulsar
//
//  Created by Vincent Esche on 2/6/15.
//  Copyright (c) 2015 Vincent Esche. All rights reserved.
//

import QuartzCore

extension CALayer {
	
	public typealias PulsarClosure = (Builder) -> ()
	
	public func addPulse(_ closure: PulsarClosure? = nil) -> CAShapeLayer? {
		guard self.masksToBounds == false else {
			print("Aborting. CALayers with 'masksToBounds' set to YES cannot show pulse.")
			return nil
		}
		
		let builder = Builder(self)
		if let closure = closure {
			closure(builder)
		}
		
		let pulseLayer = CAShapeLayer()
		
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		
		assert((builder.borderColors.count > 0) || (builder.backgroundColors.count > 0))
		
		pulseLayer.fillColor = builder.backgroundColors.first
		pulseLayer.frame = self.bounds
		pulseLayer.opacity = 0.0
		pulseLayer.path = builder.path
		pulseLayer.strokeColor = builder.borderColors.first
		pulseLayer.lineWidth = builder.lineWidth
		
		CATransaction.commit()
		
		self.insertSublayer(pulseLayer, at:0)

        var pulsarLayers = self.pulsarLayers
        pulsarLayers.append(pulseLayer)
        self.pulsarLayers = pulsarLayers
		
		let alphaAnimation = CABasicAnimation(keyPath: "opacity")
		alphaAnimation.fromValue = 1.0
		alphaAnimation.toValue = 0.0
		alphaAnimation.duration = max(builder.duration, 0.0)
		
		let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
		scaleAnimation.fromValue = NSValue(caTransform3D: builder.transformBefore)
		scaleAnimation.toValue = NSValue(caTransform3D: builder.transformAfter)
		scaleAnimation.duration = max(builder.duration, 0.0)
		
		var animations: [CAAnimation] = [alphaAnimation, scaleAnimation]
		
		if (builder.borderColors.count > 1) {
			let colorAnimation = CAKeyframeAnimation(keyPath: "strokeColor")
			colorAnimation.values = builder.borderColors
			animations.append(colorAnimation)
		}
		
		if (builder.backgroundColors.count > 1) {
			let colorAnimation = CAKeyframeAnimation(keyPath: "fillColor")
			colorAnimation.values = builder.backgroundColors
			animations.append(colorAnimation)
		}
		
		let animationGroup = CAAnimationGroup()
		animationGroup.duration = max(builder.duration, 0.0)
		if builder.repeatCount > 0 {
			animationGroup.duration += max(builder.repeatDelay, 0.0)
		}
		animationGroup.animations = animations
		animationGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
		animationGroup.repeatCount = Float(min(Float(builder.repeatCount), FLT_MAX))
		animationGroup.delegate = Delegate(pulseLayer: pulseLayer)
		pulseLayer.add(animationGroup, forKey: nil)
		
		return pulseLayer
	}
	
    public func removePulse(_ pulse: CAShapeLayer) {
        if let index = self.pulsarLayers.index(where: { $0 === pulse }) {
            pulse.removeAllAnimations()
            pulse.removeFromSuperlayer()
            self.pulsarLayers.remove(at: index)
        }
    }

    public func removePulses() {
		for pulseLayer in self.pulsarLayers {
			pulseLayer.removeAllAnimations()
			pulseLayer.removeFromSuperlayer()
		}
		self.pulsarLayers = []
	}
	
	var pulsarLayers: [CAShapeLayer] {
		set {
			self.setValue(newValue, forKey: PulsarConstants.layersKey)
		}
		get {
			let pulsarLayers = self.value(forKey: PulsarConstants.layersKey) as? [CAShapeLayer]
			return pulsarLayers ?? []
		}
	}
}

struct PulsarConstants {
	fileprivate static let keyPrefix: String = "Pulsar."
	static let layersKey: String = keyPrefix + "layers"
}

public typealias PulsarStartClosure = (TimeInterval) -> ()
public typealias PulsarStopClosure = (Bool) -> ()

open class Builder {
	open var layer: CALayer
	open var borderColors: [CGColor]
	open var backgroundColors: [CGColor]
	open var path: CGPath
	open var duration: TimeInterval = 1.0
	open var repeatDelay: TimeInterval = 0.0
	open var repeatCount: Int = 0
	open var lineWidth: CGFloat = 3.0
	open var transformBefore: CATransform3D = CATransform3DIdentity
	open var transformAfter: CATransform3D = CATransform3DMakeScale(2.0, 2.0, 1.0)
	open var startBlock: PulsarStartClosure? = nil
	open var stopBlock: PulsarStopClosure? = nil
	
	init(_ layer: CALayer) {
		self.layer = layer
		self.borderColors = Builder.defaultBorderColorsForLayer(layer)
		self.backgroundColors = Builder.defaultBackgroundColorsForLayer(layer)
		self.path = Builder.defaultPathForLayer(layer)
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
				return CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
			} else {
				return CGPath(rect: rect, transform: nil)
			}
		}
	}
}

class Delegate: NSObject {
	
	let pulseLayer: CAShapeLayer
	let startBlock: PulsarStartClosure? = nil
	let stopBlock: PulsarStopClosure? = nil
	
	init(pulseLayer: CAShapeLayer) {
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
        guard var pulseLayers = self.pulseLayer.superlayer?.pulsarLayers else {
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
