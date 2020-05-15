//
//  ImageSource+Applyer.swift
//  SpotUI
//
//  Created by Shawn Clovie on 27/9/2017.
//  Copyright © 2017 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import Spot
import SpotCache

public struct StyleImageSource {
	enum Source {
		case empty
		case solidColor(UIColor, size: CGSize)
		case name(String, size: CGSize, template: Bool)
	}
	
	/// Make empty source, it would produce nil.
	public static let empty = StyleImageSource(.empty)
	
	/// Make source with solid color
	/// - Parameter color: Fill color
	/// - Parameter size: Image size, 1x1 by default
	public static func solidColor(_ color: UIColor, size: CGSize = .init(width: 1, height: 1)) -> StyleImageSource {
		.init(.solidColor(color, size: size))
	}
	
	/// Make source with image name, support jpg/png/gif/pdf
	/// - Parameter name: Image name, e.g. "bar.png" or "path/icon.pdf"
	/// - Parameter size: Content size for PDF, or fitting size for bitmap
	/// - Parameter template: Should make image as template with global tint color (call withRenderingMode(.alwaysTemplate) to loaded image).
	public static func name(_ name: String, size: CGSize = .zero, template: Bool = false) -> StyleImageSource {
		.init(.name(name, size: size, template: template))
	}
	
	let source: Source
	
	init(_ src: Source) {
		source = src
	}
	
	init(with data: [AnyHashable: Any], predefined: StyleValueSet) {
		if let name = predefined.value(for: data["name"]) as? String {
			let size = AnyToCGSize(predefined.value(for: data["size"])) ?? .zero
			source = .name(name, size: size, template: data["template"] as? Bool ?? false)
		} else if let value = predefined.value(for: data["solid-color"]) as? String,
			let color = DecimalColor(hexARGB: value) {
			let size = AnyToCGSize(predefined.value(for: data["size"])) ?? .init(width: 1, height: 1)
			source = .solidColor(color.colorValue, size: size)
		} else {
			source = .empty
		}
	}
	
	public func makeImage() -> UIImage? {
		switch source {
		case .empty:
			return nil
		case .name(let name, let size, let template):
			let image = Self.loadImage(name: name, fitSize: size)
			return template ? image?.withRenderingMode(.alwaysTemplate) : image
		case .solidColor(let color, let size):
			return color.cgColor
				.spot.solidImage(width: Int(size.width), height: Int(size.height))
				.map(UIImage.init(cgImage:))
		}
	}
}

extension StyleImageSource {
	public typealias ImageLoader = (_ name: String, _ contentSize: CGSize)->UIImage?
	
	static var registeredImageLoader: [String: ImageLoader] = [
		"pdf": {UIImage.spot_fromPDF(named: $0, contentSize: $1)},
	]
	
	public static func registerImageLoader(ext: String, _ fn: @escaping ImageLoader) {
		let suffix = ext.hasPrefix(".") ? ext.dropFirst().lowercased() : ext.lowercased()
		registeredImageLoader[suffix] = fn
	}
	
	private static func loadImage(name: String, fitSize: CGSize) -> UIImage? {
		guard !name.isEmpty else {return nil}
		if let ext = name.spot.pathExtension,
			let fn = registeredImageLoader[ext.lowercased()] {
			return fn(name, fitSize)
		}
		let image = UIImage(named: name)
		return fitSize == .zero ? image : image?.spot.scaled(toFit: fitSize, by: .scaleToFill)
	}
}

struct StillImageApplyer: StyleApplyer {
	var producer: (UITraitCollection?)->StyleImageSource
	
	init?(with value: Any, predefined: StyleValueSet) {
		guard let data = predefined.value(for: value) as? [AnyHashable: Any] else {return nil}
		let image = StyleImageSource(with: data, predefined: predefined)
		producer = {_ in image}
	}
	
	init(_ fn: @escaping (UITraitCollection?)->StyleImageSource) {
		producer = fn
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection?) {
		switch to {
		case let layer as CALayer:
			layer.contents = producer(trait).makeImage()?.cgImage
		case let view as UIImageView:
			view.image = producer(trait).makeImage()
		case let view as UIButton:
			view.setImage(producer(trait).makeImage(), for: .normal)
		case let view as UISlider:
			view.setThumbImage(producer(trait).makeImage(), for: .normal)
		case let item as UIBarItem:
			item.image = producer(trait).makeImage()
		default:break
		}
	}
}

// MARK: - Stateful

private func parseStatefulImages(with value: Any, predefined: StyleValueSet) -> [UIControl.State: StyleImageSource] {
	guard let data = predefined.value(for: value) as? [AnyHashable: Any] else {return [:]}
	if data["normal"] == nil {
		return [.normal: .init(with: data, predefined: predefined)]
	}
	var sources: [UIControl.State: StyleImageSource] = [:]
	for (key, value) in data {
		if let value = value as? [AnyHashable: Any] {
			sources[.spot(key)] = .init(with: value, predefined: predefined)
		}
	}
	return sources
}

protocol StatefulImageApplying {
	static func apply(to: StyleApplyable, producer: (UITraitCollection?)->[UIControl.State: StyleImageSource], with trait: UITraitCollection?)
}

struct StatefulImageApplyer<Applying: StatefulImageApplying>: StyleApplyer {
	var producer: (UITraitCollection?)->[UIControl.State: StyleImageSource]
	
	init(with value: Any, predefined: StyleValueSet) {
		let images = parseStatefulImages(with: value, predefined: predefined)
		producer = {_ in images}
	}
	
	init(_ fn: @escaping (UITraitCollection?)->[UIControl.State: StyleImageSource]) {
		producer = fn
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection?) {
		Applying.apply(to: to, producer: producer, with: trait)
	}
}

struct BackgroundImageApplying: StatefulImageApplying {
	static func apply(to: StyleApplyable, producer: (UITraitCollection?) -> [UIControl.State : StyleImageSource], with trait: UITraitCollection?) {
		for (state, source) in producer(trait) {
			switch to {
			case let view as UIButton:
				view.setBackgroundImage(source.makeImage(), for: state)
			case let view as UISearchBar:
				view.backgroundImage = source.makeImage()
			default:break
			}
		}
	}
}

struct ImageApplying: StatefulImageApplying {
	static func apply(to: StyleApplyable, producer: (UITraitCollection?) -> [UIControl.State : StyleImageSource], with trait: UITraitCollection?) {
		for (state, source) in producer(trait) {
			switch to {
			case let layer as CALayer:
				layer.contents = source.makeImage()?.cgImage
			case let view as UIImageView:
				if state == .highlighted {
					view.highlightedImage = source.makeImage()
				} else {
					view.image = source.makeImage()
				}
			case let view as UIButton:
				view.setImage(source.makeImage(), for: state)
			case let view as UISlider:
				view.setThumbImage(source.makeImage(), for: state)
			case let item as UITabBarItem where state == .highlighted:
				item.selectedImage = source.makeImage()
			case let item as UIBarItem:
				item.image = source.makeImage()
			default:break
			}
		}
	}
}

struct SlideTrackImageApplyer: StyleApplyer {
	var sourcesMin: [UIControl.State: StyleImageSource]
	var sourcesMax: [UIControl.State: StyleImageSource]

	init?(with value: Any, predefined: StyleValueSet) {
		guard let value = value as? [AnyHashable: Any] else {return nil}
		sourcesMin = parseStatefulImages(with: value["min"] as Any, predefined: predefined)
		sourcesMax = parseStatefulImages(with: value["max"] as Any, predefined: predefined)
	}
	
	init(min: [UIControl.State: StyleImageSource], max: [UIControl.State: StyleImageSource]) {
		sourcesMin = min
		sourcesMax = max
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection?) {
		guard let view = to as? UISlider else {return}
		for (state, source) in sourcesMin {
			view.setMinimumTrackImage(source.makeImage(), for: state)
		}
		for (state, source) in sourcesMax {
			view.setMaximumTrackImage(source.makeImage(), for: state)
		}
	}
}
#endif
