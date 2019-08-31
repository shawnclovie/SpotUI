//
//  UITableView+.swift
//  SpotUI
//
//  Created by Shawn Clovie on 14/5/2019.
//  Copyright © 2019 Shawn Clovie. All rights reserved.
//

import UIKit
import Spot

extension Suffix where Base == UITableView {
	/// Deselect row with transition animation if there is row was selected.
	///
	/// Usage: Calling the function in viewWillAppear, and don't deselect in tableView(_:didSelectRowAt:) if the row should have the animation.
	public func deselectRowIfNeeded(with coord: UIViewControllerTransitionCoordinator?, animated: Bool) {
		guard let selectedIP = base.indexPathForSelectedRow else {return}
		if let coord = coord {
			coord.animate(alongsideTransition: { _ in
				self.base.deselectRow(at: selectedIP, animated: true)
			}) { ctx in
				guard ctx.isCancelled else {return}
				self.base.selectRow(at: selectedIP, animated: true, scrollPosition: .none)
			}
		} else {
			base.deselectRow(at: selectedIP, animated: animated)
		}
	}
}
