//
//  Number+Applyer.swift
//  SpotUI
//
//  Created by Shawn Clovie on 27/9/2017.
//  Copyright © 2017 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit

struct AlphaApplyer: StyleApplyer {
	var value: CGFloat
	
	init(with value: Any, predefined: StyleValueSet) {
		self.value = CGFloat(predefined.parseDouble(value))
	}
	
	init(_ value: CGFloat) {
		self.value = value
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection) {
		switch to {
		case let view as UIView:
			view.alpha = value
		case let layer as CALayer:
			layer.opacity = Float(value)
		default:break
		}
	}
}

struct CornerRadiusApplyer: StyleApplyer {
	var producer: (UITraitCollection)->CGFloat
	
	init(with value: Any, predefined: StyleValueSet) {
		let number = predefined.parseDouble(value)
		producer = {_ in CGFloat(number)}
	}
	
	init(_ fn: @escaping (UITraitCollection)->CGFloat) {
		producer = fn
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection) {
		switch to {
		case let view as UIView:
			view.layer.cornerRadius = producer(trait)
		case let layer as CALayer:
			layer.cornerRadius = producer(trait)
		default:break
		}
	}
}

struct NumberOfLinesApplyer: StyleApplyer {
	var value: Int
	
	init?(with value: Any, predefined: StyleValueSet) {
		self.value = predefined.value(for: value) as? Int ?? 1
	}
	
	init(_ value: Int) {
		self.value = value
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection) {
		switch to {
		case let view as UILabel:
			view.numberOfLines = value
		case let view as UITextView:
			view.textContainer.maximumNumberOfLines = value
		case let view as UIButton:
			view.titleLabel?.numberOfLines = value
		default:break
		}
	}
}

struct LineSpacingApplyer: StyleApplyer {
	var producer: (UITraitCollection)->CGFloat
	
	init(with value: Any, predefined: StyleValueSet) {
		let number = predefined.parseDouble(value)
		producer = {_ in CGFloat(number)}
	}
	
	init(_ fn: @escaping (UITraitCollection)->CGFloat) {
		self.producer = fn
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection) {
		switch to {
		case let view as UITextView:
			view.textContainer.lineFragmentPadding = producer(trait)
		case let view as UICollectionView:
			guard let layout = view.collectionViewLayout as? UICollectionViewFlowLayout else {break}
			layout.minimumLineSpacing = producer(trait)
		default:break
		}
	}
	
	func merge(to: inout [NSAttributedString.Key : Any], with trait: UITraitCollection) {
		let style = to[.paragraphStyle] as? NSMutableParagraphStyle ?? .init()
		style.lineSpacing = producer(trait)
		to[.paragraphStyle] = style
	}
}

struct LineWidthApplyer: StyleApplyer {
	var producer: (UITraitCollection)->CGFloat
	
	init(with value: Any, predefined: StyleValueSet) {
		let number = predefined.parseDouble(value)
		producer = {_ in CGFloat(number)}
	}
	
	init(_ fn: @escaping (UITraitCollection)->CGFloat) {
		self.producer = fn
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection) {
		if let layer = to as? CAShapeLayer {
			layer.lineWidth = producer(trait)
		}
	}
}

struct SpacingApplyer: StyleApplyer {
	var producer: (UITraitCollection)->CGFloat
	
	init(with value: Any, predefined: StyleValueSet) {
		let number = predefined.parseDouble(value)
		producer = {_ in CGFloat(number)}
	}
	
	init(_ fn: @escaping (UITraitCollection)->CGFloat) {
		self.producer = fn
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection) {
		switch to {
		case let view as UICollectionView:
			if let layout = view.collectionViewLayout as? UICollectionViewFlowLayout {
				layout.minimumInteritemSpacing = producer(trait)
			}
		case let view as UIStackView:
			view.spacing = producer(trait)
		default:break
		}
	}
}
#endif
