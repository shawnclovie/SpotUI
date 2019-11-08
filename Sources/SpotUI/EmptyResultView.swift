//
//  EmptyResultView.swift
//  SpotUI
//
//  Created by Shawn Clovie on 26/10/2017.
//  Copyright © 2017 Shawn Clovie. All rights reserved.
//

import UIKit
import Spot

public struct EmptyResultViewStyleSet {
	public static var shared = EmptyResultViewStyleSet()
	
	public var view = Style()
		.backgroundColor(StyleShared.popupPanelBackgroundColorProducer)
		.shadow{_ in .init(color: .init(white: 0, alpha: 0.25), offset: .zero, opacity: 1, radius: 6)}
		.cornerRadius{_ in 10}
	public var spacing: CGFloat = 16
	public var titleView = Style()
		.backgroundColor(StyleShared.clearColorProducer)
		.textColor{_ in .systemGray}
		.font{_ in .systemFont(ofSize: 20)}
		.textAlignment(.center)
		.padding{_ in .init(top: 8, left: 20, bottom: 0, right: 20)}
	public var descriptionView = Style()
		.backgroundColor(StyleShared.clearColorProducer)
		.textColor{_ in .systemGray}
		.font{_ in .systemFont(ofSize: 14)}
		.textAlignment(.center)
		.padding{_ in .init(top: 0, left: 20, bottom: 0, right: 20)}
	public var imageView = Style()
	public var button = Style()
		.font{_ in .systemFont(ofSize: 16)}
		.padding{_ in .init(top: 8, left: 10, bottom: 16, right: 10)}
		.buttonTitleColor{ (state, trait) in
			switch state {
			case .disabled:	return StyleShared.secondForegroundTextColor
			default:		return StyleShared.tintColorProducer(trait)
			}
	}
}

open class EmptyResultView: UIView {
	
	public var onButtonTapped: ((EmptyResultView)->Void)?

	private let contentView = UIView()
	public let contentStack = UIStackView()
	public let imageView = UIImageView()
	public let titleView = UITextView()
	public let descriptionView = UITextView()
	public let button = UIButton()
	public var emptyResultViewStyle = EmptyResultViewStyleSet.shared
	
	public required override init(frame: CGRect) {
		super.init(frame: frame)
		addSubview(contentView)
		titleView.spot.disableInteraction()
		descriptionView.spot.disableInteraction()
		button.addTarget(self, action: #selector(touchUp(button:)), for: .touchUpInside)
		contentStack.axis = .vertical
		contentStack.alignment = .center
		contentStack.distribution = .equalSpacing
		contentStack.spacing = emptyResultViewStyle.spacing
		[imageView, titleView, descriptionView, button].forEach(contentStack.addArrangedSubview(_:))
		contentView.addSubview(contentStack)
		
		contentView.spot.constraints(contentStack)
		[
			contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
			contentView.centerYAnchor.constraint(equalTo: centerYAnchor),
			contentView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor),
			].spot_set(active: true)
	}
	
	required convenience public init?(coder: NSCoder) {
		self.init(frame: .zero)
	}
	
	open override func didMoveToWindow() {
		super.didMoveToWindow()
		resetStyle()
	}
	
	open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		resetStyle()
	}
	
	open func resetStyle() {
		emptyResultViewStyle.view.apply(to: contentView, with: traitCollection)
		emptyResultViewStyle.titleView.apply(to: titleView, with: traitCollection)
		emptyResultViewStyle.descriptionView.apply(to: descriptionView, with: traitCollection)
		emptyResultViewStyle.imageView.apply(to: imageView, with: traitCollection)
		emptyResultViewStyle.button.apply(to: button, with: traitCollection)
	}
	
	open func set(title: String, image: UIImage? = nil, description: String? = nil, buttonTitle: String? = nil) {
		titleView.text = title
		imageView.image = image
		descriptionView.text = description
		button.setTitle(buttonTitle, for: .normal)
	}
	
	@objc private func touchUp(button: Any) {
		onButtonTapped?(self)
	}
}
