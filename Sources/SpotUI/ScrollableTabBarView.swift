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
	func scrollableTabBar(view: ScrollableTabBarView, didTouch side: ScrollableTabBarView.Side)
}

public struct ScrollableTabBarButton {
	public var title: String?
	public var image: UIImage?
	public var style: Style
	public var selectedStyle: Style
	public var mark: Any?
	public var handler: ((ScrollableTabBarButton, Int)->Void)?
	
	/// Make button info
	/// - Parameters:
	///   - title: Title if needed
	///   - image: Image if needed
	///   - style: Style on normal state
	///   - selectedStyle: Style on selected (highlighted) state
	///   - mark: Any value to mark the button if needed
	///   - handler: Handler on touchUpInside with index of the button. The index would be -1 or .max for leading or trailing of Side.
	public init(title: String? = nil, image: UIImage? = nil,
				style: Style = Style().textColor(StyleShared.foregroundTextColorProducer),
				selectedStyle: Style = Style().textColor(StyleShared.foregroundTextColorProducer),
				mark: Any? = nil,
				handler: ((ScrollableTabBarButton, Int)->Void)? = nil) {
		self.title = title
		self.image = image
		self.style = style
		self.selectedStyle = selectedStyle
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
		.backgroundColor{DecimalColor(rgb: $0?.spot.userInterfaceStyle == .dark ? 0x101010 : 0xfdfdfd).colorValue}
	
	/// Set leading to layout top for horizontal, left for vertical
	///
	/// Set trailing to layout bottom for horizontal, right for vertical
	public var selectIndicatorPosition: ScrollableTabBarView.Side = .trailing
	/// Set indicator height for horizontal, width for vertical.
	public var selectIndicatorSize: CGFloat = 4
	public var selectIndicator = Style()
		.backgroundColor(StyleShared.tintColorProducer)
	
	public var buttonStack = Style()
		.stackDistribution(.equalSpacing)
}

public final class ScrollableTabBarView: UIView {
	public enum Side: Int {
		case leading, trailing
	}
	
	public enum Alignment {
		case leading, center, trailing, justified
	}
	
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
	public private(set) var axis: NSLayoutConstraint.Axis
	public private(set) var alignment: Alignment

	private var sideButtons: [Side: Model] = [:]
	private let contentView = UIScrollView()
	private let buttonStack = UIStackView(frame: .zero)
	
	private var contentViewPadding: [Side: CGFloat] = [:]
	private var managedContraints: [NSLayoutConstraint] = []
	private let selectIndicator = UIView()
	private var models: [Model] = []
	
	public init(frame: CGRect,
				axis: NSLayoutConstraint.Axis = .horizontal,
				alignment: Alignment = .justified) {
		self.axis = axis
		self.alignment = alignment
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
		
		contentView.spot.constraints(buttonStack, attributes: [.top, .left])
		set(axis: axis, alignment: alignment)
	}
	
	required public init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
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
		layoutContentViews()
	}
	
	private func layoutContentViews() {
		let size = bounds.size
		let isHorizontal = axis == .horizontal
		contentView.layoutIfNeeded()
		let contentSize = buttonStack.bounds.size
		var inset: UIEdgeInsets = .zero
		if !sideButtons.isEmpty {
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
		}
		if alignment != .justified && alignment != .leading {
			if isHorizontal {
				let spacing = contentView.bounds.width - (inset.left + inset.right) - contentSize.width
				if spacing > 0 {
					switch alignment {
					case .center:	inset.left += spacing * 0.5
					case .trailing:	inset.left += spacing
					default:break
					}
				}
			} else {
				let spacing = contentView.bounds.height - (inset.top + inset.bottom) - contentSize.height
				if spacing > 0 {
					switch alignment {
					case .center:	inset.top += spacing * 0.5
					case .trailing:	inset.top += spacing
					default:break
					}
				}
			}
		}
		contentView.contentInset = inset
		contentView.contentSize = contentSize
		
		updateSelectIndicator(from: indicatorIndexPosition, highlightButton: true, animated: false)
	}
	
	public func set(axis: NSLayoutConstraint.Axis, alignment: Alignment) {
		removeConstraints(managedContraints)
		self.axis = axis
		self.alignment = alignment
		buttonStack.axis = axis
		var contentViewAttrs: [NSLayoutConstraint.Attribute]
		switch axis {
		case .horizontal:
			managedContraints = [
				heightAnchor.constraint(equalTo: buttonStack.heightAnchor),
				contentView.heightAnchor.constraint(equalTo: buttonStack.heightAnchor),
				contentView.widthAnchor.constraint(equalTo: widthAnchor),
			]
			if alignment == .justified {
				managedContraints.append(buttonStack.widthAnchor.constraint(equalTo: widthAnchor))
			}
			contentViewAttrs = [.top, .bottom]
			switch alignment {
			case .justified:contentViewAttrs.append(.left)
			case .leading:	contentViewAttrs.append(.left)
			case .center:	contentViewAttrs.append(.centerX)
			case .trailing:	contentViewAttrs.append(.right)
			}
		case .vertical:fallthrough
		@unknown default:
			managedContraints = [
				widthAnchor.constraint(equalTo: buttonStack.widthAnchor),
				contentView.widthAnchor.constraint(equalTo: buttonStack.widthAnchor),
				contentView.heightAnchor.constraint(equalTo: heightAnchor),
			]
			if alignment == .justified {
				managedContraints.append(buttonStack.heightAnchor.constraint(equalTo: heightAnchor))
			}
			contentViewAttrs = [.left, .right]
			switch alignment {
			case .justified:contentViewAttrs.append(.top)
			case .leading:	contentViewAttrs.append(.top)
			case .center:	contentViewAttrs.append(.centerY)
			case .trailing:	contentViewAttrs.append(.bottom)
			}
		}
		managedContraints.spot_set(active: true)
		managedContraints += spot.constraints(contentView, attributes: contentViewAttrs)
	}
	
	/// Replace side buttons, all exist buttons would be removed.
	public func set(sideButtons: [Side: ScrollableTabBarButton]) {
		for it in self.sideButtons {
			it.value.button.removeFromSuperview()
		}
		self.sideButtons.removeAll()
		for (side, info) in sideButtons {
			let button = UIButton(type: .custom)
			button.layer.anchorPoint = side == .leading ? .zero : .init(x: 1, y: 1)
			button.tag = side.rawValue
			button.addTarget(self, action: #selector(touchUp(side:)), for: .touchUpInside)
			self.sideButtons[side] = .init(button: button, originalSize: .zero, info: info)
			addSubview(button)
			info.apply(button)
			button.sizeToFit()
		}
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
	
	/// Replace exist buttons
	public func reset(buttons: [ScrollableTabBarButton]) {
		models.forEach{$0.button.removeFromSuperview()}
		models.removeAll()
		buttons.forEach(add(button:))
		buttonStack.layoutIfNeeded()
		layoutContentViews()
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
		let isLeading = style.selectIndicatorPosition == .leading
		let fn = {
			if highlightButton {
				if let oldModel = self.models.spot_value(at: self.selectedIndex) {
					oldModel.info.style.apply(to: oldModel.button, with: self.traitCollection)
				}
				model1.info.selectedStyle.apply(to: model1.button, with: self.traitCollection)
				self.selectedIndex = indexRange.lowerBound
			}
			let indicatorFrame: CGRect
			if self.axis == .horizontal {
				let x = btnFrame1.minX + (btnFrame2.minX - btnFrame1.minX) * progress
				let width = btnFrame1.width + (btnFrame2.width - btnFrame1.width) * progress
				indicatorFrame = CGRect(x: x, y: isLeading ? 0 : btnFrame1.maxY - indicatorSize, width: width, height: indicatorSize)
				if containerSize.width > 0 {
					var offset = container.contentOffset
					if indicatorFrame.minX < offset.x {
						offset.x = max(indicatorFrame.minX, 0)
					} else if indicatorFrame.maxX > offset.x + containerSize.width {
						offset.x = min(indicatorFrame.maxX - containerSize.width, container.contentSize.width - containerSize.width)
					}
					container.setContentOffset(offset, animated: false)
				}
			} else {
				let y = btnFrame1.minY + (btnFrame2.minY - btnFrame1.minY) * progress
				let height = btnFrame1.height + (btnFrame2.height - btnFrame1.height) * progress
				indicatorFrame = CGRect(x: isLeading ? 0 : btnFrame1.maxX - indicatorSize, y: y, width: indicatorSize, height: height)
				if containerSize.height > 0 {
					var offset = container.contentOffset
					if indicatorFrame.minY < offset.y {
						offset.y = max(indicatorFrame.minY, 0)
					} else if indicatorFrame.maxY > offset.y + containerSize.height {
						offset.y = min(indicatorFrame.maxY - containerSize.height, container.contentSize.height - containerSize.height)
					}
					container.setContentOffset(offset, animated: false)
				}
			}
			indicator.frame = indicatorFrame
		}
		if animated {
			UIView.animate(withDuration: 0.2, animations: fn)
		} else {
			fn()
		}
	}
	
	@objc private func touchUp(side button: UIButton) {
		guard let side = Side(rawValue: button.tag) else {
			return
		}
		if let button = sideButtons[side], let fn = button.info.handler {
			fn(button.info, side == .leading ? .min : .max)
		}
		delegate?.scrollableTabBar(view: self, didTouch: side)
	}
	
	@objc private func touchUp(item: UIButton) {
		guard let model = models.spot_value(at: item.tag) else {
			return
		}
		model.info.handler?(model.info, item.tag)
		delegate?.scrollableTabBar(view: self, didSelect: item.tag, info: model.info)
	}
}
