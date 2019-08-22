//
//  WeakProxy.swift
//  SpotUI
//
//  Created by Shawn Clovie on 12/1/2019.
//  Copyright © 2019 Shawn Clovie. All rights reserved.
//

import Foundation

public final class WeakProxy {
	public private(set) weak var target: NSObject?
	private let action: Selector
	
	public init(_ target: NSObject, _ act: Selector) {
		self.target = target
		action = act
	}
	
	@objc public func event(_ arg: Any) {
		guard let tar = target, tar.responds(to: action) else {return}
		_ = tar.perform(action, with: arg)
	}
}
