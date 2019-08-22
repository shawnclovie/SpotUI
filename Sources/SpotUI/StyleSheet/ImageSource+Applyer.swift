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

public enum StyleImageSource {
	case empty
	case solidColor(UIColor)
	case name(name: String, size: CGSize, template: Bool)
	case url(url: URL, placeholder: String?, template: Bool)
	
	init(with data: [AnyHashable: Any], predefined: StyleValueSet) {
		if let value = predefined.value(for: data["url"]) as? String,
			let url = URL(string: value) {
			self = .url(url: url,
						placeholder: predefined.value(for: data["placeholder"]) as? String,
						template: data["template"] as? Bool ?? false)
		} else if let name = predefined.value(for: data["name"]) as? String {
			self = .name(name: name,
						 size: CGSize.spot(predefined.value(for: data["size"])) ?? .zero,
						 template: data["template"] as? Bool ?? false)
		} else if let value = predefined.value(for: data["solid-color"]) as? String,
			let color = DecimalColor(hexARGB: value) {
			self = .solidColor(color.colorValue)
		} else {
			self = .empty
		}
	}
	
	func loadImage(completion: @escaping (UIImage?)->Void) {
		switch self {
		case .empty:
			completion(nil)
		case .name(let it):
			completion(Self.loadImage(name: it.name, size: it.size, template: it.template))
		case .solidColor(let color):
			let image = color.cgColor
				.spot.solidImage(width: 1, height: 1)
				.map(UIImage.init(cgImage:))
			completion(image)
		case .url(let it):
			completion(Self.loadImage(name: it.placeholder, size: .zero, template: it.template))
			Cache<UIImage>.shared.fetch(it.url) { result in
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

struct BackgroundImageApplyer: StyleApplyer {
	var producer: (UITraitCollection)->[UIControl.State: StyleImageSource]
	
	init(with value: Any, predefined: StyleValueSet) {
		let images = parseStatefulImages(with: value, predefined: predefined)
		producer = {_ in images}
	}
	
	init(_ fn: @escaping (UITraitCollection)->[UIControl.State: StyleImageSource]) {
		producer = fn
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection) {
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

struct ImageApplyer: StyleApplyer {
	var producer: (UITraitCollection)->[UIControl.State: StyleImageSource]
	
	init(with value: Any, predefined: StyleValueSet) {
		let images = parseStatefulImages(with: value, predefined: predefined)
		producer = {_ in images}
	}
	
	init(_ fn: @escaping (UITraitCollection)->[UIControl.State: StyleImageSource]) {
		producer = fn
	}
	
	func apply(to: StyleApplyable, with trait: UITraitCollection) {
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
