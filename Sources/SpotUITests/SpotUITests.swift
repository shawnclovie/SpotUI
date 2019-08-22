//
//  SpotUITests.swift
//  SpotUITests
//
//  Created by Shawn Clovie on 27/8/2018.
//  Copyright © 2018 Shawn Clovie. All rights reserved.
//

import XCTest
import Spot
import SpotUI

class SpotUITests: XCTestCase {
	
	override func setUp() {
		super.setUp()
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	func testPDFImage() {
		let bundle = Bundle(for: classForCoder)
		XCTAssertNotNil(UIImage.spot_fromPDF(named: "action_font_family", in: bundle))
	}
	
	func testStyleSheet() {
		var sheet = StyleSheet()
		sheet.load(from: [
			"c": ["background-color": "#ff0000"],
			"name": ["shadow": ["offset": [2, 2], "color": "#ff0000", "opacity": 0.5, "radius": 2]]
			])
		let shadow = sheet.stringAttributes(styles: ["name"], with: .init())[.shadow] as! NSShadow
		XCTAssertEqual(shadow.shadowOffset, CGSize(width: 2, height: 2))
		XCTAssertEqual(shadow.shadowBlurRadius, 2)
		XCTAssertEqual(StyleValueSet(["tint": "#ff0000"]).color(ofKey: "tint"), .red)
		let view = UIView()
		sheet.apply(styles: ["c"], to: view, with: view.traitCollection)
		XCTAssertEqual(view.backgroundColor, .red)
	}
}
