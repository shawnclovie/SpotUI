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
	public var handler: (()->Void)?
	
	public init(title: String? = nil, image: UIImage? = nil, style: Style? = nil, mark: Any? = nil, handler: (()->Void)? = nil) {
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
	
	public var selectIndicatorHeight: CGFloat = 4
	public var selectIndicator = Style()
		.backgroundColor(StyleShared.tintColorProducer)
	
	public var button = Style()
		.textColor(StyleShared.foregroundTextColorProducer)
		.font{_ in .systemFont(ofSize: 18)}
		.padding{_ in .init(top: 6, left: 10, bottom: 6, right: 10)}
	
	public var sideButton = Style()
		.textColor(StyleShared.foregroundTextColorProducer)
		.padding{_ in .init(top: 8, left: 8, bottom: 8, right: 8)}
}

public final class ScrollableTabBarView: UIView {
	
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
	
	/// Alignment for buttons, affect on total area size > buttons size only.
	public var alignment: ScrollableTabBarButton.Alignment = .leading
	
	private var sideButtons: [ScrollableTabBarButton.Side: Model] = [:]
	private let contentView = UIScrollView()
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
		selectIndicator.layer.anchorPoint = CGPoint(x: 0, y: 1)
		contentView.addSubview(selectIndicator)
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public var style: ScrollableTabBarStyleSet = .shared
	
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
		let h_2 = size.height / 2
		var widthBL: CGFloat = 0
		var widthBR: CGFloat = 0
		if let button = sideButtons[.leading]?.button {
			widthBL = button.bounds.width
			button.center = CGPoint(x: 0, y: h_2)
			button.bounds.size.height = size.height
		}
		if let button = sideButtons[.trailing]?.button {
			widthBR = button.bounds.width
			button.center = CGPoint(x: size.width - widthBR, y: h_2)
			button.bounds.size.height = size.height
		}
		// width of contentView area
		let widthCA = size.width - widthBL - widthBR
		// width of total buttons
		let widthCBs: CGFloat = models.reduce(0, {$0 + $1.originalSize.width})
		var buttonX: CGFloat = 0
		var buttonSizes = models.map {$0.originalSize}
		switch alignment {
		case .justified:
			if widthCA > widthCBs {
				let scale = widthCA / widthCBs
				buttonSizes = buttonSizes.map {$0 * scale}
			}
		case .leading:		break
		case .center:	buttonX = max(0, (widthCA - widthCBs) / 2)
		case .trailing:	buttonX = max(0, widthCA - widthCBs)
		}
		for (index, model) in models.enumerated() {
			let size = buttonSizes[index]
			model.button.center = CGPoint(x: buttonX, y: h_2)
			model.button.bounds.size.width = size.width
			buttonX += size.width
		}
		contentView.contentSize = CGSize(width: buttonX, height: size.height)
		contentView.frame = CGRect(x: widthBL, y: 0, width: widthCA, height: size.height)
		selectIndicator.center.y = size.height
		updateSelectIndicator(from: selectedIndex, animated: false)
	}
	
	public override var intrinsicContentSize: CGSize {
		let width = bounds.width
		return .init(width: width > 0 ? width : UIScreen.main.bounds.size.width,
					 height: models.reduce(0, {max($0, $1.originalSize.height)}))
	}
	
	public func setSideButton(of side: ScrollableTabBarButton.Side, _ info: ScrollableTabBarButton) {
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
			button.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
			addSubview(button)
			sideButtons[side] = .init(button: button, originalSize: .zero, info: info)
		}
		button.setTitle(info.title, for: .normal)
		button.setImage(info.image, for: .normal)
		info.style?.apply(to: button, with: traitCollection)
		button.sizeToFit()
	}
	
	public func buttonTitle(at index: Int) -> String? {
		models.spot_value(at: index)?.button.title(for: .normal)
	}
	
	public func addButton(_ info: ScrollableTabBarButton) {
		let button = UIButton(type: .custom)
		info.title.map{button.setTitle($0, for: .normal)}
		info.image.map{button.setImage($0, for: .normal)}
		self.style.button.apply(to: button, with: traitCollection)
		info.style?.apply(to: button, with: traitCollection)
		button.addTarget(self, action: #selector(touchUp(item:)), for: .touchUpInside)
		button.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
		button.sizeToFit()
		button.center = .zero
		button.tag = models.count
		models.append(Model(button: button, originalSize: button.bounds.size, info: info))
		contentView.addSubview(button)
		selectIndicator.isHidden = models.count <= 1
	}
	
	private func resetStyle() {
		style.view.apply(to: self, with: traitCollection)
		style.selectIndicator.apply(to: selectIndicator, with: traitCollection)
		selectIndicator.bounds.size.height = style.selectIndicatorHeight
		sideButtons.forEach{
			style.sideButton.apply(to: $0.value.button, with: traitCollection)}
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
		let fn = {
			let btnWidth = button.bounds.width
			let btnX = button.center.x
			indicator.center.x = btnX
			indicator.bounds.size.width = btnWidth
			let containerWidth = container.bounds.width
			if containerWidth > 0 {
				var offset = container.contentOffset
				if btnX < offset.x {
					offset.x = max(btnX - (containerWidth - btnWidth) / 2, 0)
				} else if btnX + btnWidth > offset.x + containerWidth {
					offset.x = min(btnX - (containerWidth - btnWidth) / 2, container.contentSize.width - containerWidth)
				}
				container.setContentOffset(offset, animated: false)
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
		sideButtons[side]?.info.handler?()
		delegate?.scrollableTabBar(view: self, didTouch: side)
	}
	
	@objc private func touchUp(item: UIButton) {
		guard let model = models.spot_value(at: item.tag) else {
			return
		}
		model.info.handler?()
		delegate?.scrollableTabBar(view: self, didSelect: item.tag, info: model.info)
	}
}
