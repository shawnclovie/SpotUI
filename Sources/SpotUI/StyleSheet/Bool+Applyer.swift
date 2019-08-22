//
//  StyleBooleanValue.swift
//  SpotUI
//
//  Created by Shawn Clovie on 27/9/2017.
//  Copyright © 2017 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit

struct MaskToBoundsApplyer: StyleApplyer {
	var value: Bool
	
	init(with value: Any, predefined: StyleValueSet) {
		self.value = predefined.pareseBool(value)
	}
	
	init(_ value: Bool) {
		self.value = value
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection) {
		switch to {
		case let view as UIView:
			view.layer.masksToBounds = value
		case let layer as CALayer:
			layer.masksToBounds = value
		default:break
		}
	}
}

struct UserInteractionEnabledApplyer: StyleApplyer {
	var value: Bool
	
	init(with value: Any, predefined: StyleValueSet) {
		self.value = predefined.pareseBool(value)
	}
	
	init(_ value: Bool) {
		self.value = value
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection) {
		(to as? UIView)?.isUserInteractionEnabled = value
	}
}
#endif
