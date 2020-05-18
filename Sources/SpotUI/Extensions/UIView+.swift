//
//  UIView+.swift
//  SpotUI
//
//  Created by Shawn Clovie on 16/11/2016.
//  Copyright © 2016 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import Spot

extension Suffix where Base: UIView {
	/// Render image with current view
	///
	/// - Returns: Image or nil while render failed
	public func renderImage(opaque: Bool = false, scale: CGFloat = 0) -> UIImage? {
		var image: UIImage?
		UIGraphicsBeginImageContextWithOptions(base.bounds.size, opaque, scale)
		if let ctx = UIGraphicsGetCurrentContext() {
			base.layer.render(in: ctx)
			image = UIGraphicsGetImageFromCurrentImageContext()
		}
		UIGraphicsEndImageContext()
		return image
	}
	
	public func addHorizontalLine(with view: UIView, _ toAttr: NSLayoutConstraint.Attribute, spacing: CGFloat = 0, color: UIColor = .gray) {
		let line = UIView()
		line.backgroundColor = color
		base.addSubview(line)
		line.spot.constraint(.height).with(constant: 1 / UIScreen.main.scale)
		base.spot.constraint(line, .top).with(view, toAttr, constant: spacing)
		base.spot.constraints(line, attributes: [.left, .right])
	}
	
	/// Set round corner mask to view, should call after the view did layout
	/// - Parameters:
	///   - corners: Corner position
	///   - radius: Radius for each corner
	public func setRoundCornerMask(corners: UIRectCorner, radius: CGFloat) {
		let path = UIBezierPath(roundedRect: base.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
		let mask = CAShapeLayer()
		mask.path = path.cgPath
		base.layer.mask = mask
	 }
}
#endif
