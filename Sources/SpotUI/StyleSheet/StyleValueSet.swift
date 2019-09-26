//
//  StyleValueSet.swift
//  SpotUI
//
//  Created by Shawn Clovie on 21/8/2019.
//  Copyright © 2019 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import Spot

public struct StyleValueSet {
	public var values: [String: Any]
	
	public init(_ values: [String: Any]) {
		self.values = values
	}
	
	public init(contentsOf file: URL) throws {
		let data = try JSONSerialization.jsonObject(with: try Data(contentsOf: file))
		guard let values = data as? [String: Any] else {
			throw AttributedError(.invalidFormat, object: data)
		}
		self.values = values
	}
	
	/// Parse predefined value if the parameter is name with prefix "$".
	///
	/// - Parameter value: Name of predefined value or the value itself.
	/// - Returns: predefined value, or the parameter.
	public func value(for value: Any?) -> Any? {
		guard let str = value as? String, str.starts(with: "$") else {
			return value
		}
		let key = String(str.dropFirst())
		return values[key] ?? value
	}
	
	public func bool(ofKey key: String) -> Bool {
		AnyToBool(value(for: values[key])) ?? false
	}
	
	public func color(ofKey key: String) -> UIColor? {
		values[key].flatMap(parseColor)
	}
	
	func parseDouble(_ value: Any?, defaultValue: Double = 0) -> Double {
		AnyToDouble(self.value(for: value)) ?? defaultValue
	}
	
	private func color(named name: String) -> UIColor? {
		guard let first = name.first else {return nil}
		switch first {
		case "#":
			return DecimalColor(hexARGB: name)?.colorValue
		default:
			if #available(iOS 11.0, *) {
				return UIColor(named: name)
			} else {
				return nil
			}
		}
	}
	
	func parseColor(_ value: Any?) -> UIColor? {
		guard let name = self.value(for: value) as? String else {return nil}
		return color(named: name)
	}
	
	func parseStatefulColors(with value: Any) -> [UIControl.State: UIColor?] {
		var colors: [UIControl.State: UIColor?] = [:]
		if let value = self.value(for: value) {
			if let value = value as? String {
				colors[.normal] = color(named: value)
			} else if let data = value as? [AnyHashable: String] {
				for (key, value) in data {
					let state = UIControl.State.spot(key)
					if let value = self.value(for: value) as? String {
						colors[state] = color(named: value)
					} else {
						colors[state] = Optional.none
					}
				}
			}
		} else {
			colors[.normal] = Optional.none
		}
		return colors
	}
}
#endif
