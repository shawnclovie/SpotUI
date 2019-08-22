//
//  WindowTraitCollectionAdjuster.swift
//  SpotUI
//
//  Created by Shawn Clovie on 21/8/2019.
//  Copyright © 2019 Shawn Clovie. All rights reserved.
//

import UIKit

/// The view can set attributes of the attached window, and reset them while traitCollectionDidChange be called.
///
/// Attributes: tintColor by StyleShared.tintColorProducer
open class WindowTraitCollectionAdjuster: UIView {
	
	override open func didMoveToWindow() {
		super.didMoveToWindow()
		isUserInteractionEnabled = false
		backgroundColor = nil
		if let window = window {
			window.tintColor = StyleShared.tintColorProducer(window.traitCollection)
		}
	}
	
	override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		if let window = window {
			window.tintColor = StyleShared.tintColorProducer(window.traitCollection)
		}
	}
}
