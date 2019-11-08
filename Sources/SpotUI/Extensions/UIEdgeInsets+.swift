//
//  UIEdgeInsets+.swift
//  SpotUI
//
//  Created by Shawn Clovie on 25/1/2018.
//  Copyright © 2018 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public func AnyToUIEdgeInsets(_ value: Any?) -> UIEdgeInsets? {
	guard let value = value else {
		return nil
	}
	switch value {
	case let value as Double:
		let v = CGFloat(value)
		return .init(top: v, left: v, bottom: v, right: v)
	case let vs as [Double] where vs.count >= 4:
		return .init(top: CGFloat(vs[0]), left: CGFloat(vs[1]),
						  bottom: CGFloat(vs[2]), right: CGFloat(vs[3]))
	case let data as [AnyHashable: Double]:
		return .init(top: CGFloat(data["top", default: 0]),
					 left: CGFloat(data["left", default: 0]),
					 bottom: CGFloat(data["bottom", default: 0]),
					 right: CGFloat(data["right", default: 0]))
	default:
		return nil
	}
}
#endif
