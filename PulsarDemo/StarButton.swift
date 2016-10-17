//
//  StarButton.swift
//  Pulsar
//
//  Created by Vincent Esche on 2/6/15.
//  Copyright (c) 2015 Vincent Esche. All rights reserved.
//

import UIKit

class StarButton: UIButton {

	required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
		let shapeLayer = self.layer as! CAShapeLayer
		shapeLayer.path = StarButton.pathForRect(self.bounds)
		self.applyTheme()
	}

	override class var layerClass : AnyClass {
		return CAShapeLayer.self
	}

	class func pathForRect(_ rect: CGRect) -> CGPath {
		let origin = rect.origin
		let width = rect.width
		let height = rect.height
		let transform = CGAffineTransform(translationX: -origin.x, y: -origin.y)
		let path = CGMutablePath()
        path.move(to: CGPoint(x: width * 0.5000, y: height * 0.0200), transform: transform)
		path.addLine(to: CGPoint(x: width * 0.6834, y: height * 0.2876), transform: transform)
		path.addLine(to: CGPoint(x: width * 0.9945, y: height * 0.3793), transform: transform)
		path.addLine(to: CGPoint(x: width * 0.7967, y: height * 0.6364), transform: transform)
		path.addLine(to: CGPoint(x: width * 0.8056, y: height * 0.9607), transform: transform)
		path.addLine(to: CGPoint(x: width * 0.5000, y: height * 0.8520), transform: transform)
		path.addLine(to: CGPoint(x: width * 0.1944, y: height * 0.9607), transform: transform)
		path.addLine(to: CGPoint(x: width * 0.2033, y: height * 0.6364), transform: transform)
		path.addLine(to: CGPoint(x: width * 0.0055, y: height * 0.3793), transform: transform)
		path.addLine(to: CGPoint(x: width * 0.3166, y: height * 0.2876), transform: transform)
		path.closeSubpath()
		return path
	}
}
