//
//  ViewController.swift
//  PulsarDemo
//
//  Created by Vincent Esche on 2/6/15.
//  Copyright (c) 2015 Vincent Esche. All rights reserved.
//

import UIKit

import Pulsar

func colorsWithHalfOpacity(colors: [CGColor]) -> [CGColor] {
	return colors.map({ CGColorCreateCopyWithAlpha($0, CGColorGetAlpha($0) * 0.5) })
}

class ViewController: UIViewController {

	@IBOutlet var containerView: UIView!
	@IBOutlet var activityIndicatorView: UIActivityIndicatorView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		UIApplication.sharedApplication().statusBarStyle = .LightContent
		
		self.view.backgroundColor = UIColor.lightGrayColor()
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		self.addRepeatingPulseToProgressIndicator()
		self.activityIndicatorView.startAnimating()
	}
	
	func addRepeatingPulseToProgressIndicator() {
		self.activityIndicatorView.layer.addPulse { builder in
			builder.borderColors = [UIColor.blackColor().CGColor]
			builder.backgroundColors = colorsWithHalfOpacity(builder.borderColors)
			builder.path = UIBezierPath(ovalInRect: self.activityIndicatorView.bounds).CGPath
			builder.duration *= 2.0
			builder.repeatCount = Int.max
			builder.lineWidth = 2.0;
			builder.backgroundColors = []
		}
	}

	@IBAction func didTriggerActionOnStarButton(sender: StarButton) {
		sender.layer.addPulse { builder in
			builder.borderColors = [
				UIColor.greenColor().CGColor,
				UIColor.yellowColor().CGColor,
				UIColor.yellowColor().CGColor,
				UIColor.redColor().CGColor
			]
			builder.backgroundColors = colorsWithHalfOpacity(builder.borderColors)
		}
	}
	
	@IBAction func didTriggerActionOnRoundedRectButton(sender: RoundedRectButton) {
		sender.layer.addPulse()
	}
	
	@IBAction func didTriggerActionOnCircleButton(sender: CircleButton) {
		sender.layer.addPulse { builder in
			builder.borderColors = [
				UIColor(hue: CGFloat(rand()) / CGFloat(RAND_MAX), saturation: 1.0, brightness: 1.0, alpha: 1.0).CGColor
			]
			builder.backgroundColors = colorsWithHalfOpacity(builder.borderColors)
		}
	}
	
	@IBAction func didTriggerActionOnSlider(sender: UISlider) {
		let subviews = sender.subviews
		let view = subviews[2] as! UIView
		
		let delayTime = dispatch_time(DISPATCH_TIME_NOW,
			Int64(0.2 * Double(NSEC_PER_SEC)))
		dispatch_after(delayTime, dispatch_get_main_queue()) {
			let bounds = view.bounds
			let path = CGPathCreateWithEllipseInRect(bounds, nil)
			let saturation = CGFloat(sender.value)
			view.layer.addPulse { builder in
				builder.borderColors = [UIColor(hue: 0.6, saturation: saturation, brightness: 1.0, alpha: 1.0).CGColor]
				builder.backgroundColors = colorsWithHalfOpacity(builder.borderColors)
				builder.path = UIBezierPath(ovalInRect: bounds).CGPath
			}
		}
	}
	
	@IBAction func didTriggerActionOnSwitch(sender: UISwitch) {
		let internalSubview = sender.subviews.first as! UIView
		let subviews = internalSubview.subviews
		let view = subviews[3] as! UIView
		let delayTime = dispatch_time(DISPATCH_TIME_NOW,
			Int64(0.4 * Double(NSEC_PER_SEC)))
		dispatch_after(delayTime, dispatch_get_main_queue()) {
			var bounds = view.bounds
			bounds = CGRectMake(
				CGRectGetMinX(bounds) + (CGRectGetWidth(bounds) - CGRectGetHeight(bounds)) / 2,
				CGRectGetMinY(bounds),
				CGRectGetHeight(bounds),
				CGRectGetHeight(bounds)
			)
			view.layer.addPulse { builder in
				builder.borderColors = [(sender.on) ? UIColor.greenColor().CGColor : UIColor.whiteColor().CGColor]
				builder.backgroundColors = colorsWithHalfOpacity(builder.borderColors)
				builder.path = UIBezierPath(ovalInRect: bounds).CGPath
			}
		}
	}

}