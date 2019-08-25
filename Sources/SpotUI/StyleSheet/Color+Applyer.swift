//
//  Color+Applyer.swift
//  SpotUI
//
//  Created by Shawn Clovie on 27/9/2017.
//  Copyright © 2017 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import Spot

protocol ColorApplying {
	static func apply(to: StyleApplyable, producer: (UITraitCollection)->UIColor?, with trait: UITraitCollection)
	static func merge(to: inout [NSAttributedString.Key : Any], producer: (UITraitCollection)->UIColor?, with trait: UITraitCollection)
}

extension ColorApplying {
	static func merge(to: inout [NSAttributedString.Key : Any], producer: (UITraitCollection)->UIColor?, with trait: UITraitCollection) {}
}

struct ColorApplyer<Applying: ColorApplying>: StyleApplyer {
	var producer: (UITraitCollection)->UIColor?
	
	init(with value: Any, predefined: StyleValueSet) {
		let color = predefined.parseColor(value)
		producer = {_ in color}
	}
	
	init(_ fn: @escaping (UITraitCollection)->UIColor?) {
		producer = fn
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection) {
		Applying.apply(to: to, producer: producer, with: trait)
	}
	
	func merge(to: inout [NSAttributedString.Key : Any], with trait: UITraitCollection) {
		Applying.merge(to: &to, producer: producer, with: trait)
	}
}

struct BackgroundColorApplying: ColorApplying {
	static func apply(to: StyleApplyable, producer: (UITraitCollection) -> UIColor?, with trait: UITraitCollection) {
		switch to {
		case let view as UIView:
			view.backgroundColor = producer(trait)
		case let layer as CALayer:
			layer.backgroundColor = producer(trait)?.cgColor
		default:break
		}
	}
}

struct TextColorApplying: ColorApplying {
	static func apply(to: StyleApplyable, producer: (UITraitCollection) -> UIColor?, with trait: UITraitCollection) {
		switch to {
		case let view as UILabel:
			view.textColor = producer(trait)
		case let view as UITextField:
			view.textColor = producer(trait)
		case let view as UITextView:
			view.textColor = producer(trait)
		case let view as UIButton:
			view.setTitleColor(producer(trait), for: .normal)
		default:break
		}
	}
	
	static func merge(to: inout [NSAttributedString.Key : Any], producer: (UITraitCollection) -> UIColor?, with trait: UITraitCollection) {
		to[.foregroundColor] = producer(trait)
	}
}

struct TintColorApplying: ColorApplying {
	static func apply(to: StyleApplyable, producer: (UITraitCollection) -> UIColor?, with trait: UITraitCollection) {
		switch to {
		case let view as UIView:
			view.tintColor = producer(trait)
		case let view as UIBarButtonItem:
			view.tintColor = producer(trait)
		default:break
		}
	}
}

struct BarTintColorApplying: ColorApplying {
	static func apply(to: StyleApplyable, producer: (UITraitCollection) -> UIColor?, with trait: UITraitCollection) {
		switch to {
		case let view as UIToolbar:
			view.barTintColor = producer(trait)
		case let view as UITabBar:
			view.barTintColor = producer(trait)
		case let view as UISearchBar:
			view.barTintColor = producer(trait)
		case let view as UINavigationBar:
			view.barTintColor = producer(trait)
		default:break
		}
	}
}

struct FillColorApplying: ColorApplying {
	static func apply(to: StyleApplyable, producer: (UITraitCollection) -> UIColor?, with trait: UITraitCollection) {
		switch to {
		case let layer as CAShapeLayer:
			layer.fillColor = producer(trait)?.cgColor
		default:break
		}
	}
}

struct StrokeColorApplying: ColorApplying {
	static func apply(to: StyleApplyable, producer: (UITraitCollection) -> UIColor?, with trait: UITraitCollection) {
		switch to {
		case let layer as CAShapeLayer:
			layer.strokeColor = producer(trait)?.cgColor
		default:break
		}
	}
}

// MARK: - Stateful

struct StatefulTitleColorApplyer: StyleApplyer {
	var states: Set<UIControl.State>
	var producer: (UIControl.State, UITraitCollection)->UIColor?
	
	init(with value: Any, predefined: StyleValueSet) {
		let colorSet = predefined.parseStatefulColors(with: value)
		states = Set(colorSet.keys)
		producer = { (state, _) in colorSet[state] ?? nil}
	}
	
	init(for states: Set<UIControl.State> = [.normal],
		 _ fn: @escaping (UIControl.State, UITraitCollection)->UIColor?) {
		producer = fn
		self.states = states
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection) {
		guard let view = to as? UIButton else {return}
		for state in states {
			view.setTitleColor(producer(state, trait), for: state)
		}
	}
}
#endif
