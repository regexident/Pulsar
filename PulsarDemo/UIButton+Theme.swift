//
//  UIButton+Theme.swift
//  Pulsar
//
//  Created by Vincent Esche on 2/6/15.
//  Copyright (c) 2015 Vincent Esche. All rights reserved.
//

import UIKit

extension UIButton {
	func applyTheme() {
		let fillColor = UIColor(white: 0.0, alpha: 0.25).CGColor
		let borderColor = UIColor(white: 1.0, alpha: 1.0).CGColor
		if let shapeLayer = self.layer as? CAShapeLayer {
			shapeLayer.fillColor = fillColor
			shapeLayer.strokeColor = borderColor
			shapeLayer.lineWidth = 3.0
		} else {
			layer.backgroundColor = fillColor
			layer.borderColor = borderColor
			layer.borderWidth = 3.0
		}
	}
}