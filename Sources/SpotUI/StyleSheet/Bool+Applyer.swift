//
//  StyleBooleanValue.swift
//  SpotUI
//
//  Created by Shawn Clovie on 27/9/2017.
//  Copyright © 2017 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit

protocol BoolApplying {
	static func apply(to: StyleApplyable, value: Bool, with trait: UITraitCollection)
}

struct BoolApplyer<Applying: BoolApplying>: StyleApplyer {
	var value: Bool
	
	init(with value: Any, predefined: StyleValueSet) {
		self.value = predefined.pareseBool(value)
	}
	
	init(_ value: Bool) {
		self.value = value
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection) {
		Applying.apply(to: to, value: value, with: trait)
	}
}

struct HiddenApplying: BoolApplying {
	static func apply(to: StyleApplyable, value: Bool, with trait: UITraitCollection) {
		switch to {
		case let view as UIView:	view.isHidden = value
		case let layer as CALayer:	layer.isHidden = value
		default:break
		}
	}
}

struct MaskToBoundsApplying: BoolApplying {
	static func apply(to: StyleApplyable, value: Bool, with trait: UITraitCollection) {
		switch to {
		case let view as UIView:
			view.layer.masksToBounds = value
		case let layer as CALayer:
			layer.masksToBounds = value
		default:break
		}
	}
}

struct MomentaryApplying: BoolApplying {
	static func apply(to: StyleApplyable, value: Bool, with trait: UITraitCollection) {
		(to as? UISegmentedControl)?.isMomentary = value
	}
}

struct UserInteractionEnabledApplying: BoolApplying {
	static func apply(to: StyleApplyable, value: Bool, with trait: UITraitCollection) {
		(to as? UIView)?.isUserInteractionEnabled = value
	}
}
#endif
