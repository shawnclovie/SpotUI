//
//  ScrollableTabBarView.swift
//  Spot UI
//
//  Created by Shawn Clovie on 17/8/2017.
//  Copyright © 2017 Shawn Clovie. All rights reserved.
//

import UIKit
import Spot

public protocol ScrollableTabBarViewDelegate: class {
	func scrollableTabBar(view: ScrollableTabBarView, didSelect index: Int, info: ScrollableTabBarButton)
	func scrollableTabBar(view: ScrollableTabBarView, didTouch side: ScrollableTabBarButton.Side)
}

public struct ScrollableTabBarButton {
	public enum Side: Int {
		case leading, trailing
	}
	
	public enum Alignment {
		case leading, center, trailing, justified
	}
	
	public var title: String?
	public var image: UIImage?
	public var style: Style?
	public var mark: Any?
	public var handler: ((Int)->Void)?
	
	/// Make button info
	/// - Parameters:
	///   - title: Title if needed
	///   - image: Image if needed
	///   - style: Style to style the button if needed
	///   - mark: Any value to mark the button if needed
	///   - handler: Handler on touchUpInside with index of the button. The index would be -1 or .max for leading or trailing of Side.
	public init(title: String? = nil, image: UIImage? = nil, style: Style? = nil, mark: Any? = nil, handler: ((Int)->Void)? = nil) {
		self.title = title
		self.image = image
		self.style = style
		self.mark = mark
		self.handler = handler
	}
}

public struct ScrollableTabBarStyleSet {
	public static var shared = ScrollableTabBarStyleSet()
	
	public var view = Style()
		.backgroundColor{DecimalColor(rgb: $0.spot.userInterfaceStyle == .dark ? 0x101010 : 0xfdfdfd).colorValue}
	
	/// Set leading to layout top for horizontal, left for vertical
	///
	/// Set trailing to layout bottom for horizontal, right for vertical
	public var selectIndicatorPosition: ScrollableTabBarButton.Side = .trailing
	/// Set indicator height for horizontal, width for vertical.
	public var selectIndicatorSize: CGFloat = 4
	public var selectIndicator = Style()
		.backgroundColor(StyleShared.tintColorProducer)
	
	public var button = Style()
		.textColor(StyleShared.foregroundTextColorProducer)
		.font{_ in .systemFont(ofSize: 18)}
		.padding{_ in .init(top: 6, left: 10, bottom: 6, right: 10)}
	public var buttonStack = Style()
		.stackDistribution(.equalSpacing)
	
	public var sideButton = Style()
		.textColor(StyleShared.foregroundTextColorProducer)
		.padding{_ in .init(top: 8, left: 8, bottom: 8, right: 8)}
}

public final class ScrollableTabBarView: UIStackView {
	
	private struct Model {
		let button: UIButton
		let originalSize: CGSize
		var info: ScrollableTabBarButton
	}
	
	public weak var delegate: ScrollableTabBarViewDelegate?
	
	public var selectedIndex = -1 {
		didSet {
			updateSelectIndicator(from: oldValue, animated: oldValue >= 0)
		}
	}
	
	public var style: ScrollableTabBarStyleSet = .shared
	
	private var sideButtons: [ScrollableTabBarButton.Side: Model] = [:]
	private let contentView = UIScrollView()
	private let buttonStack = UIStackView(frame: .zero)
	private var buttonStackContraints: [NSLayoutConstraint] = []
	private let selectIndicator = UIView()
	private var models: [Model] = []
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		if #available(iOS 11.0, *) {
			contentView.contentInsetAdjustmentBehavior = .never
		}
		contentView.showsHorizontalScrollIndicator = false
		contentView.showsVerticalScrollIndicator = false
		addArrangedSubview(contentView)
		
		selectIndicator.isUserInteractionEnabled = false
		buttonStack.translatesAutoresizingMaskIntoConstraints = false
		
		contentView.addSubview(buttonStack)
		contentView.addSubview(selectIndicator)
		contentView.spot.constraints(buttonStack)
		axis = .horizontal
	}
	
	required public init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override var axis: NSLayoutConstraint.Axis {
		didSet {
			guard axis != oldValue else {return}
			buttonStack.axis = axis
			removeConstraints(buttonStackContraints)
			buttonStackContraints = [axis == .horizontal
				? buttonStack.heightAnchor.constraint(equalTo: heightAnchor)
				: buttonStack.widthAnchor.constraint(equalTo: widthAnchor)]
			buttonStackContraints.spot_set(active: true)
		}
	}
	
	public override func didMoveToWindow() {
		super.didMoveToWindow()
		resetStyle()
	}
	
	public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		resetStyle()
	}
	
	public override func layoutSubviews() {
		super.layoutSubviews()
		let size = bounds.size
		let isHorizontal = axis == .horizontal
		contentView.contentSize = buttonStack.bounds.size
		let indicatorH_2 = style.selectIndicatorSize * 0.5
		if isHorizontal {
			selectIndicator.center.y = style.selectIndicatorPosition == .leading ? indicatorH_2 : size.height - indicatorH_2
		} else {
			selectIndicator.center.x = style.selectIndicatorPosition == .leading ? indicatorH_2 : size.width - indicatorH_2
		}
		updateSelectIndicator(from: selectedIndex, animated: false)
	}
	
	public func set(sideButton info: ScrollableTabBarButton,
					at side: ScrollableTabBarButton.Side) {
		let button: UIButton
		if var v = sideButtons[side] {
			button = v.button
			v.info = info
			sideButtons[side] = v
		} else {
			button = UIButton(type: .custom)
			button.tag = side.rawValue
			self.style.sideButton.apply(to: button, with: traitCollection)
			button.addTarget(self, action: #selector(touchUp(side:)), for: .touchUpInside)
			sideButtons[side] = .init(button: button, originalSize: .zero, info: info)
			switch side {
			case .leading:
				insertArrangedSubview(button, at: 0)
			case .trailing:
				addArrangedSubview(button)
			}
		}
		button.setTitle(info.title, for: .normal)
		button.setImage(info.image, for: .normal)
		info.style?.apply(to: button, with: traitCollection)
		button.sizeToFit()
	}
	
	public func button(at index: Int) -> ScrollableTabBarButton? {
		models.spot_value(at: index)?.info
	}
	
	public func add(button info: ScrollableTabBarButton) {
		let button = UIButton(type: .custom)
		info.title.map{button.setTitle($0, for: .normal)}
		info.image.map{button.setImage($0, for: .normal)}
		self.style.button.apply(to: button, with: traitCollection)
		info.style?.apply(to: button, with: traitCollection)
		button.addTarget(self, action: #selector(touchUp(item:)), for: .touchUpInside)
		button.center = .zero
		button.tag = models.count
		models.append(Model(button: button, originalSize: button.bounds.size, info: info))
		buttonStack.addArrangedSubview(button)
		selectIndicator.isHidden = models.count <= 1
	}
	
	func resetStyle() {
		style.view.apply(to: self, with: traitCollection)
		style.selectIndicator.apply(to: selectIndicator, with: traitCollection)
		if axis == .horizontal {
			selectIndicator.bounds.size.height = style.selectIndicatorSize
		} else {
			selectIndicator.bounds.size.width = style.selectIndicatorSize
		}
		sideButtons.forEach{
			style.sideButton.apply(to: $0.value.button, with: traitCollection)}
		style.buttonStack.apply(to: buttonStack, with: traitCollection)
		models.forEach{
			style.button.apply(to: $0.button, with: traitCollection)}
	}
	
	private func updateSelectIndicator(from oldIndex: Int, animated: Bool) {
		guard models.indices.contains(selectedIndex) else {
			return
		}
		layoutIfNeeded()
		selectIndicator.layer.removeAllAnimations()
		let button = models[selectedIndex].button
		let indicator = selectIndicator
		let container = contentView
		let btnSize = button.bounds.size
		let btnCenter = button.center
		let containerSize = container.bounds.size
		let fn = {
			if self.axis == .horizontal {
				indicator.center.x = btnCenter.x
				indicator.bounds.size.width = btnSize.width
				if containerSize.width > 0 {
					var offset = container.contentOffset
					if btnCenter.x < offset.x {
						offset.x = max(btnCenter.x - (containerSize.width - btnSize.width) / 2, 0)
					} else if btnCenter.x + btnSize.width > offset.x + containerSize.width {
						offset.x = min(btnCenter.x - (containerSize.width - btnSize.width) / 2, container.contentSize.width - containerSize.width)
					}
					container.setContentOffset(offset, animated: false)
				}
			} else {
				indicator.center.y = btnCenter.y
				indicator.bounds.size.height = btnSize.height
				if containerSize.height > 0 {
					var offset = container.contentOffset
					if btnCenter.y < offset.y {
						offset.y = max(btnCenter.y - (containerSize.height - btnSize.height) / 2, 0)
					} else if btnCenter.y + btnSize.height > offset.y + containerSize.height {
						offset.y = min(btnCenter.y - (containerSize.height - btnSize.height) / 2, container.contentSize.height - containerSize.height)
					}
					container.setContentOffset(offset, animated: false)
				}
			}
		}
		if animated && selectedIndex != oldIndex {
			UIView.animate(withDuration: 0.2, animations: fn)
		} else {
			fn()
		}
	}
	
	@objc private func touchUp(side button: UIButton) {
		guard let side = ScrollableTabBarButton.Side(rawValue: button.tag) else {
			return
		}
		if let fn = sideButtons[side]?.info.handler {
			fn(side == .leading ? -1 : .max)
		}
		delegate?.scrollableTabBar(view: self, didTouch: side)
	}
	
	@objc private func touchUp(item: UIButton) {
		guard let model = models.spot_value(at: item.tag) else {
			return
		}
		model.info.handler?(item.tag)
		delegate?.scrollableTabBar(view: self, didSelect: item.tag, info: model.info)
	}
}
