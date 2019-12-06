//
//  StyleApplyable.swift
//  SpotUI
//
//  Created by Shawn Clovie on 21/8/2019.
//  Copyright © 2019 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import Spot

public protocol StyleApplyable: class {}

extension Suffix where Base: StyleApplyable {
	public func apply(styles: [String], with trait: UITraitCollection?, in sheet: StyleSheet = .shared) {
		sheet.apply(styles: styles, to: base, with: trait)
	}
}

extension CALayer: StyleApplyable {}

extension UIView: StyleApplyable {}

extension Suffix where Base: UIView {
	public func apply(styles: [String], in sheet: StyleSheet = .shared) {
		sheet.apply(styles: styles, to: base, with: base.traitCollection)
	}
}

extension UIBarItem: StyleApplyable {}
#endif
