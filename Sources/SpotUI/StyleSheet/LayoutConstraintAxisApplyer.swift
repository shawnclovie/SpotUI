//
//  LayoutConstraintAxisApplyer.swift
//  SpotUI
//
//  Created by Shawn Clovie on 30/9/2017.
//  Copyright © 2017 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit

struct LayoutConstraintAxisApplyer: StyleApplyer {
	var value: NSLayoutConstraint.Axis
	
	init?(with value: Any, predefined: StyleValueSet) {
		switch predefined.value(for: value) as? String ?? "" {
		case "vertical":	self.value = .vertical
		case "horizontal":	self.value = .horizontal
		default:return nil
		}
	}
	
	init(_ value: NSLayoutConstraint.Axis) {
		self.value = value
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection) {
		switch to {
		case let view as UIStackView:
			view.axis = value
		case let view as UICollectionView:
			guard let layout = view.collectionViewLayout as? UICollectionViewFlowLayout else {break}
			switch value {
			case .vertical:		layout.scrollDirection = .vertical
			case .horizontal:	fallthrough
			@unknown default:	layout.scrollDirection = .horizontal
			}
		default:break
		}
	}
}
#endif
