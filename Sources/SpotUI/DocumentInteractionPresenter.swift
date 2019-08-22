//
//  DocumentInteractionPresenter.swift
//  SpotUI
//
//  Created by Shawn Clovie on 16/02/2017.
//  Copyright © 2017 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public final class DocumentInteractionPresenter: NSObject, UIDocumentInteractionControllerDelegate {
	public static let shared = DocumentInteractionPresenter()
	
	fileprivate var presenting: UIDocumentInteractionController?
	private var completion: (()->Void)?
	
	@discardableResult
	public func presentController(withFile url: URL, parent: UIView, uti: String?, annotation: Any? = nil, completion: (()->Void)? = nil) -> Bool {
		guard presenting == nil else {
			return false
		}
		let ctl = UIDocumentInteractionController(url: url)
		ctl.delegate = self
		ctl.uti = uti
		ctl.annotation = annotation
		presenting = ctl
		self.completion = completion
		return ctl.presentOpenInMenu(from: parent.bounds, in: parent, animated: true)
	}
	
	@objc public func documentInteractionControllerDidDismissOpenInMenu(_ controller: UIDocumentInteractionController) {
		presenting = nil
		completion?()
		completion = nil
	}
}
#endif
