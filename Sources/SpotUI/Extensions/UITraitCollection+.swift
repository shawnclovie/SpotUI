//
//  UITraitCollection+.swift
//  SpotUI
//
//  Created by Shawn Clovie on 20/8/2019.
//  Copyright © 2019 Shawn Clovie. All rights reserved.
//

import UIKit
import Spot

public enum UserInterfaceStyle: Int {
	case unspecified, light, dark
}

extension Suffix where Base == UITraitCollection {
	
	public var userInterfaceStyle: UserInterfaceStyle {
		if #available(iOS 12.0, *) {
			return UserInterfaceStyle(rawValue: base.userInterfaceStyle.rawValue) ?? .unspecified
		}
		return .light
	}
}
