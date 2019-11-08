//
//  ItemSizeApplyer.swift
//  SpotUI
//
//  Created by Shawn Clovie on 6/10/2017.
//  Copyright © 2017 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit

struct ItemSizeApplyer: StyleApplyer {
	var producer: (UITraitCollection)->CGSize
	
	
	init?(with value: Any, predefined: StyleValueSet) {
		guard let parsed = AnyToCGSize(predefined.value(for: value)) else {
			return nil
		}
		producer = {_ in parsed}
	}
	
	init(_ fn: @escaping (UITraitCollection)->CGSize) {
		producer = fn
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection) {
		if let view = to as? UICollectionView,
			let layout = view.collectionViewLayout as? UICollectionViewFlowLayout {
			layout.itemSize = producer(trait)
		}
	}
}
#endif
