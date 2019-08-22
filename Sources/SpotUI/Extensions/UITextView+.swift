//
//  UITextView+.swift
//  SpotUI
//
//  Created by Shawn Clovie on 29/3/2018.
//  Copyright © 2018 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import Spot

extension Suffix where Base: UITextView {
	public func disableInteraction() {
		base.isEditable = false
		base.isSelectable = false
		base.isScrollEnabled = false
	}
}
#endif
