//
//  AlignmentApplyer.swift
//  SpotUI
//
//  Created by Shawn Clovie on 27/9/2017.
//  Copyright © 2017 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit

struct TextAlignmentApplyer: StyleApplyer {
	var value: NSTextAlignment
	
	init(with value: Any, predefined: StyleValueSet) {
		switch predefined.value(for: value) as? String ?? "" {
		case "justified":	self.value = .justified
		case "natural":		self.value = .natural
		case "right":		self.value = .right
		case "center":		self.value = .center
		default:			self.value = .left
		}
	}
	
	init(_ value: NSTextAlignment) {
		self.value = value
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection?) {
		switch to {
		case let view as UILabel:
			view.textAlignment = value
		case let view as UITextView:
			view.textAlignment = value
		case let view as UITextField:
			view.textAlignment = value
		case let view as UIButton:
			let align: UIControl.ContentHorizontalAlignment
			switch value {
			case .right:		align = .right
			case .center:		align = .center
			case .justified:	align = .fill
			case .natural:
				if #available(iOS 11.0, *) {
					align = .leading
				} else {
					fallthrough
				}
			case .left:			fallthrough
			@unknown default:	align = .left
			}
			view.contentHorizontalAlignment = align
		default:break
		}
	}
	
	func merge(to: inout [NSAttributedString.Key : Any], with trait: UITraitCollection?) {
		let style = to[.paragraphStyle] as? NSMutableParagraphStyle ?? .init()
		style.alignment = value
		to[.paragraphStyle] = style
	}
}

struct VerticalAlignmentApplyer: StyleApplyer {
	var value: UIControl.ContentVerticalAlignment
	
	init?(with value: Any, predefined: StyleValueSet) {
		switch predefined.value(for: value) as? String ?? "" {
		case "fill":	self.value = .fill
		case "bottom":	self.value = .bottom
		case "top":		self.value = .top
		default:		self.value = .center
		}
	}
	
	init(_ value: UIControl.ContentVerticalAlignment) {
		self.value = value
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection?) {
		switch to {
		case let view as UIControl:
			view.contentVerticalAlignment = value
		default:break
		}
	}
}

struct StackAlignmentApplyer: StyleApplyer {
	var value: UIStackView.Alignment
	
	init(_ v: UIStackView.Alignment) {
		value = v
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection?) {
		(to as? UIStackView)?.alignment = value
	}
}

struct StackDistributionApplyer: StyleApplyer {
	var value: UIStackView.Distribution
	
	init(_ v: UIStackView.Distribution) {
		value = v
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection?) {
		(to as? UIStackView)?.distribution = value
	}
}
#endif
