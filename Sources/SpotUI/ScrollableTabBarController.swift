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
	/// On selected tab, should scroll to the view controller animated? true by default.
	func scrollableTabBar(controller: ScrollableTabBarController,
	                      shouldAnimatingScrollToTab index: Int) -> Bool
	func scrollableTabBar(controller: ScrollableTabBarController,
						  didTouchSideButton side: ScrollableTabBarView.Side)
}

extension ScrollableTabBarControllerDelegate {
	public func scrollableTabBar(controller: ScrollableTabBarController, shouldAnimatingScrollToTab index: Int) -> Bool {
		true
	}
	
	public func scrollableTabBar(controller: ScrollableTabBarController, didTouchSideButton side: ScrollableTabBarView.Side) {
	}
}

open class ScrollableTabBarController: UIViewController, UIScrollViewDelegate, ScrollableTabBarViewDelegate {
	
	public struct StyleSet {
		public static var shared = StyleSet()
		
		public var view = Style()
			.backgroundColor(StyleShared.backgroundColorProducer)
	}
	
	public weak var delegate: ScrollableTabBarControllerDelegate?
	
	public private(set) var tabBarPosition: ScrollableTabBarPosition = .top
	public private(set) var shouldTabBarCoverContentView = false
	
	public var style: StyleSet = .shared
	
	public private(set) var contentViewControllers: ContiguousArray<UIViewController> = []
	
	private let tabBar: ScrollableTabBarView
	private var tabBarConstraints: [NSLayoutConstraint.Attribute: NSLayoutConstraint] = [:]
	private let contentView = UIScrollView()
	private var contentViewConstraints: [NSLayoutConstraint.Attribute: NSLayoutConstraint] = [:]
	
	public init(barAlignment: ScrollableTabBarView.Alignment) {
		tabBar = .init(frame: .zero, axis: .horizontal, alignment: barAlignment)
		super.init(nibName: nil, bundle: nil)
	}
	
	required public init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	open override func viewDidLoad() {
		super.viewDidLoad()
		if #available(iOS 11.0, *) {
			contentView.contentInsetAdjustmentBehavior = .never
		}
		automaticallyAdjustsScrollViewInsets = false
		
		tabBar.setContentHuggingPriority(.required, for: .vertical)
		tabBar.setContentCompressionResistancePriority(.required, for: .vertical)
		tabBar.delegate = self
		
		contentView.delegate = self
		contentView.isPagingEnabled = true
		contentView.bounces = false
		contentView.showsHorizontalScrollIndicator = false
		view.addSubview(contentView)
		view.spot.constraints(contentView).forEach{
			contentViewConstraints[$0.firstAttribute] = $0
		}
		view.addSubview(tabBar)
		view.spot.constraints(tabBar).forEach {
			tabBarConstraints[$0.firstAttribute] = $0
		}
		resetStyle()
	}
	
	open override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		updateContentView()
		updateLayout()
		if tabBar.selectedIndex < 0 {
			tabBar.set(selectedIndex: 0, highlightButton: true, animated: false)
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
	
	// MARK: - Access TabBar
	
	public var barSelectedIndex: Int {tabBar.selectedIndex}
	public var barButtons: [ScrollableTabBarButton] {tabBar.buttons}
	
	public func setBar(alignment: ScrollableTabBarView.Alignment) {
		tabBar.set(axis: .horizontal, alignment: alignment)
	}
	
	public func setBar(sideButtons: [ScrollableTabBarView.Side: ScrollableTabBarButton]) {
		tabBar.set(sideButtons: sideButtons)
	}
	
	public func setBar(styleSet: ScrollableTabBarStyleSet) {
		tabBar.style = styleSet
		tabBar.resetStyle()
	}
	
	public func setBar(styles: [WritableKeyPath<ScrollableTabBarStyleSet, Style>: Style]) {
		for it in styles {
			tabBar.style[keyPath: it.key] = it.value
		}
		tabBar.resetStyle()
	}
	
	public var isBarHidden: Bool {
		get {tabBar.isHidden}
		set {tabBar.isHidden = newValue}
	}
	
	/// Set bar hidden with animation
	public func setBar(hidden: Bool, duration: TimeInterval = 0.2) {
		let oldHidden = tabBar.isHidden
		guard hidden != oldHidden else {return}
		let height = tabBar.bounds.height
		let isTop = tabBarPosition == .top
		let transOnHidden = CGAffineTransform(translationX: 0, y: isTop ? -height : height)
		tabBar.transform = oldHidden ? transOnHidden : .identity
		tabBar.isHidden = false
		UIView.animate(withDuration: duration, animations: {
			self.tabBar.transform = hidden ? transOnHidden : .identity
		}) { _ in
			self.tabBar.isHidden = hidden
		}
	}
	
	public func setBar(position: ScrollableTabBarPosition, cover: Bool) {
		tabBarPosition = position
		shouldTabBarCoverContentView = cover
		updateLayout()
	}
	
	// MARK: - Content View Controller
	
	public func add(viewController vc: UIViewController, tab info: ScrollableTabBarButton = .init()) {
		add(viewControllers: [(vc, info)])
	}
	
	public func add(viewControllers infos: [(UIViewController, ScrollableTabBarButton)]) {
		guard let first = infos.first else {return}
		if contentViewControllers.isEmpty {
			spot.addChild(first.0, parentView: contentView)
		}
		for it in infos {
			contentViewControllers.append(it.0)
			tabBar.add(button: it.1)
		}
		updateContentView()
	}
	
	public func insert(viewController: UIViewController, tab: ScrollableTabBarButton, at: Int) {
		guard contentViewControllers.indices.contains(at) else {
			add(viewController: viewController, tab: tab)
			return
		}
		if contentViewControllers.isEmpty {
			spot.addChild(viewController, parentView: contentView)
		}
		contentViewControllers.insert(viewController, at: at)
		updateContentView()
		let tabSelectedIndex = tabBar.selectedIndex
		tabBar.insert(button: tab, at: at, animated: false)
		let newIndex = tabSelectedIndex + (tabSelectedIndex >= at ? 1 : 0)
		setContentOffset(selectedIndex: newIndex, animated: false)
	}
	
	@discardableResult
	public func removeViewController(at: Int) -> ScrollableTabBarButton? {
		guard contentViewControllers.indices.contains(at) else {return nil}
		let tabSelectedIndex = tabBar.selectedIndex
		let newIndex = min(tabSelectedIndex - (tabSelectedIndex > at ? 1 : 0), contentViewControllers.count - 1)
		let tab = tabBar.removeButton(at: at)
		let vc = contentViewControllers.remove(at: at)
		vc.spot.removeFromParent()
		updateContentView()
		setContentOffset(selectedIndex: newIndex, animated: false)
		scrollViewDidScroll(contentView)
		return tab
	}
	
	public func set(selected vc: UIViewController, animated: Bool) {
		guard let index = contentViewControllers.firstIndex(of: vc) else {return}
		set(selectedIndex: index, animated: animated)
	}
	
	public func set(selectedIndex: Int, animated: Bool) {
		guard contentViewControllers.indices.contains(selectedIndex) else {return}
		tabBar.set(selectedIndex: CGFloat(selectedIndex), highlightButton: true, animated: animated)
		view.layoutIfNeeded()
		contentView.setContentOffset(CGPoint(x: CGFloat(selectedIndex) * view.bounds.width, y: 0), animated: animated)
	}
	
	private func updateLayout() {
		let isTop = tabBarPosition == .top
		let attrOld: NSLayoutConstraint.Attribute = isTop ? .bottom : .top
		let attrNew: NSLayoutConstraint.Attribute = isTop ? .top : .bottom
		tabBarConstraints[attrOld]?.isActive = false
		tabBarConstraints[attrNew]?.isActive = true
		if !shouldTabBarCoverContentView {
			let barHeight = tabBar.isHidden ? 0 : tabBar.bounds.height
			contentViewConstraints[attrOld]?.constant = 0
			contentViewConstraints[attrNew]?.constant = attrNew == .bottom ? -barHeight : barHeight
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
		guard view.bounds.width > 0 else {return}
		let pagePosition = scrollView.contentOffset.x / view.bounds.width
		let pageRange = floor(pagePosition)...ceil(pagePosition)
		for index in [Int(pageRange.lowerBound), Int(pageRange.upperBound)] {
			guard contentViewControllers.indices.contains(index) else {
				continue
			}
			let vc = contentViewControllers[index]
			if vc.parent == nil {
				spot.addChild(vc, parentView: contentView)
				updateContentView()
			}
		}
		tabBar.set(selectedIndex: pagePosition, highlightButton: pageRange.lowerBound == pageRange.upperBound, animated: false)
	}
	
	open func scrollableTabBar(view: ScrollableTabBarView, didTouch side: ScrollableTabBarView.Side) {
		delegate?.scrollableTabBar(controller: self, didTouchSideButton: side)
	}
	
	open func scrollableTabBar(view: ScrollableTabBarView, didSelect index: Int, info: ScrollableTabBarButton) {
		let animated = delegate?.scrollableTabBar(controller: self, shouldAnimatingScrollToTab: index)
		setContentOffset(selectedIndex: index, animated: animated ?? true)
	}
	
	private func setContentOffset(selectedIndex: Int, animated: Bool) {
		let offset = CGPoint(x: CGFloat(selectedIndex) * contentView.bounds.width, y: 0)
		contentView.setContentOffset(offset, animated: animated)
	}
}
