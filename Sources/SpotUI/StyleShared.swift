//
//  StyleShared.swift
//  SpotUI
//
//  Created by Shawn Clovie on 20/8/2019.
//  Copyright © 2019 Shawn Clovie. All rights reserved.
//

import UIKit
import Spot

public enum StyleShared {
	
	public static var clearColorProducer: (UITraitCollection)->UIColor = {_ in .clear}
	public static var clearBorderProducer: (UITraitCollection)->StyleBorder = {_ in .clear}
	
	public static var tintColorLight: UIColor = .systemBlue
	public static var tintColorDark: UIColor = .systemBlue
	
	public static var tintColorProducer: (UITraitCollection)->UIColor = {
		$0.spot.userInterfaceStyle == .dark
			? tintColorDark
			: tintColorLight
	}
	
	public static var statefulTintColorProducer: (UIControl.State, UITraitCollection)->UIColor = {
		tintColorProducer($1)
	}
	
	public static var errorTintColor: UIColor = .systemRed
	public static var destructiveTintColor: UIColor = .systemRed
	
	public static var foregroundTextColorLight: UIColor = .black
	public static var foregroundTextColorDark: UIColor = .init(white: 0.96, alpha: 1)

	public static var foregroundTextColorProducer: (UITraitCollection)->UIColor = {
		$0.spot.userInterfaceStyle == .dark
			? foregroundTextColorDark
			: foregroundTextColorLight
	}
	
	public static var secondForegroundTextColor: UIColor = .systemGray
	
	public static var backgroundColorLight: UIColor = .white
	public static var backgroundColorDark: UIColor = .init(white: 0.04, alpha: 1)
	
	public static var backgroundColorProducer: (UITraitCollection)->UIColor = {
		$0.spot.userInterfaceStyle == .dark
			? backgroundColorDark
			: backgroundColorLight
	}
	
	public static var popupPanelBackgroundColorLight: UIColor = .white
	public static var popupPanelBackgroundColorDark: UIColor = .init(white: 0.2, alpha: 1)

	public static var popupPanelBackgroundColorProducer: (UITraitCollection)->UIColor = {
		$0.spot.userInterfaceStyle == .dark
			? popupPanelBackgroundColorDark
			: popupPanelBackgroundColorLight}
	
	public static var maskBackgroundColor: UIColor = .init(white: 0, alpha: 0.2)
}
