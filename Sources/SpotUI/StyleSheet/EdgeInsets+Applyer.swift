//
//  EdgeInsets+Applyer.swift
//  SpotUI
//
//  Created by Shawn Clovie on 27/9/2017.
//  Copyright © 2017 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit

struct ParagraphSpacingApplyer: StyleApplyer {
	
	var value: UIEdgeInsets
	
	init?(with value: Any, predefined: StyleValueSet) {
		self.value = UIEdgeInsets.spot(predefined.value(for: value)) ?? .zero
	}
	
	init(_ v: UIEdgeInsets) {
		value = v
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection) {
	}
	
	func merge(to: inout [NSAttributedString.Key : Any], with trait: UITraitCollection) {
		let style = to[.paragraphStyle] as? NSMutableParagraphStyle
			?? NSMutableParagraphStyle()
		style.paragraphSpacing = value.bottom
		style.paragraphSpacingBefore = value.top
		to[.paragraphStyle] = style
	}
}

struct PaddingApplyer: StyleApplyer {
	var producer: (UITraitCollection)->UIEdgeInsets
	
	init(with value: Any, predefined: StyleValueSet) {
		let insets = UIEdgeInsets.spot(predefined.value(for: value)) ?? .zero
		producer = {_ in insets}
	}
	
	init(_ fn: @escaping (UITraitCollection)->UIEdgeInsets) {
		producer = fn
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection) {
		switch to {
		case let view as UIButton:
			view.contentEdgeInsets = producer(trait)
		case let view as UITextView:
			view.textContainerInset = producer(trait)
		case let view as UICollectionView:
			guard let layout = view.collectionViewLayout as? UICollectionViewFlowLayout else {break}
			layout.sectionInset = producer(trait)
		default:break
		}
	}
}

struct TitlePaddingApplyer: StyleApplyer {
	var producer: (UITraitCollection)->UIEdgeInsets
	
	init(with value: Any, predefined: StyleValueSet) {
		let insets = UIEdgeInsets.spot(predefined.value(for: value)) ?? .zero
		producer = {_ in insets}
	}
	
	init(_ fn: @escaping (UITraitCollection)->UIEdgeInsets) {
		producer = fn
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection) {
		if let view = to as? UIButton {
			view.titleEdgeInsets = producer(trait)
		}
	}
}
#endif
