//
//  ContentModeApplyer.swift
//  SpotUI
//
//  Created by Shawn Clovie on 27/9/2017.
//  Copyright © 2017 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import Spot

public struct ContentModeApplyer: StyleApplyer {
	public static func parseContentMode(_ value: String) -> UIView.ContentMode? {
		switch value {
		case "center":				return .center
		case "top":					return .top
		case "top-left":			return .topLeft
		case "top-right":			return .topRight
		case "bottom":				return .bottom
		case "bottom-left":			return .bottomLeft
		case "bottom-right":		return .bottomRight
		case "left":				return .left
		case "right":				return .right
		case "redraw":				return .redraw
		case "scale-to-fill":		return .scaleToFill
		case "scale-aspect-fill":	return .scaleAspectFill
		case "scale-aspect-fit":	return .scaleAspectFit
		default:
			return nil
		}
	}
	
	var value: UIView.ContentMode
	
	public init(with value: Any, predefined: StyleValueSet) {
		if let value = predefined.value(for: value) as? String,
			let mode = Self.parseContentMode(value) {
			self.value = mode
		} else {
			self.value = .center
		}
	}
	
	init(_ value: UIView.ContentMode) {
		self.value = value
	}
	
	public func apply(to: StyleApplyable, with trait: UITraitCollection) {
		switch to {
		case let view as UIButton:
			view.imageView?.contentMode = value
		case let view as UIView:
			view.contentMode = value
		default:break
		}
	}
}
#endif
