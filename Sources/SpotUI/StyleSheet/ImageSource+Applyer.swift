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
		case url(URL, placeholder: String?, template: Bool)
	}
	
	public static let empty = StyleImageSource(.empty)
	
	public static func solidColor(_ color: UIColor, size: CGSize = .init(width: 1, height: 1)) -> StyleImageSource {
		.init(.solidColor(color, size: size))
	}
	
	public static func name(_ name: String, size: CGSize = .zero, template: Bool = false) -> StyleImageSource {
		.init(.name(name, size: size, template: template))
	}
	
	public static func url(_ url: URL, placeholder: String? = nil, template: Bool = false) -> StyleImageSource {
		.init(.url(url, placeholder: placeholder, template: template))
	}
	
	let source: Source
	
	init(_ src: Source) {
		source = src
	}
	
	init(with data: [AnyHashable: Any], predefined: StyleValueSet) {
		if let value = predefined.value(for: data["url"]) as? String,
			let url = URL(string: value) {
			source = .url(url,
						placeholder: predefined.value(for: data["placeholder"]) as? String,
						template: data["template"] as? Bool ?? false)
		} else if let name = predefined.value(for: data["name"]) as? String {
			source = .name(name,
						 size: CGSize.spot(predefined.value(for: data["size"])) ?? .zero,
						 template: data["template"] as? Bool ?? false)
		} else if let value = predefined.value(for: data["solid-color"]) as? String,
			let color = DecimalColor(hexARGB: value) {
			let size = CGSize.spot(predefined.value(for: data["size"])) ?? .init(width: 1, height: 1)
			source = .solidColor(color.colorValue, size: size)
		} else {
			source = .empty
		}
	}
	
	func loadImage(completion: @escaping (UIImage?)->Void) {
		switch source {
		case .empty:
			completion(nil)
		case .name(let it):
			completion(Self.loadImage(name: it.0, size: it.size, template: it.template))
		case .solidColor(let it):
			let image = it.0.cgColor
				.spot.solidImage(width: Int(it.size.width), height: Int(it.size.height))
				.map(UIImage.init(cgImage:))
			completion(image)
		case .url(let it):
			completion(Self.loadImage(name: it.placeholder, size: .zero, template: it.template))
			Cache<UIImage>.shared.fetch(it.0) { result in
				guard case .success(var image) = result else {return}
				if it.template {
					image = image.withRenderingMode(.alwaysTemplate)
				}
				completion(image)
			}
		}
	}

	private static func loadImage(name: String?, size: CGSize, template: Bool) -> UIImage? {
		guard let name = name, !name.isEmpty else {return nil}
		var image: UIImage?
		if name.hasSuffix(".pdf") {
			image = .spot_fromPDF(named: name, contentSize: size)
		} else {
			image = UIImage(named: name)
			if size != .zero {
				image = image?.spot.scaled(toFit: size, by: .scaleToFill)
			}
		}
		return template ? image?.withRenderingMode(.alwaysTemplate) : image
	}
}

struct StillImageApplyer: StyleApplyer {
	var producer: (UITraitCollection)->StyleImageSource
	
	init?(with value: Any, predefined: StyleValueSet) {
		guard let data = predefined.value(for: value) as? [AnyHashable: Any] else {return nil}
		let image = StyleImageSource(with: data, predefined: predefined)
		producer = {_ in image}
	}
	
	init(_ fn: @escaping (UITraitCollection)->StyleImageSource) {
		producer = fn
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection) {
		producer(trait).loadImage { image in
			switch to {
			case let layer as CALayer:
				layer.contents = image?.cgImage
			case let view as UIImageView:
				view.image = image
			case let view as UIButton:
				view.setImage(image, for: .normal)
			case let view as UISlider:
				view.setThumbImage(image, for: .normal)
			case let item as UIBarItem:
				item.image = image
			default:break
			}
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
	static func apply(to: StyleApplyable, producer: (UITraitCollection)->[UIControl.State: StyleImageSource], with trait: UITraitCollection)
}

struct StatefulImageApplyer<Applying: StatefulImageApplying>: StyleApplyer {
	var producer: (UITraitCollection)->[UIControl.State: StyleImageSource]
	
	init(with value: Any, predefined: StyleValueSet) {
		let images = parseStatefulImages(with: value, predefined: predefined)
		producer = {_ in images}
	}
	
	init(_ fn: @escaping (UITraitCollection)->[UIControl.State: StyleImageSource]) {
		producer = fn
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection) {
		Applying.apply(to: to, producer: producer, with: trait)
	}
}

struct BackgroundImageApplying: StatefulImageApplying {
	static func apply(to: StyleApplyable, producer: (UITraitCollection) -> [UIControl.State : StyleImageSource], with trait: UITraitCollection) {
		for (state, source) in producer(trait) {
			source.loadImage { [weak to] (image) in
				switch to {
				case let view as UIButton:
					view.setBackgroundImage(image, for: state)
				case let view as UISearchBar:
					view.backgroundImage = image
				default:break
				}
			}
		}
	}
}

struct ImageApplying: StatefulImageApplying {
	static func apply(to: StyleApplyable, producer: (UITraitCollection) -> [UIControl.State : StyleImageSource], with trait: UITraitCollection) {
		for (state, source) in producer(trait) {
			source.loadImage { [weak to] (image) in
				switch to {
				case let layer as CALayer:
					layer.contents = image?.cgImage
				case let view as UIImageView:
					if state == .highlighted {
						view.highlightedImage = image
					} else {
						view.image = image
					}
				case let view as UIButton:
					view.setImage(image, for: state)
				case let view as UISlider:
					view.setThumbImage(image, for: state)
				case let item as UITabBarItem where state == .highlighted:
					item.selectedImage = image
				case let item as UIBarItem:
					item.image = image
				default:break
				}
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
	
	func apply(to: StyleApplyable, with trait: UITraitCollection) {
		guard let view = to as? UISlider else {return}
		for (state, source) in sourcesMin {
			source.loadImage {
				view.setMinimumTrackImage($0, for: state)
			}
		}
		for (state, source) in sourcesMax {
			source.loadImage {
				view.setMaximumTrackImage($0, for: state)
			}
		}
	}
}
#endif
