//
//  ViewController.swift
//  PulsarDemo
//
//  Created by Vincent Esche on 2/6/15.
//  Copyright (c) 2015 Vincent Esche. All rights reserved.
//

import UIKit

import Pulsar

func colorsWithHalfOpacity(_ colors: [CGColor]) -> [CGColor] {
	return colors.map({ $0.copy(alpha: $0.alpha * 0.5)! })
}

class ViewController: UIViewController {

	@IBOutlet var containerView: UIView!
	@IBOutlet var activityIndicatorView: UIActivityIndicatorView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		UIApplication.shared.statusBarStyle = .lightContent
		
		self.view.backgroundColor = UIColor.lightGray
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.addRepeatingPulseToProgressIndicator()
		self.activityIndicatorView.startAnimating()
	}
	
	func addRepeatingPulseToProgressIndicator() {
		let _ = self.activityIndicatorView.layer.addPulse { builder in
			builder.borderColors = [UIColor.clear.cgColor, UIColor.black.cgColor]
			builder.backgroundColors = colorsWithHalfOpacity(builder.borderColors)
			builder.path = UIBezierPath(ovalIn: self.activityIndicatorView.bounds).cgPath
			builder.transformBefore = CATransform3DMakeScale(0.65, 0.65, 0.0)
			builder.duration = 2.0
			builder.repeatDelay = 0.0
			builder.repeatCount = Int.max
			builder.lineWidth = 2.0
			builder.backgroundColors = []
		}
	}

	@IBAction func didTriggerActionOnStarButton(_ sender: StarButton) {
		let _ = sender.layer.addPulse { builder in
			builder.borderColors = [
				UIColor.green.cgColor,
				UIColor.yellow.cgColor,
				UIColor.yellow.cgColor,
				UIColor.red.cgColor
			]
			builder.backgroundColors = colorsWithHalfOpacity(builder.borderColors)
		}
	}
	
	@IBAction func didTriggerActionOnRoundedRectButton(_ sender: RoundedRectButton) {
		let _ = sender.layer.addPulse()
	}
	
	@IBAction func didTriggerActionOnCircleButton(_ sender: CircleButton) {
		let _ = sender.layer.addPulse { builder in
			builder.borderColors = [
				UIColor(hue: CGFloat(arc4random()) / CGFloat(RAND_MAX), saturation: 1.0, brightness: 1.0, alpha: 1.0).cgColor
			]
			builder.backgroundColors = colorsWithHalfOpacity(builder.borderColors)
		}
	}
	
	@IBAction func didTriggerActionOnSlider(_ sender: UISlider) {
		let subviews = sender.subviews
		let view = subviews[2]
		let delayTime = DispatchTime.now() + Double(Int64(0.2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
		DispatchQueue.main.asyncAfter(deadline: delayTime) {
			let bounds = view.bounds
			let path = CGPath(ellipseIn: bounds, transform: nil)
			let saturation = CGFloat(sender.value)
			let _ = view.layer.addPulse { builder in
				builder.borderColors = [UIColor(hue: 0.6, saturation: saturation, brightness: 1.0, alpha: 1.0).cgColor]
				builder.backgroundColors = colorsWithHalfOpacity(builder.borderColors)
				builder.path = path
			}
		}
	}
	
	@IBAction func didTriggerActionOnSwitch(_ sender: UISwitch) {
		let internalSubview = sender.subviews.first!
		let subviews = internalSubview.subviews
		let view = subviews[3]
		let delayTime = DispatchTime.now() + Double(Int64(0.4 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
		DispatchQueue.main.asyncAfter(deadline: delayTime) {
			var bounds = view.bounds
			bounds = CGRect(
				x: bounds.minX + (bounds.width - bounds.height) / 2,
				y: bounds.minY,
				width: bounds.height,
				height: bounds.height
			)
			let _ = view.layer.addPulse { builder in
				builder.borderColors = [(sender.isOn) ? UIColor.green.cgColor : UIColor.white.cgColor]
				builder.backgroundColors = colorsWithHalfOpacity(builder.borderColors)
				builder.path = UIBezierPath(ovalIn: bounds).cgPath
			}
		}
	}

}
