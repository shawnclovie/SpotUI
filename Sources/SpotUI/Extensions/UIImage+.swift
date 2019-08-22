//
//  UIImage+.swift
//  SpotUI
//
//  Created by Shawn Clovie on 3/11/16.
//  Copyright © 2016 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import Spot
import SpotCache

extension UIImage {

	/// Load PDF document and render image for any page, would save rendered image to DefaultImageCache.
	///
	/// - Parameters:
	///   - name: PDF basename, should be found by Bundle.url(forResource: name, withExtension: "pdf").
	///   - pageIndex: Page index based 1, default 1.
	///   - bundle: Bundle to search file, default .main.
	///   - box: PDFBox
	///   - canvasSize: Renderering canvas size
	/// - Returns: Rendered or cached image.
	public static func spot_fromPDF(named name: String,
									in bundle: Bundle = .main,
									page: Int = 1,
									box: CGPDFBox = .cropBox,
									contentSize: CGSize = .zero) -> UIImage? {
		guard let url = bundle.url(forResource: name, withExtension: name.hasSuffix(".pdf") ? nil : "pdf") else {
			return nil
		}
		return spot_fromPDF(url, page: page, box: box, contentSize: contentSize)
	}
	
	public static func spot_fromPDF(_ url: URL,
									page: Int = 1,
									box: CGPDFBox = .cropBox,
									contentSize: CGSize = .zero) -> UIImage? {
		let cacheURL = contentSize == .zero ? url
			: url.appendingPathExtension("\(Int(contentSize.width))x\(Int(contentSize.height))")
		if let image = Cache<UIImage>.shared.retrieveItemInMemoryCache(for: cacheURL) {
			return image
		}
		guard let doc = CGPDFDocument(url as CFURL),
			let page = doc.page(at: page) else {
				return nil
		}
		guard let image = page.spot.renderImage(by: box, contentSize: contentSize) else {
			return nil
		}
		Cache<UIImage>.shared.saveToMemoryCache(image, for: cacheURL)
		return image
	}
	
	/// Get data format, may be pdf | jpg | png | gif | webp | ""
	public static func spot_formatByHeader(of data: Data) -> String? {
		if data.count > 20 {
			if data[0...1] == Data([0xff, 0xd8]) {
				return "jpg"
			}
			let prefix4b = data[0...3]
			if prefix4b == Data([0x25, 0x50, 0x44, 0x46]) {
				return "pdf"
			}
			if prefix4b == Data([0x89, 0x50, 0x4e, 0x47]) {
				return "png"
			}
			if prefix4b == Data([0x47, 0x49, 0x46, 0x38]) {
				return "gif"
			}
			if prefix4b == Data([0x52, 0x49, 0x46, 0x46]) && data[8...11] == Data([0x57, 0x45, 0x42, 0x50]) {
				return "webp"
			}
		}
		return nil
	}
}

extension Suffix where Base: UIImage {

	/// Create partial image in rect.
	/// - parameter rect:  Rectangle in source image
	/// - returns: Partial image if create operate did succeed.
	public func partial(in rect: CGRect) -> UIImage? {
		let scale = base.scale
		let scaledRect = CGRect(x: max(0, rect.origin.x * scale),
								y: max(0, rect.origin.y * scale),
		                        width: min(base.size.width, rect.size.width) * scale,
								height: min(base.size.height, rect.size.height) * scale)
		if scaledRect == CGRect(origin: .zero, size: base.size) {
			return base
		}
		guard let cg = base.cgImage, let newCGImage = cg.cropping(to: scaledRect) else {
			return nil
		}
		#if os(OSX)
		return .init(cgImage: newCGImage, size: scaledRect.size)
		#else
		return .init(cgImage: newCGImage, scale: scale, orientation: base.imageOrientation)
		#endif
	}

	/// Create partial image in center area.
	/// - parameter size:  Partial image size
	/// - returns: Partial image if create operate did succeed.
	public func partial(fromCenter size: CGSize) -> UIImage? {
		let rect = CGRect(x: (base.size.width - size.width) * 0.5,
		                  y: (base.size.height - size.height) * 0.5,
		                  width: size.width, height: size.height)
		return partial(in: rect)
	}

	#if !os(OSX)
	public var resizabled: UIImage {
		let size = base.size
		return base.resizableImage(withCapInsets: .init(
			top: floor((size.height - 1) * 0.5),
			left: floor((size.width - 1) * 0.5),
			bottom: ceil((size.height - 1) * 0.5),
			right: ceil((size.width - 1) * 0.5)))
	}
	#endif
}
#endif
