//
//  StyleSheet.swift
//  SpotUI
//
//  Created by Shawn Clovie on 26/7/2017.
//  Copyright © 2017 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import Spot
import SpotCache

public struct StyleSheet {
	
	public static var shared = StyleSheet()
	
	private var styles: [String: Style] = [:]

	public init() {}
	
	public mutating func load(styleFile: URL, predefined: StyleValueSet) throws {
		let data = try JSONSerialization.jsonObject(with: try Data(contentsOf: styleFile))
		guard let json = data as? [String: [String: Any]] else {
			throw AttributedError(.invalidFormat, object: data)
		}
		load(from: json, predefined: predefined)
	}
	
	public mutating func load(from data: [String: [String: Any]], predefined: StyleValueSet = .init([:])) {
		for (name, data) in data {
			styles[name] = Style(with: data, predefined: predefined)
		}
	}
	
	/// Load serial style files
	///
	/// - Parameters:
	///   - bundleDirectory: Directory name in main bundle
	///   - variableFile: File name in the directory that stored style var, default by no var would reading.
	public mutating func load(bundleDirectory: String, variableFile: String = "") throws {
		guard let pathStyle = Bundle.main.url(forResource: bundleDirectory, withExtension: nil) else {
			throw AttributedError(.fileNotFound, object: bundleDirectory)
		}
		let styleFiles = try FileManager.default.contentsOfDirectory(atPath: pathStyle.path)
		let styleVars: StyleValueSet = variableFile.isEmpty ? .init([:]) : try .init(contentsOf: pathStyle.appendingPathComponent(variableFile))
		for file in styleFiles where file.hasSuffix(".json") && file != variableFile {
			let path = pathStyle.appendingPathComponent(file)
			try load(styleFile: path, predefined: styleVars)
		}
	}
	
	public subscript(key: String) -> Style? {
		styles[key]
	}
	
	/// Apply style to the applyable with names
	/// - Parameter styles: Style names
	/// - Parameter view: Applyable (UIView/CALayer/UIBarItem)
	/// - Parameter trait: TraitCollection from UIView or UIViewController
	public func apply(styles names: [String], to view: StyleApplyable, with trait: UITraitCollection) {
		for name in names {
			styles[name]?.apply(to: view, with: trait)
		}
		if UIDevice.current.userInterfaceIdiom == .pad {
			for name in names {
				styles[name + "~pad"]?.apply(to: view, with: trait)
			}
		}
	}
	
	/// Make string attributes with style names
	/// - Parameter styles: Style names
	/// - Parameter trait: TraitCollection from UIView or UIViewController
	public func stringAttributes(styles names: [String], with trait: UITraitCollection) -> [NSAttributedString.Key : Any] {
		var attrs: [NSAttributedString.Key : Any] = [:]
		for name in names {
			if let style = styles[name] {
				for (key, value) in style.stringAttributes(with: trait) {
					attrs[key] = value
				}
			}
		}
		if UIDevice.current.userInterfaceIdiom == .pad {
			for name in names {
				if let style = styles[name + "~pad"] {
					for (key, value) in style.stringAttributes(with: trait) {
						attrs[key] = value
					}
				}
			}
		}
		return attrs
	}
}
#endif
