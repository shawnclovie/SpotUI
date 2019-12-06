//
//  Number+Applyer.swift
//  SpotUI
//
//  Created by Shawn Clovie on 27/9/2017.
//  Copyright © 2017 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit

protocol NumberApplying {
	static func apply(to: StyleApplyable, value: CGFloat, with trait: UITraitCollection?)
	static var defaultValue: Double {get}
}

extension NumberApplying {
	static var defaultValue: Double {0}
}

struct NumberApplyer<Applying: NumberApplying>: StyleApplyer {
	var value: CGFloat
	
	init(with value: Any, predefined: StyleValueSet) {
		self.value = CGFloat(predefined.parseDouble(value, defaultValue: Applying.defaultValue))
	}
	
	init(_ value: CGFloat) {
		self.value = value
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection?) {
		Applying.apply(to: to, value: value, with: trait)
	}
}

struct AlphaApplying: NumberApplying {
	static func apply(to: StyleApplyable, value: CGFloat, with trait: UITraitCollection?) {
		switch to {
		case let view as UIView:
			view.alpha = value
		case let layer as CALayer:
			layer.opacity = Float(value)
		default:break
		}
	}
}

struct NumberOfLinesApplying: NumberApplying {
	
	static var defaultValue: Double {1}
	
	static func apply(to: StyleApplyable, value: CGFloat, with trait: UITraitCollection?) {
		let value = Int(value)
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

// MARK: - Trait

protocol TraitNumberApplying {
	static func apply(to: StyleApplyable, producer: (UITraitCollection?)->CGFloat, with trait: UITraitCollection?)
	
	static func merge(to: inout [NSAttributedString.Key : Any], producer: (UITraitCollection?)->CGFloat, with trait: UITraitCollection?)
}

extension TraitNumberApplying {
	static func merge(to: inout [NSAttributedString.Key : Any], producer: (UITraitCollection?)->CGFloat, with trait: UITraitCollection?) {}
}

struct TraitNumberApplyer<Applying: TraitNumberApplying>: StyleApplyer {
	var producer: (UITraitCollection?)->CGFloat
	
	init(with value: Any, predefined: StyleValueSet) {
		let number = predefined.parseDouble(value)
		producer = {_ in CGFloat(number)}
	}
	
	init(_ fn: @escaping (UITraitCollection?)->CGFloat) {
		producer = fn
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection?) {
		Applying.apply(to: to, producer: producer, with: trait)
	}
	
	func merge(to: inout [NSAttributedString.Key : Any], with trait: UITraitCollection?) {
		Applying.merge(to: &to, producer: producer, with: trait)
	}
}

struct CornerRadiusApplying: TraitNumberApplying {
	static func apply(to: StyleApplyable, producer: (UITraitCollection?) -> CGFloat, with trait: UITraitCollection?) {
		switch to {
		case let view as UIView:
			view.layer.cornerRadius = producer(trait)
		case let layer as CALayer:
			layer.cornerRadius = producer(trait)
		default:break
		}
	}
}

struct LineSpacingApplying: TraitNumberApplying {
	static func apply(to: StyleApplyable, producer: (UITraitCollection?) -> CGFloat, with trait: UITraitCollection?) {
		switch to {
		case let view as UITextView:
			view.textContainer.lineFragmentPadding = producer(trait)
		case let view as UICollectionView:
			guard let layout = view.collectionViewLayout as? UICollectionViewFlowLayout else {break}
			layout.minimumLineSpacing = producer(trait)
		default:break
		}
	}
	
	static func merge(to: inout [NSAttributedString.Key : Any], producer: (UITraitCollection?) -> CGFloat, with trait: UITraitCollection?) {
		let style = to[.paragraphStyle] as? NSMutableParagraphStyle ?? .init()
		style.lineSpacing = producer(trait)
		to[.paragraphStyle] = style
	}
}

struct LineWidthApplying: TraitNumberApplying {
	static func apply(to: StyleApplyable, producer: (UITraitCollection?) -> CGFloat, with trait: UITraitCollection?) {
		if let layer = to as? CAShapeLayer {
			layer.lineWidth = producer(trait)
		}
	}
}

struct SpacingApplying: TraitNumberApplying {
	static func apply(to: StyleApplyable, producer: (UITraitCollection?) -> CGFloat, with trait: UITraitCollection?) {
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
