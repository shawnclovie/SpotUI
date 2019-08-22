//
//  Style.swift
//  SpotUI
//
//  Created by Shawn Clovie on 26/7/2017.
//  Copyright © 2017 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import Spot

public final class Style {
	
	public var applyers: [String: StyleApplyer] = [:]
	
	public var loadedData: [String: Any]
	
	public init() {
		loadedData = [:]
	}
	
	init(with data: [String: Any], predefined: StyleValueSet) {
		loadedData = data
		for (key, value) in data {
			guard let cls = Self.applyerTypes[key],
				let applyer = cls.init(with: value, predefined: predefined) else {continue}
			set(applyer)
		}
	}
	
	@inlinable
	@discardableResult
	public func set(_ op: StyleApplyer) -> Self {
		applyers["\(type(of: op))"] = op
		return self
	}
	
	public func apply(to: StyleApplyable, with trait: UITraitCollection) {
		for it in applyers.values {
			it.apply(to: to, with: trait)
		}
	}
	
	public func stringAttributes(with trait: UITraitCollection) -> [NSAttributedString.Key : Any] {
		var result: [NSAttributedString.Key : Any] = [:]
		for it in applyers.values {
			it.merge(to: &result, with: trait)
		}
		return result
	}
}
#endif
