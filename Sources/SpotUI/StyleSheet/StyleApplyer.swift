//
//  StyleApplyer.swift
//  SpotUI
//
//  Created by Shawn Clovie on 21/8/2019.
//  Copyright © 2019 Shawn Clovie. All rights reserved.
//

import UIKit

public protocol StyleApplyer {
	init?(with value: Any, predefined: StyleValueSet)
	func apply(to: StyleApplyable, with trait: UITraitCollection)
	func merge(to: inout [NSAttributedString.Key : Any], with trait: UITraitCollection)
}

extension StyleApplyer {
	init?(with value: Any, predefined: StyleValueSet) {
		return nil
	}
	public func merge(to: inout [NSAttributedString.Key : Any], with trait: UITraitCollection) {}
}
