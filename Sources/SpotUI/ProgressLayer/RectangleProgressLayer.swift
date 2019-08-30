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
	
	public enum Direction {
		case leftToRight, rightToLeft, topToBottom, bottomToTop
	}
	
	public override init() {
		super.init()
	}
	
	public override init(layer: Any) {
		super.init(layer: layer)
		if let layer = layer as? RectangleProgressLayer {
			bounds = layer.bounds
			opacity = layer.opacity
			fillColor = layer.fillColor
			direction = layer.direction
		}
	}
	
	required public convenience init?(coder: NSCoder) {
		self.init()
	}
	
	public var direction: Direction = .leftToRight {
		didSet {
			update()
		}
	}
	
	public func set(direction: Direction, size: CGSize, _ color: CGColor? = nil) {
		fillColor = color
		self.direction = direction
		bounds.size = size
		update()
	}
	
	open override func update() {
		path = makePath(percentage: percentage)
	}
	
	private func makePath(percentage: Double) -> CGPath {
		let size = bounds.size
		var rect = CGRect(origin: .zero, size: size)
		switch direction {
		case .leftToRight:
			rect.size.width *= CGFloat(percentage)
		case .rightToLeft:
			rect.size.width *= CGFloat(percentage)
			rect.origin.x = size.width - rect.width
		case .bottomToTop:
			rect.size.height *= CGFloat(percentage)
			#if !os(OSX)
			rect.origin.y = size.height - rect.height
			#endif
		case .topToBottom:
			rect.size.height *= CGFloat(percentage)
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
	
	open override var animation: CABasicAnimation {
		let ani = CABasicAnimation(keyPath: "path")
		ani.fromValue = makePath(percentage: 0)
		ani.toValue = makePath(percentage: 1)
		return ani
	}
}
