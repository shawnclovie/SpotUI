//
//  ShadowApplyer.swift
//  SpotUI
//
//  Created by Shawn Clovie on 27/9/2017.
//  Copyright © 2017 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import Spot

public struct StyleShadow {
	public var color: UIColor
	public var offset: CGSize
	public var opacity: Float
	public var radius: CGFloat
	
	public init(color: UIColor = .clear, offset: CGSize = .zero, opacity: Float = 1, radius: CGFloat = 0) {
		self.color = color
		self.offset = offset
		self.opacity = opacity
		self.radius = radius
	}
}

struct ShadowApplyer: StyleApplyer {
	var producer: (UITraitCollection?)->StyleShadow
	
	init?(with value: Any, predefined: StyleValueSet) {
		guard let data = predefined.value(for: value) as? [AnyHashable: Any],
			let value = predefined.value(for: data["color"]) as? String,
			let color = DecimalColor(hexARGB: value) else {
				return nil
		}
		let shadow = StyleShadow(
			color: color.colorValue,
			offset: AnyToCGSize(predefined.value(for: data["offset"])) ?? .zero,
			opacity: Float(predefined.parseDouble(data["opacity"], defaultValue: 1)),
			radius: CGFloat(predefined.parseDouble(data["radius"])))
		producer = {_ in shadow}
	}
	
	init(_ fn: @escaping (UITraitCollection?)->StyleShadow) {
		producer = fn
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection?) {
		switch to {
		case let view as UIView:
			apply(to: view.layer, with: trait)
		case let layer as CALayer:
			apply(to: layer, with: trait)
		default:break
		}
	}
	
	private func apply(to layer: CALayer, with trait: UITraitCollection?) {
		let shadow = producer(trait)
		layer.shadowColor = shadow.color.cgColor
		layer.shadowOffset = shadow.offset
		layer.shadowOpacity = shadow.opacity
		layer.shadowRadius = shadow.radius
	}
	
	func merge(to: inout [NSAttributedString.Key : Any], with trait: UITraitCollection?) {
		let value = producer(trait)
		let shadow = NSShadow()
		var color = value.color
		if value.opacity < 1 {
			color = color.withAlphaComponent(CGFloat(value.opacity))
		}
		shadow.shadowColor = color
		shadow.shadowOffset = value.offset
		shadow.shadowBlurRadius = value.radius
		to[.shadow] = shadow
	}
}
#endif
