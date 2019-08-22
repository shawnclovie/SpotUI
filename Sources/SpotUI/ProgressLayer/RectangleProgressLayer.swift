//
//  RectangleProgressLayer.swift
//  SpotUI
//
//  Created by Shawn Clovie on 7/2/16.
//  Copyright © 2016 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

open class RectangleProgressLayer: ProgressLayer {
	public static let DefaultOpacity: Float = 0.4
	
	public enum Direction {
		case leftToRight, rightToLeft, topToBottom, bottomToTop
	}
	
	open var direction = Direction.leftToRight {
		didSet {
			update()
		}
	}
	
	open var size = CGSize.zero {
		didSet {
			bounds.size = size
			update()
		}
	}
	
	public convenience init(direction: Direction,
	                        size: CGSize,
	                        _ color: CGColor? = nil) {
		self.init()
		self.direction = direction
		fillColor = color
		opacity = RectangleProgressLayer.DefaultOpacity
		self.size = size
	}
	
	open override func update() {
		path = path(withPercentage: percentage)
	}
	
	private func path(withPercentage percent: Double) -> CGPath {
		var rect = CGRect(origin: .zero, size: size)
		switch direction {
		case .leftToRight:
			rect.size.width *= CGFloat(percent)
		case .rightToLeft:
			rect.size.width *= CGFloat(percent)
			rect.origin.x = size.width - rect.width
		case .bottomToTop:
			rect.size.height *= CGFloat(percent)
			#if !os(OSX)
			rect.origin.y = size.height - rect.height
			#endif
		case .topToBottom:
			rect.size.height *= CGFloat(percent)
			#if os(OSX)
			rect.origin.y = size.height - rect.height
			#endif
		}
		#if canImport(UIKit)
		return UIBezierPath(rect: rect).cgPath
		#else
		return CGPath(rect: rect, transform: nil)
		#endif
	}
	
	override var animation: CABasicAnimation {
		let ani = CABasicAnimation(keyPath: "path")
		ani.fromValue = path(withPercentage: 0)
		ani.toValue = path(withPercentage: 1)
		return ani
	}
}
