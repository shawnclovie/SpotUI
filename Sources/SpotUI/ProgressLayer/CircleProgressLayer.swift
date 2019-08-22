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
	/**
	Create an shape layer with arc bezier path.
	
	- parameter radius:      Inner radius
	- parameter lineWidth:   Border line width
	- parameter color:       Stroke color, default is [black a0.4].
	- parameter trackAlpha:  Track layer would use same color of above with the alpha.
	*/
	public convenience init(radius: CGFloat,
	                        lineWidth: CGFloat,
	                        _ color: UIColor? = nil,
	                        trackAlpha: CGFloat = 0.2) {
		self.init()
		let color = color ?? .init(white: 0, alpha: 0.4)
		path = UIBezierPath.spot(arcPathInnerRadius: radius,
								 lineWidth: lineWidth,
								 startAngle: -90, endAngle: 270.00001,
								 clockwise: true).cgPath
		fillColor = nil
		strokeColor = color.cgColor
		lineCap = .butt
		self.lineWidth = CGFloat(lineWidth)
		update()
		let track = CAShapeLayer()
		track.path = path
		track.fillColor = nil
		track.strokeColor = color.withAlphaComponent(trackAlpha).cgColor
		track.lineCap = lineCap
		track.lineWidth = self.lineWidth
		addSublayer(track)
	}
	
	open override func update() {
		strokeEnd = CGFloat(percentage)
	}
	
	override var animation: CABasicAnimation {
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
