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

struct BackgroundColorApplyer: StyleApplyer {
	var producer: (UITraitCollection)->UIColor?
	
	init(with value: Any, predefined: StyleValueSet) {
		let color = predefined.parseColor(value)
		producer = {_ in color}
	}
	
	init(_ fn: @escaping (UITraitCollection)->UIColor?) {
		producer = fn
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection) {
		switch to {
		case let view as UIView:
			view.backgroundColor = producer(trait)
		case let layer as CALayer:
			layer.backgroundColor = producer(trait)?.cgColor
		default:break
		}
	}
}

struct TextColorApplyer: StyleApplyer {
	var producer: (UITraitCollection)->UIColor?
	
	init(with value: Any, predefined: StyleValueSet) {
		let color = predefined.parseColor(value)
		producer = {_ in color}
	}
	
	init(_ fn: @escaping (UITraitCollection)->UIColor?) {
		producer = fn
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection) {
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
	
	func merge(to: inout [NSAttributedString.Key : Any], with trait: UITraitCollection) {
		to[.foregroundColor] = producer(trait)
	}
}

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

struct TintColorApplyer: StyleApplyer {
	var producer: (UITraitCollection)->UIColor?
	
	init(with value: Any, predefined: StyleValueSet) {
		let color = predefined.parseColor(value)
		producer = {_ in color}
	}
	
	init(_ fn: @escaping (UITraitCollection)->UIColor?) {
		producer = fn
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection) {
		switch to {
		case let view as UIView:
			view.tintColor = producer(trait)
		case let view as UIBarButtonItem:
			view.tintColor = producer(trait)
		default:break
		}
	}
}

struct BarTintColorApplyer: StyleApplyer {
	var producer: (UITraitCollection)->UIColor?
	
	init(with value: Any, predefined: StyleValueSet) {
		let color = predefined.parseColor(value)
		producer = {_ in color}
	}
	
	init(_ fn: @escaping (UITraitCollection)->UIColor?) {
		producer = fn
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection) {
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

struct FillColorApplyer: StyleApplyer {
	var producer: (UITraitCollection)->CGColor?
	
	init(with value: Any, predefined: StyleValueSet) {
		let color = predefined.parseColor(value)?.cgColor
		producer = {_ in color}
	}
	
	init(_ fn: @escaping (UITraitCollection)->CGColor?) {
		producer = fn
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection) {
		switch to {
		case let layer as CAShapeLayer:
			layer.fillColor = producer(trait)
		default:break
		}
	}
}

struct StrokeColorApplyer: StyleApplyer {
	var producer: (UITraitCollection)->CGColor?
	
	init(with value: Any, predefined: StyleValueSet) {
		let color = predefined.parseColor(value)?.cgColor
		producer = {_ in color}
	}
	
	init(_ fn: @escaping (UITraitCollection)->CGColor?) {
		producer = fn
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection) {
		switch to {
		case let layer as CAShapeLayer:
			layer.strokeColor = producer(trait)
		default:break
		}
	}
}
#endif
