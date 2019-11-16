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
	public var style = Style()
		.textColor(StyleShared.foregroundTextColorProducer)
	public var selectedStyle = Style()
		.textColor(StyleShared.foregroundTextColorProducer)
	public var mark: Any?
	public var handler: ((Int)->Void)?
	
	/// Make button info
	/// - Parameters:
	///   - title: Title if needed
	///   - image: Image if needed
	///   - mark: Any value to mark the button if needed
	///   - handler: Handler on touchUpInside with index of the button. The index would be -1 or .max for leading or trailing of Side.
	public init(title: String? = nil, image: UIImage? = nil,
				mark: Any? = nil, handler: ((Int)->Void)? = nil) {
		self.title = title
		self.image = image
		self.mark = mark
		self.handler = handler
	}
	
	func apply(_ button: UIButton) {
		button.setTitle(title, for: .normal)
		button.setImage(image, for: .normal)
		style.apply(to: button, with: button.traitCollection)
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
	
	public var buttonStack = Style()
		.stackDistribution(.equalSpacing)
}

public final class ScrollableTabBarView: UIView {
	
	private struct Model: Hashable {
		static func == (lhs: ScrollableTabBarView.Model, rhs: ScrollableTabBarView.Model) -> Bool {
			lhs.button === rhs.button
		}
		
		let button: UIButton
		let originalSize: CGSize
		var info: ScrollableTabBarButton
		
		func hash(into hasher: inout Hasher) {
			hasher.combine(button)
		}
	}
	
	public weak var delegate: ScrollableTabBarViewDelegate?
	
	public private(set) var selectedIndex = -1
	public private(set) var indicatorIndexPosition: CGFloat = -1
	
	public var style: ScrollableTabBarStyleSet = .shared
	
	private var sideButtons: [ScrollableTabBarButton.Side: Model] = [:]
	private let contentView = UIScrollView()
	private let buttonStack = UIStackView(frame: .zero)
	private var axisContraints: [NSLayoutConstraint] = []
	private let selectIndicator = UIView()
	private var models: [Model] = []
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		if #available(iOS 11.0, *) {
			contentView.contentInsetAdjustmentBehavior = .never
		}
		contentView.showsHorizontalScrollIndicator = false
		contentView.showsVerticalScrollIndicator = false
		addSubview(contentView)
		
		selectIndicator.isUserInteractionEnabled = false
		buttonStack.translatesAutoresizingMaskIntoConstraints = false
		
		contentView.addSubview(buttonStack)
		contentView.addSubview(selectIndicator)
		
		contentView.spot.constraints(buttonStack)
		updateAxis()
	}
	
	required public init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public var axis: NSLayoutConstraint.Axis = .horizontal {
		didSet {
			guard axis != oldValue else {return}
			updateAxis()
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
		var frame = bounds
		if !sideButtons.isEmpty {
			var inset: UIEdgeInsets = .zero
			for (side, model) in sideButtons {
				switch side {
				case .leading:
					if isHorizontal {
						inset.left = model.button.bounds.width
						model.button.bounds.size.height = size.height
					} else {
						inset.top = model.button.bounds.height
						model.button.bounds.size.width = size.width
					}
					model.button.center = .zero
				case .trailing:
					if isHorizontal {
						inset.right = model.button.bounds.width
						model.button.bounds.size.height = size.height
					} else {
						inset.bottom = model.button.bounds.height
						model.button.bounds.size.width = size.width
					}
					model.button.center = .init(x: size.width, y: size.height)
				}
			}
			frame = frame.inset(by: inset)
		}
		contentView.frame = frame
		
		let indicatorH_2 = style.selectIndicatorSize * 0.5
		if isHorizontal {
			selectIndicator.center.y = style.selectIndicatorPosition == .leading ? indicatorH_2 : size.height - indicatorH_2
		} else {
			selectIndicator.center.x = style.selectIndicatorPosition == .leading ? indicatorH_2 : size.width - indicatorH_2
		}
		updateSelectIndicator(from: indicatorIndexPosition, highlightButton: true, animated: false)
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
			button.layer.anchorPoint = side == .leading ? .zero : .init(x: 1, y: 1)
			button.tag = side.rawValue
			button.addTarget(self, action: #selector(touchUp(side:)), for: .touchUpInside)
			sideButtons[side] = .init(button: button, originalSize: .zero, info: info)
			addSubview(button)
		}
		info.apply(button)
		button.sizeToFit()
	}
	
	public func button(at index: Int) -> ScrollableTabBarButton? {
		models.spot_value(at: index)?.info
	}
	
	public func add(button info: ScrollableTabBarButton) {
		let button = UIButton(type: .custom)
		info.apply(button)
		button.addTarget(self, action: #selector(touchUp(item:)), for: .touchUpInside)
		button.tag = models.count
		models.append(Model(button: button, originalSize: button.bounds.size, info: info))
		buttonStack.addArrangedSubview(button)
		selectIndicator.isHidden = models.count <= 1
	}
	
	public func set(selectedIndex: CGFloat, highlightButton: Bool, animated: Bool) {
		guard models.indices.contains(Int(ceil(selectedIndex))) else {return}
		let oldValue = self.indicatorIndexPosition
		self.indicatorIndexPosition = selectedIndex
		updateSelectIndicator(from: oldValue, highlightButton: highlightButton, animated: animated && oldValue >= 0)
	}
	
	func resetStyle() {
		style.view.apply(to: self, with: traitCollection)
		style.selectIndicator.apply(to: selectIndicator, with: traitCollection)
		if axis == .horizontal {
			selectIndicator.bounds.size.height = style.selectIndicatorSize
		} else {
			selectIndicator.bounds.size.width = style.selectIndicatorSize
		}
		sideButtons.values.forEach{
			$0.info.style.apply(to: $0.button, with: traitCollection)}
		style.buttonStack.apply(to: buttonStack, with: traitCollection)
		let range = Int(indicatorIndexPosition)...Int(ceil(indicatorIndexPosition))
		models.enumerated().forEach{ (i, model) in
			(range.contains(i) ? model.info.selectedStyle : model.info.style)
				.apply(to: model.button, with: traitCollection)}
	}
	
	private func updateAxis() {
		buttonStack.axis = axis
		removeConstraints(axisContraints)
		let isHorizontal = axis == .horizontal
		axisContraints = [
			isHorizontal
				? heightAnchor.constraint(equalTo: buttonStack.heightAnchor)
				: widthAnchor.constraint(equalTo: buttonStack.widthAnchor),
			isHorizontal
				? contentView.heightAnchor.constraint(equalTo: buttonStack.heightAnchor)
				: contentView.widthAnchor.constraint(equalTo: buttonStack.widthAnchor),
		]
		axisContraints.spot_set(active: true)
	}
	
	private func updateSelectIndicator(from oldIndex: CGFloat, highlightButton: Bool, animated: Bool) {
		guard models.indices.contains(Int(indicatorIndexPosition)) else {
			return
		}
		layoutIfNeeded()
		selectIndicator.layer.removeAllAnimations()
		let indicator = selectIndicator
		let container = contentView
		
		let indexRange = Int(indicatorIndexPosition)...Int(ceil(indicatorIndexPosition))
		let progress = indicatorIndexPosition - CGFloat(indexRange.lowerBound)
		let indicatorSize = style.selectIndicatorSize
		
		let model1 = models[indexRange.lowerBound]
		let model2 = models[indexRange.upperBound]
		let btnFrame1 = model1.button.frame
		let btnFrame2 = model2.button.frame
		let containerSize = container.bounds.size
		let fn = {
			if highlightButton {
				if let oldModel = self.models.spot_value(at: self.selectedIndex) {
					oldModel.info.style.apply(to: oldModel.button, with: self.traitCollection)
				}
				model1.info.selectedStyle.apply(to: model1.button, with: self.traitCollection)
				self.selectedIndex = indexRange.lowerBound
			}
			if self.axis == .horizontal {
				let x = btnFrame1.minX + (btnFrame2.minX - btnFrame1.minX) * progress
				let width = btnFrame1.width + (btnFrame2.width - btnFrame1.width) * progress
				let indicatorFrame = CGRect(x: x, y: btnFrame1.maxY - indicatorSize, width: width, height: indicatorSize)
				indicator.frame = indicatorFrame
				if containerSize.width > 0 {
					var offset = container.contentOffset
					if indicatorFrame.minX < offset.x {
						offset.x = max(indicatorFrame.minX, 0)
					} else if indicatorFrame.maxX > offset.x + containerSize.width {
						offset.x = min(indicatorFrame.minX, container.contentSize.width - containerSize.width)
					}
					container.setContentOffset(offset, animated: false)
				}
			} else {
				let y = btnFrame1.minY + (btnFrame2.minY - btnFrame1.minY) * progress
				let height = btnFrame1.height + (btnFrame2.height - btnFrame1.height) * progress
				let indicatorFrame = CGRect(x: btnFrame1.maxX - indicatorSize, y: y, width: indicatorSize, height: height)
				indicator.frame = indicatorFrame
				if containerSize.height > 0 {
					var offset = container.contentOffset
					if indicatorFrame.minY < offset.y {
						offset.y = max(indicatorFrame.minY, 0)
					} else if indicatorFrame.maxY > offset.y + containerSize.height {
						offset.y = min(indicatorFrame.minY, container.contentSize.height - containerSize.height)
					}
					container.setContentOffset(offset, animated: false)
				}
			}
		}
		if animated {
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
