//
//  StarButton.swift
//  Pulsar
//
//  Created by Vincent Esche on 2/6/15.
//  Copyright (c) 2015 Vincent Esche. All rights reserved.
//

import UIKit

class StarButton: UIButton {
	
	required init(coder decoder: NSCoder) {
		super.init(coder: decoder)
		let shapeLayer = self.layer as! CAShapeLayer
		shapeLayer.path = StarButton.pathForRect(self.bounds)
		self.applyTheme()
	}
	
	override class func layerClass() -> AnyClass {
		return CAShapeLayer.self
	}
	
	class func pathForRect(rect: CGRect) -> CGPath {
		let origin = rect.origin
		let width = CGRectGetWidth(rect)
		let height = CGRectGetHeight(rect)
		var transform = CGAffineTransformMakeTranslation(-origin.x, -origin.y)
		let path = CGPathCreateMutable()
		CGPathMoveToPoint(path, &transform, width * 0.5000, height * 0.0200)
		CGPathAddLineToPoint(path, &transform, width * 0.6834, height * 0.2876)
		CGPathAddLineToPoint(path, &transform, width * 0.9945, height * 0.3793)
		CGPathAddLineToPoint(path, &transform, width * 0.7967, height * 0.6364)
		CGPathAddLineToPoint(path, &transform, width * 0.8056, height * 0.9607)
		CGPathAddLineToPoint(path, &transform, width * 0.5000, height * 0.8520)
		CGPathAddLineToPoint(path, &transform, width * 0.1944, height * 0.9607)
		CGPathAddLineToPoint(path, &transform, width * 0.2033, height * 0.6364)
		CGPathAddLineToPoint(path, &transform, width * 0.0055, height * 0.3793)
		CGPathAddLineToPoint(path, &transform, width * 0.3166, height * 0.2876)
		CGPathCloseSubpath(path)
		return path
	}
}
