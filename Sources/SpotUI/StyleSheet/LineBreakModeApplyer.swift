//
//  LineBreakModeApplyer.swift
//  SpotUI
//
//  Created by Shawn Clovie on 27/9/2017.
//  Copyright © 2017 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit

struct LineBreakModeApplyer: StyleApplyer {
	var value: NSLineBreakMode
	
	init(with value: Any, predefined: StyleValueSet) {
		switch predefined.value(for: value) as? String ?? "" {
		case "char-wrapping":		self.value = .byCharWrapping
		case "clipping":			self.value = .byClipping
		case "truncating-head":		self.value = .byTruncatingHead
		case "truncating-middle":	self.value = .byTruncatingMiddle
		case "truncating-tail":		self.value = .byTruncatingTail
		default:					self.value = .byWordWrapping
		}
	}
	
	init(_ value: NSLineBreakMode) {
		self.value = value
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection) {
		switch to {
		case let view as UILabel:
			view.lineBreakMode = value
		case let view as UITextView:
			view.textContainer.lineBreakMode = value
		case let view as UIButton:
			view.titleLabel?.lineBreakMode = value
		default:break
		}
	}
	
	func merge(to: inout [NSAttributedString.Key : Any], with trait: UITraitCollection) {
		let style = to[.paragraphStyle] as? NSMutableParagraphStyle ?? .init()
		style.lineBreakMode = value
		to[.paragraphStyle] = style
	}
}
#endif
