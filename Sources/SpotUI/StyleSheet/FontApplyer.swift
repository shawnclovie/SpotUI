//
//  FontApplyer.swift
//  SpotUI
//
//  Created by Shawn Clovie on 27/9/2017.
//  Copyright © 2017 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit

struct FontApplyer: StyleApplyer {
	static func parseFontWeight(_ value: Any) -> UIFont.Weight {
		switch value {
		case var value as Double:
			if (0.0...1.0).contains(value) {
				value *= 100
			}
			return .init(rawValue: CGFloat(value))
		case let value as String:
			switch value {
			case "ultraLight":	return .ultraLight
			case "thin":		return .thin
			case "light":		return .light
			case "medium":		return .medium
			case "semibold":	return .semibold
			case "bold":		return .bold
			case "heavy":		return .heavy
			case "black":		return .black
			default:break
			}
		default:break
		}
		return .regular
	}
	
	var producer: (UITraitCollection?)->UIFont
	
	init?(with value: Any, predefined: StyleValueSet) {
		guard let data = predefined.value(for: value) as? [AnyHashable: Any] else {
			return nil
		}
		let size = predefined.parseDouble(data["size"])
		guard size > 0 else {return nil}
		let font: UIFont
		let fontSize = CGFloat(size)
		if let family = predefined.value(for: data["family"]) as? String,
			!family.isEmpty,
			let _font = UIFont(name: family, size: fontSize) {
			font = _font
		} else {
			var weight: UIFont.Weight = .regular
			if let value = predefined.value(for: data["weight"]) {
				weight = Self.parseFontWeight(value)
			}
			font = .systemFont(ofSize: fontSize, weight: weight)
		}
		producer = {_ in font}
	}
	
	init(_ fn: @escaping (UITraitCollection?)->UIFont) {
		producer = fn
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection?) {
		switch to {
		case let view as UILabel:
			view.font = producer(trait)
		case let view as UIButton:
			view.titleLabel?.font = producer(trait)
		case let view as UITextView:
			view.font = producer(trait)
		default:break
		}
	}
	
	func merge(to: inout [NSAttributedString.Key : Any], with trait: UITraitCollection?) {
		to[.font] = producer(trait)
	}
}
#endif
