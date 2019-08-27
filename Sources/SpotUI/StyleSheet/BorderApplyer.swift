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

struct BorderApplyer: StyleApplyer {
	var producer: (UITraitCollection)->(UIColor?, CGFloat)
	
	init(with value: Any, predefined: StyleValueSet) {
		var color: UIColor?
		var width: CGFloat = 0
		if let data = predefined.value(for: value) as? [AnyHashable: Any] {
			if let vColor = predefined.value(for: data["color"]) as? String,
				let dColor = DecimalColor(hexARGB: vColor) {
				color = dColor.colorValue
			} else {
				color = nil
			}
			width = CGFloat(predefined.parseDouble(data["width"]))
		}
		producer = {_ in (color, width)}
	}
	
	init(_ fn: @escaping (UITraitCollection)->(UIColor?, CGFloat)) {
		producer = fn
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection) {
		switch to {
		case let view as UIView:
			apply(to: view.layer, with: trait)
		case let layer as CALayer:
			apply(to: layer, with: trait)
		default:break
		}
	}
	
	private func apply(to layer: CALayer, with trait: UITraitCollection) {
		let (color, width) = producer(trait)
		layer.borderColor = color?.cgColor
		layer.borderWidth = width
	}
}
#endif
