//
//  CircleButton.swift
//  Pulsar
//
//  Created by Vincent Esche on 2/6/15.
//  Copyright (c) 2015 Vincent Esche. All rights reserved.
//

import UIKit

class CircleButton: UIButton {
	required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
		self.layer.cornerRadius = CircleButton.cornerRadiusForRect(self.bounds)
		self.applyTheme()
	}
	
	class func cornerRadiusForRect(rect: CGRect) -> CGFloat {
		return min(CGRectGetWidth(rect), CGRectGetHeight(rect)) / 2.0
	}
}