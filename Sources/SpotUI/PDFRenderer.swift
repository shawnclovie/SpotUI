//
//  PDFRenderer.swift
//  SpotUI
//
//  Created by Shawn Clovie on 9/5/2018.
//  Copyright © 2018 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit

/// UIGraphics based PDF Renderer
public struct PDFRenderer {
	
	public static func render(size: CGSize = .zero, invoking: (PDFRenderer) throws ->Void) rethrows -> Data {
		let data = NSMutableData()
		UIGraphicsBeginPDFContextToData(data, CGRect(origin: .zero, size: size), nil)
		do {
			try invoking(PDFRenderer())
			UIGraphicsEndPDFContext()
		} catch {
			UIGraphicsEndPDFContext()
			throw error
		}
		return data as Data
	}
	
	public func newPage(size: CGSize, pageInfo: [AnyHashable: Any]? = nil) {
		UIGraphicsBeginPDFPageWithInfo(CGRect(origin: .zero, size: size), pageInfo)
	}
	
	public func newPage(with view: UIView) {
		newPage(size: view.bounds.size, pageInfo: nil)
		// the context should obtain after UIGraphicsBeginPDFContextToData
		if let ctx = UIGraphicsGetCurrentContext() {
			view.layer.render(in: ctx)
		}
	}
}
#endif
