//
//  ProgressLayer.swift
//  SpotUI
//
//  Created by Shawn Clovie on 7/2/16.
//  Copyright © 2016 Shawn Clovie. All rights reserved.
//

import CoreGraphics
import QuartzCore

open class ProgressLayer: CAShapeLayer, CAAnimationDelegate {
	
	public var percentage = 0.0 {
		didSet {
			update()
		}
	}
	
	/// Set percentage to 0 by default without animation.
	/// - Parameter to: To percentage
	public func resetPercentage(to: Double = 0) {
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		percentage = to
		CATransaction.commit()
	}
	
	open func update() {
	}
	
	open var animation: CABasicAnimation {
		CABasicAnimation(keyPath: "bounds")
	}
	
	open func createAnimation(duration: TimeInterval) -> CABasicAnimation {
		let ani = animation
		ani.duration = duration
		ani.fillMode = .both
		ani.isRemovedOnCompletion = false
		ani.delegate = self
		add(ani, forKey: ani.keyPath)
		return ani
	}
}
