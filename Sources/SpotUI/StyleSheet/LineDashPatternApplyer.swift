//
//  LineDashPatternApplyer.swift
//  SpotUI
//
//  Created by Shawn Clovie on 14/1/2018.
//  Copyright © 2018 Shawn Clovie. All rights reserved.
//

import UIKit

struct LineDashPatternApplyer: StyleApplyer {
	var producer: (UITraitCollection)->[Double]
	
	init?(with value: Any, predefined: StyleValueSet) {
		guard let values = predefined.value(for: value) as? [Double] else {
			return nil
		}
		producer = {_ in values}
	}
	
	init(_ fn: @escaping (UITraitCollection)->[Double]) {
		producer = fn
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection) {
		switch to {
		case let layer as CAShapeLayer:
			layer.lineDashPattern = producer(trait) as [NSNumber]
		default:break
		}
	}
}
