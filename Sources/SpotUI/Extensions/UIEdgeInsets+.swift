//
//  UIEdgeInsets+.swift
//  SpotUI
//
//  Created by Shawn Clovie on 25/1/2018.
//  Copyright © 2018 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import Spot

public func AnyToUIEdgeInsets(_ value: Any?) -> UIEdgeInsets? {
	switch value {
	case let value as Double:
		let v = CGFloat(value)
		return .init(top: v, left: v, bottom: v, right: v)
	case let vs as [Any] where vs.count >= 4:
		return .init(top: CGFloat(AnyToDouble(vs[0]) ?? 0),
					 left: CGFloat(AnyToDouble(vs[1]) ?? 0),
					 bottom: CGFloat(AnyToDouble(vs[2]) ?? 0),
					 right: CGFloat(AnyToDouble(vs[3]) ?? 0))
	case let data as [AnyHashable: Any]:
		return .init(top: CGFloat(AnyToDouble(data["top"]) ?? 0),
					 left: CGFloat(AnyToDouble(data["left"]) ?? 0),
					 bottom: CGFloat(AnyToDouble(data["bottom"]) ?? 0),
					 right: CGFloat(AnyToDouble(data["right"]) ?? 0))
	default:
		return nil
	}
}
#endif
