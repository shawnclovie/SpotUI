//
//  UIAlertController+.swift
//  SpotUI
//
//  Created by Shawn Clovie on 28/9/2018.
//  Copyright © 2018 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import Spot

extension Suffix where Base: UIAlertController {
	public func setPopoverSource(view: UIView?, frame: CGRect) {
		guard let popover = base.popoverPresentationController else {return}
		popover.sourceView = view
		popover.sourceRect = frame
	}
}

extension UIAlertController {
	/// Make a UIAlertController
	/// - Parameter title: Title
	/// - Parameter message: Message
	/// - Parameter preferredStyle: Alert style
	/// - Parameter actions: Actions
	///
	/// The convenience initializer would prevent exception while both title and message are nil. You can provide all actions, and popover source if needed.
	public convenience init(title: String?,
						    message: String?,
						    preferredStyle: UIAlertController.Style,
						    actions: [UIAlertAction],
							popover source: (UIView, CGRect)? = nil) {
		self.init(title: title == nil && message == nil ? "" : title, message: message, preferredStyle: preferredStyle)
		actions.forEach(addAction)
		if let popover = source {
			spot.setPopoverSource(view: popover.0, frame: popover.1)
		}
	}
}
#endif
