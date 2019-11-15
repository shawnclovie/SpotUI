//
//  ScrollableTabBarController.swift
//  Spot UI
//
//  Created by Shawn Clovie on 17/8/2017.
//  Copyright © 2017 Shawn Clovie. All rights reserved.
//

import UIKit
import Spot

public enum ScrollableTabBarPosition {
	case top, bottom
}

public protocol ScrollableTabBarControllerDelegate: class {
	func scrollableTabBar(controller: ScrollableTabBarController,
	                      shouldAnimatingScrollToTab index: Int) -> Bool
	func scrollableTabBar(controller: ScrollableTabBarController,
						  didTouchSideButton side: ScrollableTabBarButton.Side)
}

extension ScrollableTabBarControllerDelegate {
	public func scrollableTabBar(controller: ScrollableTabBarController, shouldAnimatingScrollToTab index: Int) -> Bool {
		false
	}
	
	public func scrollableTabBar(controller: ScrollableTabBarController, didTouchSideButton side: ScrollableTabBarButton.Side) {
	}
}

open class ScrollableTabBarController: UIViewController, UIScrollViewDelegate, ScrollableTabBarViewDelegate {
	
	public struct StyleSet {
		public static var shared = StyleSet()
		
		public var view = Style()
			.backgroundColor(StyleShared.backgroundColorProducer)
	}
	
	public weak var delegate: ScrollableTabBarControllerDelegate?
	
	public var tabBarPosition: ScrollableTabBarPosition = .top {
		didSet {
			updateVStackArrangedSubviews()
		}
	}
	public var style: StyleSet = .shared
	
	public private(set) var contentViewControllers: ContiguousArray<UIViewController> = []
	
	private var tabBarHiddenConstraint: NSLayoutConstraint?
	private let vStack = UIStackView()
	private let tabBar = ScrollableTabBarView(frame: .zero)
	private let contentView = UIScrollView()
	
	open override func viewDidLoad() {
		super.viewDidLoad()
		if #available(iOS 11.0, *) {
			contentView.contentInsetAdjustmentBehavior = .never
		}
		automaticallyAdjustsScrollViewInsets = false
		
		vStack.axis = .vertical
		vStack.alignment = .fill
		vStack.distribution = .fill
		view.addSubview(vStack)
		tabBar.axis = .horizontal
		tabBar.delegate = self
		
		contentView.delegate = self
		contentView.isPagingEnabled = true
		contentView.bounces = false
		contentView.showsHorizontalScrollIndicator = false
		
		[
			vStack.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
			vStack.leftAnchor.constraint(equalTo: view.leftAnchor),
			vStack.rightAnchor.constraint(equalTo: view.rightAnchor),
			vStack.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor),
		].spot_set(active: true)
		tabBarHiddenConstraint = tabBar.heightAnchor.constraint(equalToConstant: 0)
		
		updateVStackArrangedSubviews()
		resetStyle()
	}
	
	open override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		updateContentView()
		if tabBar.selectedIndex < 0 {
			tabBar.selectedIndex = 0
		}
	}
	
	open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		let offset = CGPoint(x: CGFloat(tabBar.selectedIndex) * size.width, y: 0)
		contentView.setContentOffset(offset, animated: true)
	}
	
	open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		resetStyle()
	}
	
	open func resetStyle() {
		style.view.apply(to: view, with: traitCollection)
	}
	
	public func setBarSideButton(of side: ScrollableTabBarButton.Side, _ info: ScrollableTabBarButton) {
		tabBar.set(sideButton: info, at: side)
	}
	
	public func setBarStack(style: Style) {
		tabBar.style.buttonStack = style
		tabBar.resetStyle()
	}
	
	public func setBar(hidden: Bool) {
		tabBar.isHidden = hidden
		tabBarHiddenConstraint?.isActive = hidden
	}
	
	public func add(contentViewController vc: UIViewController, tab info: ScrollableTabBarButton = .init()) {
		if contentViewControllers.isEmpty {
			contentView.addSubview(vc.view)
			addChild(vc)
		}
		contentViewControllers.append(vc)
		tabBar.add(button: info)
		updateContentView()
	}
	
	public var selectedIndex: Int {
		tabBar.selectedIndex
	}
	
	public func set(selected vc: UIViewController, animated: Bool) {
		guard let index = contentViewControllers.firstIndex(of: vc) else {return}
		set(selectedIndex: index, animated: animated)
	}
	
	public func set(selectedIndex: Int, animated: Bool) {
		guard contentViewControllers.indices.contains(selectedIndex) else {return}
		tabBar.selectedIndex = selectedIndex
		view.layoutIfNeeded()
		contentView.setContentOffset(CGPoint(x: CGFloat(selectedIndex) * view.bounds.width, y: 0), animated: animated)
	}
	
	private func updateVStackArrangedSubviews() {
		if vStack.arrangedSubviews.isEmpty {
			vStack.addArrangedSubview(contentView)
		} else {
			vStack.removeArrangedSubview(tabBar)
		}
		if tabBarPosition == .top {
			vStack.insertArrangedSubview(tabBar, at: 0)
		} else {
			vStack.addArrangedSubview(tabBar)
		}
	}
	
	private func updateContentView() {
		contentView.contentSize = CGSize(width: view.bounds.width * CGFloat(contentViewControllers.count), height: 0)
		var frame = contentView.bounds
		for (index, vc) in contentViewControllers.enumerated() where vc.parent != nil {
			frame.origin.x = frame.width * CGFloat(index)
			vc.view.frame = frame
		}
	}
	
	open func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let pagePosition = scrollView.contentOffset.x / view.bounds.width
		let page = Int(pagePosition)
		let nextPage = Int(ceil(pagePosition))
		for index in [page, nextPage] {
			guard contentViewControllers.indices.contains(index) else {
				continue
			}
			let vc = contentViewControllers[index]
			if vc.parent == nil {
				contentView.addSubview(vc.view)
				addChild(vc)
				updateContentView()
			}
		}
		if tabBar.selectedIndex != page {
			tabBar.selectedIndex = page
			_ = delegate?.scrollableTabBar(controller: self, shouldAnimatingScrollToTab: page)
		}
	}
	
	open func scrollableTabBar(view: ScrollableTabBarView, didTouch side: ScrollableTabBarButton.Side) {
		delegate?.scrollableTabBar(controller: self, didTouchSideButton: side)
	}
	
	open func scrollableTabBar(view: ScrollableTabBarView, didSelect index: Int, info: ScrollableTabBarButton) {
		let animated = delegate?.scrollableTabBar(controller: self, shouldAnimatingScrollToTab: index)
		let offset = CGPoint(x: CGFloat(index) * contentView.bounds.width, y: 0)
		contentView.setContentOffset(offset, animated: animated ?? true)
	}
}
