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
	
	public private(set) var applyers: [String: StyleApplyer]
	
	public var loadedData: [String: Any]
	
	public init(applyers: [String: StyleApplyer] = [:], loadedData: [String: Any] = [:]) {
		self.applyers = applyers
		self.loadedData = loadedData
	}
	
	convenience init(with data: [String: Any], predefined: StyleValueSet) {
		self.init(applyers: [:], loadedData: data)
		for (key, value) in data {
			guard let cls = Self.applyerTypes[key],
				let applyer = cls.init(with: value, predefined: predefined) else {continue}
			set(applyer)
		}
	}
	
	public var duplicate: Style {
		.init(applyers: applyers, loadedData: loadedData)
	}
	
	public func append(_ other: Style) {
		for it in other.applyers {
			applyers[it.key] = it.value
		}
		for it in other.loadedData {
			loadedData[it.key] = it.value
		}
	}
	
	@discardableResult
	public func set(_ op: StyleApplyer) -> Self {
		applyers["\(type(of: op))"] = op
		return self
	}
	
	public func remove(_ op: StyleApplyer) {
		applyers.removeValue(forKey: "\(type(of: op))")
	}
	
	public func removeAllApplyers() {
		applyers.removeAll()
	}
	
	public func apply(to: StyleApplyable, with trait: UITraitCollection?) {
		for it in applyers.values {
			it.apply(to: to, with: trait)
		}
	}
	
	public func stringAttributes(with trait: UITraitCollection?) -> [NSAttributedString.Key : Any] {
		var result: [NSAttributedString.Key : Any] = [:]
		for it in applyers.values {
			it.merge(to: &result, with: trait)
		}
		return result
	}
}

extension Style: Hashable, Equatable {
	
	public static func ==(l: Style, r: Style) -> Bool {
		l === r
	}
	
	public func hash(into hasher: inout Hasher) {
		for it in applyers {
			it.key.hash(into: &hasher)
		}
	}
}
#endif
