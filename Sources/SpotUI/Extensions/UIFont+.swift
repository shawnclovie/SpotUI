//
//  UIFont+.swift
//  SpotUI
//
//  Created by Shawn Clovie on 25/1/2018.
//  Copyright © 2018 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import Spot

extension Suffix where Base: UIFont {
	/// Calculate size for rendering string.
	///
	/// - Parameters:
	///   - text: String to render with the font
	///   - constrainedSize: Constrained size, default by (.greatestFiniteMagnitude, .greatestFiniteMagnitude)
	///   - lineBreakMode: Line break mode, default by word wrapping
	public func renderSize(for text: String?,
						   constrainedSize: CGSize = .init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
						   _ lineBreakMode: NSLineBreakMode = .byWordWrapping) -> CGSize {
		guard let text = text, !text.isEmpty else {return .zero}
		let paraStyle = NSMutableParagraphStyle()
		paraStyle.lineBreakMode = lineBreakMode
		return (text as NSString)
			.boundingRect(with: constrainedSize, options: [.usesLineFragmentOrigin],
						  attributes: [.font: base, .paragraphStyle: paraStyle],
						  context: nil)
			.size
	}
}
#endif
