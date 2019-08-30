//
//  CircleProgressLayer.swift
//  SpotUI
//
//  Created by Shawn Clovie on 6/8/16.
//  Copyright © 2016 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit

open class CircleProgressLayer: ProgressLayer {
	
	public let track = CAShapeLayer()
	public private(set) var radius: CGFloat = 0
	
	public override init(layer: Any) {
		super.init(layer: layer)
		if let layer = layer as? CircleProgressLayer {
			track.strokeColor = layer.track.strokeColor
			path = layer.path
			lineWidth = layer.lineWidth
			strokeColor = layer.strokeColor
		}
	}
	
	public override init() {
		super.init()
		fillColor = nil
		lineCap = .butt
		track.fillColor = nil
		track.lineCap = lineCap
		addSublayer(track)
	}
	
	required convenience public init?(coder: NSCoder) {
		self.init()
	}
	
	/// Set bezier path with arc radius and lineWidth
	/// - Parameter radius: Inner radius
	/// - Parameter lineWidth: Border line width
	public func set(radius: CGFloat, lineWidth: CGFloat) {
		self.radius = radius
		path = UIBezierPath.spot(arcPathInnerRadius: radius,
								 lineWidth: lineWidth,
								 startAngle: -90, endAngle: 270.00001,
								 clockwise: true).cgPath
		self.lineWidth = lineWidth
		track.path = path
		track.lineWidth = lineWidth
		update()
	}
	
	/// Set stroke and track color
	/// - Parameter color: Stroke color
	/// - Parameter trackAlpha: Track layer would use same color of above with the alpha.
	public func set(color: UIColor, trackAlpha: CGFloat = 0.2) {
		strokeColor = color.cgColor
		track.strokeColor = color.withAlphaComponent(trackAlpha).cgColor
	}
	
	open override func update() {
		strokeEnd = CGFloat(percentage)
	}
	
	open override var animation: CABasicAnimation {
		let ani = CABasicAnimation(keyPath: "strokeEnd")
		ani.fromValue = CGFloat(1.0)
		ani.toValue = CGFloat(0.0)
		return ani
	}
}

extension UIBezierPath {
	/**
	Create an arc bezier path with radius as innerRadius+lineWidth/2
	
	- parameter innerRadius: Inner radius
	- parameter lineWidth:   Border line width
	- parameter startAngle:  Start angle
	- parameter endAngle:    End angle
	- parameter clockwise:   Clockwise
	*/
	public static func spot(arcPathInnerRadius innerRadius: CGFloat,
	                        lineWidth: CGFloat,
	                        startAngle: CGFloat, endAngle: CGFloat,
	                        clockwise: Bool = false) -> UIBezierPath {
		let inst: UIBezierPath
		let radius = innerRadius + lineWidth / 2
		let startAngle = startAngle * .pi / 180
		let endAngle = endAngle * .pi / 180
		#if os(OSX)
		inst = .init()
		inst.appendArc(withCenter: .zero, radius: radius,
					   startAngle: startAngle, endAngle: endAngle,
					   clockwise: clockwise)
		#else
		inst = .init(arcCenter: .zero, radius: radius,
					 startAngle: startAngle, endAngle: endAngle,
					 clockwise: clockwise)
		#endif
		return inst
	}
}
#endif
