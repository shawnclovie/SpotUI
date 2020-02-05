//
//  CG+.swift
//  SpotUI
//
//  Created by Shawn Clovie on 25/1/2018.
//  Copyright © 2018 Shawn Clovie. All rights reserved.
//

import Foundation
import CoreGraphics
import Spot

/// Convert value to rect
public func AnyToCGRect(_ value: Any?) -> CGRect? {
	guard let value = value else {
		return nil
	}
	switch value {
	case let values as [AnyHashable: Any]:
		return CGRect(x: AnyToDouble(values["x"]) ?? 0,
					  y: AnyToDouble(values["y"]) ?? 0,
					  width: AnyToDouble(values["width"]) ?? 0,
					  height: AnyToDouble(values["height"]) ?? 0)
	case let values as [Any] where values.count >= 4:
		return CGRect(x: AnyToDouble(values[0]) ?? 0,
					  y: AnyToDouble(values[1]) ?? 0,
					  width: AnyToDouble(values[2]) ?? 0,
					  height: AnyToDouble(values[3]) ?? 0)
	default:
		return nil
	}
}

public func +(l: CGSize, r: CGSize) -> CGSize {
	CGSize(width: l.width + r.width, height: l.height + r.height)
}

public func -(l: CGSize, r: CGSize) -> CGSize {
	CGSize(width: l.width - r.width, height: l.height - r.height)
}

public func *(l: CGSize, r: CGFloat) -> CGSize {
	CGSize(width: l.width * r, height: l.height * r)
}

public func /(l: CGSize, r: CGFloat) -> CGSize {
	l * (1 / r)
}

public func +(l: CGPoint, r: CGPoint) -> CGPoint {
	CGPoint(x: l.x + r.x, y: l.y + r.y)
}

public func -(l: CGPoint, r: CGPoint) -> CGPoint {
	CGPoint(x: l.x - r.x, y: l.y - r.y)
}

public func *(l: CGPoint, r: CGFloat) -> CGPoint {
	CGPoint(x: l.x * r, y: l.y * r)
}

public func /(l: CGPoint, r: CGFloat) -> CGPoint {
	l * (1 / r)
}

public func AnyToCGPoint(_ value: Any?) -> CGPoint? {
	guard let value = value else {
		return nil
	}
	switch value {
	case let value as Double:
		return CGPoint(x: value, y: value)
	case let value as NSNumber:
		let number = value.doubleValue
		return CGPoint(x: number, y: number)
	case let values as [AnyHashable: Any]:
		return CGPoint(x: AnyToDouble(values["x"]) ?? 0,
					   y: AnyToDouble(values["y"]) ?? 0)
	case let values as [Any] where values.count >= 2:
		return CGPoint(x: AnyToDouble(values[0]) ?? 0,
					   y: AnyToDouble(values[1]) ?? 0)
	default:
		return nil
	}
}

public func AnyToCGSize(_ value: Any?) -> CGSize? {
	guard let value = value else {
		return nil
	}
	switch value {
	case let value as Double:
		return CGSize(width: value, height: value)
	case let value as NSNumber:
		let number = value.doubleValue
		return CGSize(width: number, height: number)
	case let values as [AnyHashable: Any]:
		return CGSize(width: AnyToDouble(values["width"]) ?? 0,
					  height: AnyToDouble(values["height"]) ?? 0)
	case let values as [Any] where values.count >= 2:
		return CGSize(width: AnyToDouble(values[0]) ?? 0,
					  height: AnyToDouble(values[1]) ?? 0)
	default:
		return nil
	}
}
