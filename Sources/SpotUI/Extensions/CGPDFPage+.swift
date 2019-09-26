//
//  CGPDFPage+.swift
//  SpotUI
//
//  Created by Shawn Clovie on 16/9/2017.
//  Copyright © 2017 Shawn Clovie. All rights reserved.
//

import Foundation
import CoreGraphics
#if canImport(UIKit)
import UIKit
#endif
import Spot

extension CGPDFPage: SuffixProtocol {
	public static func spot(from data: Data, page: Int = 1) -> CGPDFPage? {
		guard let provider = CGDataProvider(data: data as CFData),
			let doc = CGPDFDocument(provider) else {
				return nil
		}
		return doc.page(at: page)
	}
}

extension Suffix where Base: CGPDFPage {
	
	public func renderCGImage(by box: CGPDFBox = .cropBox, scale: CGFloat = 1) -> CGImage? {
		let viewportRect = base.getBoxRect(box)
		guard let context = CGContext(
			data: nil,
			width: Int(viewportRect.width * scale),
			height: Int(viewportRect.height * scale),
			bitsPerComponent: 8, bytesPerRow: 0,
			space: CGColorSpaceCreateDeviceRGB(),
			bitmapInfo: CGBitmapInfo().rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue) else {
				return nil
		}
		if scale > 0 && scale != 1 {
			context.scaleBy(x: scale, y: scale)
		}
		// Apply transform to context
		let trans = base.getDrawingTransform(box, rect: viewportRect, rotate: 0, preserveAspectRatio: true)
		context.concatenate(trans)
		context.drawPDFPage(base)
		return context.makeImage()
	}
	
	#if canImport(UIKit)
	/// Render image from pdf page.
	///
	/// - Parameters:
	///   - page: PDF page
	///   - box: PDFBox
	///   - contentSize: Renderering canvas size
	/// - Returns: Rendered or cached image.
	public func renderImage(by box: CGPDFBox = .cropBox, contentSize: CGSize = .zero) -> UIImage? {
		#if os(OSX)
			let uiScale: CGFloat = 1
		#else
			let uiScale = UIScreen.main.scale
		#endif
		var scale = uiScale
		if contentSize != .zero {
			let pageSize = base.getBoxRect(box).size
			scale *= min(contentSize.width / pageSize.width, contentSize.height / pageSize.height)
		}
		guard let cgImage = renderCGImage(by: box, scale: scale) else {
			return nil
		}
		#if os(OSX)
		return .init(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
		#else
		return .init(cgImage: cgImage, scale: uiScale, orientation: .up)
		#endif
	}
	#endif
}
