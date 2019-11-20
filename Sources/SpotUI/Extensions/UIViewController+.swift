//
//  UIViewController+.swift
//  SpotUI iOS
//
//  Created by Shawn Clovie on 20/11/2019.
//  Copyright © 2019 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import Foundation
import UIKit
import Spot

extension Suffix where Base: UIViewController {
	/// Add child view controller
	/// - Parameter child: Child view controller
	/// - Parameter parentView: Parent view that would contains the subview, or use parent view controler's view if it is nil.
	public func addChild(_ child: UIViewController, parentView: UIView? = nil) {
		base.addChild(child)
		(parentView ?? base.view).addSubview(child.view)
		child.didMove(toParent: base)
	}
	
	/// Remove view controller from parent view controller.
	public func removeFromParent() {
		base.willMove(toParent: nil)
		base.view.removeFromSuperview()
		base.removeFromParent()
	}
}
#endif
