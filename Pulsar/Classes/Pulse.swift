//
//  Pulse.swift
//  Pulsar
//
//  Created by Vincent Esche on 3/5/19.
//  Copyright © 2019 Regexident. All rights reserved.
//

import QuartzCore

public class Pulse {
    public typealias StartClosure = (TimeInterval) -> ()
    public typealias StopClosure = (Bool) -> ()
    
    public var borderColors: [CGColor]
    public var backgroundColors: [CGColor]
    public var frame: CGRect
    public var path: CGPath
    public var duration: TimeInterval = 1.0
    public var repeatDelay: TimeInterval = 0.0
    public var repeatCount: Int = 0
    public var lineWidth: CGFloat = 3.0
    public var transformBefore: CATransform3D = CATransform3DIdentity
    public var transformAfter: CATransform3D
    public var startBlock: StartClosure? = nil
    public var stopBlock: StopClosure? = nil
    
    init(_ layer: CALayer) {
        self.borderColors = Pulse.defaultBorderColors(for: layer)
        self.backgroundColors = Pulse.defaultBackgroundColors(for: layer)
        self.frame = Pulse.defaultFrame(for: layer)
        self.path = Pulse.defaultPath(for: layer)
        self.transformAfter = Pulse.defaultTransformAfter(for: layer)
    }
    
    private class func defaultBackgroundColors(for layer: CALayer) -> [CGColor] {
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
    
    private class func defaultBorderColors(for layer: CALayer) -> [CGColor] {
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
    
    private class func defaultFrame(for layer: CALayer) -> CGRect {
        return layer.bounds
    }
    
    private class func defaultPath(for layer: CALayer) -> CGPath {
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
    
    private class func defaultTransformAfter(for layer: CALayer) -> CATransform3D {
        let anchorPoint = layer.anchorPoint
        var transform = CATransform3DIdentity
        transform = CATransform3DTranslate(transform, anchorPoint.x, anchorPoint.y, 0.0);
        transform = CATransform3DScale(transform, 2.0, 2.0, 1.0);
        transform = CATransform3DTranslate(transform, -anchorPoint.x, -anchorPoint.y, 0.0);
        return transform
    }
}
