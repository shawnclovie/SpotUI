//
//  BorderApplyer.swift
//  SpotUI
//
//  Created by Shawn Clovie on 27/9/2017.
//  Copyright © 2017 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import Spot

public struct StyleBorder {
	
	public static var clear: Self {.init(.clear, width: 0)}
	
	public var color: UIColor
	public var width: CGFloat
	
	public init(_ color: UIColor, width: CGFloat) {
		self.color = color
		self.width = width
	}
}

struct BorderApplyer: StyleApplyer {
	var producer: (UITraitCollection?)->StyleBorder
	
	init(with value: Any, predefined: StyleValueSet) {
		var border = StyleBorder.clear
		if let data = predefined.value(for: value) as? [AnyHashable: Any] {
			if let vColor = predefined.value(for: data["color"]) as? String,
				let dColor = DecimalColor(hexARGB: vColor) {
				border.color = dColor.colorValue
			}
			border.width = CGFloat(predefined.parseDouble(data["width"]))
		}
		producer = {_ in border}
	}
	
	init(_ fn: @escaping (UITraitCollection?)->StyleBorder) {
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
		let border = producer(trait)
		layer.borderColor = border.color.cgColor
		layer.borderWidth = border.width
	}
}
#endif
