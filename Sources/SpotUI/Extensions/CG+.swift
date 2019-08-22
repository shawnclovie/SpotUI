//
//  CG+.swift
//  SpotUI
//
//  Created by Shawn Clovie on 25/1/2018.
//  Copyright © 2018 Shawn Clovie. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGRect {
	/// Convert value to rect
	public static func spot(_ value: Any?) -> CGRect? {
		guard let value = value else {
			return nil
		}
		switch value {
		case let values as [AnyHashable: Double]:
			return CGRect(x: values["x", default: 0],
						  y: values["y", default: 0],
						  width: values["width", default: 0],
						  height: values["height", default: 0])
		case let values as [Double] where values.count >= 4:
			return CGRect(x: values[0], y: values[1],
						  width: values[2], height: values[3])
		default:
			return nil
		}
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

extension CGPoint {
	public static func spot(_ value: Any?) -> CGPoint? {
		guard let value = value else {
			return nil
		}
		switch value {
		case let value as Double:
			return CGPoint(x: value, y: value)
		case let value as NSNumber:
			let number = value.doubleValue
			return CGPoint(x: number, y: number)
		case let values as [AnyHashable: Double]:
			return CGPoint(x: values["x", default: 0],
						   y: values["y", default: 0])
		case let values as [Double] where values.count >= 2:
			return CGPoint(x: values[0], y: values[1])
		case let values as [Int] where values.count >= 2:
			return CGPoint(x: values[0], y: values[1])
		default:
			return nil
		}
	}
}

extension CGSize {
	public static func spot(_ value: Any?) -> CGSize? {
		guard let value = value else {
			return nil
		}
		switch value {
		case let value as Double:
			return CGSize(width: value, height: value)
		case let value as NSNumber:
			let number = value.doubleValue
			return CGSize(width: number, height: number)
		case let values as [AnyHashable:Double]:
			return CGSize(width: values["width", default: 0],
						  height: values["height", default: 0])
		case let values as [Double] where values.count >= 2:
			return CGSize(width: values[0], height: values[1])
		case let values as [Int] where values.count >= 2:
			return CGSize(width: values[0], height: values[1])
		default:
			return nil
		}
	}
}
