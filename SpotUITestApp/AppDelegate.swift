//
//  AppDelegate.swift
//  SpotUITestApp
//
//  Created by Shawn Clovie on 28/10/2018.
//  Copyright © 2018 Shawn Clovie. All rights reserved.
//

import UIKit
import SpotUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		let styleVars = try! StyleValueSet(contentsOf: Bundle.main.url(forResource: "style_defines.json", withExtension: nil)!)
		try! StyleSheet.shared.load(styleFile: Bundle.main.url(forResource: "style.json", withExtension: nil)!, predefined: styleVars)
		try! StyleSheet.shared.load(bundleDirectory: "spot_ui_styles.bundle", variableFile: "defines.json")
		
		let window = UIWindow(frame: UIScreen.main.bounds)
		window.rootViewController = UINavigationController(rootViewController: SimpleTestViewController())
		window.makeKeyAndVisible()
		self.window = window
		
		StyleShared.tintColorLight = .systemTeal
		StyleShared.tintColorDark = .systemOrange
		window.addSubview(WindowTraitCollectionAdjuster(frame: window.bounds))
		return true
	}
}
