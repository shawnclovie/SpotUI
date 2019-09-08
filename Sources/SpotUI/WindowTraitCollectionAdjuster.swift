//
//  WindowTraitCollectionAdjuster.swift
//  SpotUI
//
//  Created by Shawn Clovie on 21/8/2019.
//  Copyright © 2019 Shawn Clovie. All rights reserved.
//

import UIKit
import Spot

/// The view can set attributes of the attached window, and reset them while traitCollectionDidChange be called.
///
/// Attributes: tintColor by StyleShared.tintColorProducer
public final class WindowTraitCollectionAdjuster: UIView {
	
	public static let traitCollectionDidChangeEvent = EventObservable<UITraitCollection>()
	
	public static let shared = WindowTraitCollectionAdjuster(frame: .zero)
	
	private override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	required convenience init?(coder: NSCoder) {
		self.init(frame: .zero)
	}
	
	override public func didMoveToWindow() {
		super.didMoveToWindow()
		isUserInteractionEnabled = false
		backgroundColor = nil
		if let window = window {
			window.tintColor = StyleShared.tintColorProducer(window.traitCollection)
		}
	}
	
	override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		if let window = window {
			window.tintColor = StyleShared.tintColorProducer(window.traitCollection)
		}
		Self.traitCollectionDidChangeEvent.dispatch(traitCollection)
	}
}
