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
	/// Add child view controller and add child.view to base.view as subview
	/// - Parameter child: Child view controller
	public func addChild(_ child: UIViewController) {
		addChild(child, parentView: base.view)
	}
	
	/// Add child view controller
	/// - Parameter child: Child view controller
	/// - Parameter parentView: Parent view that would contains the child.view if the parameter not nil.
	public func addChild(_ child: UIViewController, parentView: UIView?) {
		base.addChild(child)
		if let parent = parentView {
			parent.addSubview(child.view)
		}
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
