//
//  UIControlState+.swift
//  SpotUI
//
//  Created by Shawn Clovie on 25/1/2018.
//  Copyright © 2018 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit

extension UIControl.State {
	static func spot(_ value: Any) -> UIControl.State {
		switch value {
		case let value as UInt:
			return .init(rawValue: value)
		case let value as String:
			switch value {
			case "highlighted":	return .highlighted
			case "disabled":	return .disabled
			case "selected":	return .selected
			case "application":	return .application
			case "focused":		return .focused
			default:break
			}
		default:break
		}
		return .normal
	}
}

extension UIControl.State: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(rawValue)
	}
}
#endif
