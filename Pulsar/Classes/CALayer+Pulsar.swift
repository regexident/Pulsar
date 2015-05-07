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
	
	public func addPulse(closure: PulsarClosure? = nil) -> CAShapeLayer? {
		if (self.masksToBounds) {
			println("Aborting. CALayers with 'masksToBounds' set to YES cannot show pulse.");
			return nil;
		}
		
		let builder = Builder(self)
		if let closure = closure {
			closure(builder);
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
		
		self.insertSublayer(pulseLayer, atIndex:0)
		
		if var pulsarLayers = self.pulsarLayers as? [CAShapeLayer] {
			pulsarLayers.append(pulseLayer)
			self.pulsarLayers = pulsarLayers
		}
		
		let alphaAnimation = CABasicAnimation(keyPath: "opacity")
		alphaAnimation.fromValue = 1.0
		alphaAnimation.toValue = 0.0
		
		let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
		scaleAnimation.fromValue = NSValue(CATransform3D: builder.transformBefore)
		scaleAnimation.toValue = NSValue(CATransform3D: builder.transformAfter)
		
		var animations: [CAAnimation] = [alphaAnimation, scaleAnimation]
		
		if (builder.borderColors.count > 1) {
			let colorAnimation = CAKeyframeAnimation(keyPath: "strokeColor")!
			colorAnimation.values = builder.borderColors;
			animations.append(colorAnimation)
		}
		
		if (builder.backgroundColors.count > 1) {
			let colorAnimation = CAKeyframeAnimation(keyPath: "fillColor")!
			colorAnimation.values = builder.backgroundColors;
			animations.append(colorAnimation)
		}
		
		let animationGroup = CAAnimationGroup()
		animationGroup.duration = builder.duration;
		animationGroup.animations = animations;
		animationGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
		animationGroup.repeatCount = Float(min(Float(builder.repeatCount), FLT_MAX))
		animationGroup.delegate = Delegate(pulseLayer: pulseLayer)
		pulseLayer.addAnimation(animationGroup, forKey: nil)
		
		return pulseLayer
	}
	
	public func removePulses() {
		for pulseLayer in self.pulsarLayers {
			pulseLayer.removeAllAnimations()
			pulseLayer.removeFromSuperlayer()
		}
		self.pulsarLayers = []
	}
	
	var pulsarLayers: NSArray {
		set {
			self.setValue(newValue, forKey: PulsarConstants.layersKey)
		}
		get {
			let pulsarLayers = self.valueForKey(PulsarConstants.layersKey) as? NSArray
			return pulsarLayers ?? NSArray()
		}
	}
}

struct PulsarConstants {
	private static let keyPrefix: String = "Pulsar."
	static let layersKey: String = keyPrefix + "layers"
}

public typealias PulsarStartClosure = (NSTimeInterval) -> ()
public typealias PulsarStopClosure = (Bool) -> ()

public class Builder {
	public var layer: CALayer
	public var borderColors: [CGColor]
	public var backgroundColors: [CGColor]
	public var path: CGPathRef
	public var duration: NSTimeInterval = 1.0
	public var repeatCount: Int = 0
	public var lineWidth: CGFloat = 3.0
	public var transformBefore: CATransform3D = CATransform3DIdentity
	public var transformAfter: CATransform3D = CATransform3DMakeScale(2.0, 2.0, 1.0)
	public var startBlock: PulsarStartClosure? = nil
	public var stopBlock: PulsarStopClosure? = nil
	
	init(_ layer: CALayer) {
		self.layer = layer
		self.borderColors = Builder.defaultBorderColorsForLayer(layer)
		self.backgroundColors = Builder.defaultBackgroundColorsForLayer(layer)
		self.path = Builder.defaultPathForLayer(layer)
	}

	class func defaultBackgroundColorsForLayer(layer: CALayer) -> [CGColor] {
		switch layer {
		case let shapeLayer as CAShapeLayer:
			if let fillColor = shapeLayer.fillColor {
				let halfAlpha = CGColorGetAlpha(fillColor) * 0.5
				return [CGColorCreateCopyWithAlpha(fillColor, halfAlpha)]
			}
		default:
			if let backgroundColor = layer.backgroundColor {
				let halfAlpha = CGColorGetAlpha(backgroundColor) * 0.5
				return [CGColorCreateCopyWithAlpha(backgroundColor, halfAlpha)]
			}
		}
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let components: [CGFloat] = [1.0, 0.0, 0.0, 0.0]
		return [CGColorCreate(colorSpace, components)]
	}
	
	class func defaultBorderColorsForLayer(layer: CALayer) -> [CGColor] {
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
		return [CGColorCreate(colorSpace, components)]
	}
	
	class func defaultPathForLayer(layer: CALayer) -> CGPathRef {
		switch layer {
		case let shapeLayer as CAShapeLayer:
			return shapeLayer.path
		default:
			let rect = layer.bounds
			let minSize = min(CGRectGetWidth(rect), CGRectGetHeight(rect))
			let cornerRadius = min(max(0.0, layer.cornerRadius), minSize / 2.0)
			if cornerRadius > 0.0 {
				return CGPathCreateWithRoundedRect(rect, cornerRadius, cornerRadius, nil)
			} else {
				return CGPathCreateWithRect(rect, nil)
			}
		}
	}
}

class Delegate {
	
	let pulseLayer: CAShapeLayer
	let startBlock: PulsarStartClosure? = nil
	let stopBlock: PulsarStopClosure? = nil
	
	init(pulseLayer: CAShapeLayer) {
		self.pulseLayer = pulseLayer
	}
	
	func animationDidStart(animation: CAAnimation) {
		if let startBlock = self.startBlock {
			startBlock(animation.duration)
		}
	}
	
	func animationDidStop(animation: CAAnimation, finished: Bool) {
		if var pulseLayers = self.pulseLayer.superlayer?.pulsarLayers as? [CAShapeLayer] {
			if let index = find(pulseLayers, self.pulseLayer) {
				pulseLayers.removeAtIndex(index)
				self.pulseLayer.removeFromSuperlayer()
				if let stopBlock = self.stopBlock {
					stopBlock(finished)
				}
			}
		}
	}
}