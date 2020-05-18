//
//  MaskedCornersApplyer.swift
//  SpotUI iOS
//
//  Created by Shawn Clovie on 18/5/2020.
//  Copyright © 2020 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import Spot

struct MaskedCornersApplyer: StyleApplyer {
	
	var value: CACornerMask
	
	init?(with value: Any, predefined: StyleValueSet) {
		guard let value = predefined.value(for: value) as? [String],
			!value.isEmpty
			else {return nil}
		self.value = []
		value.forEach{
			switch $0 {
			case "left-top":		self.value.insert(.layerMinXMinYCorner)
			case "right-top":		self.value.insert(.layerMaxXMinYCorner)
			case "left-bottom":		self.value.insert(.layerMinXMaxYCorner)
			case "right-bottom":	self.value.insert(.layerMaxXMaxYCorner)
			default:break
			}
		}
	}
	
	init(_ value: CACornerMask) {
		self.value = value
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection?) {
		if #available(iOS 11.0, *) {
			switch to {
			case let view as UIView:
				view.layer.maskedCorners = value
			case let layer as CALayer:
				layer.maskedCorners = value
			default:break
			}
		}
	}
}
#endif
