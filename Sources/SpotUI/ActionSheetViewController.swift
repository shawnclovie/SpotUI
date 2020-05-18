//
//  ActionSheetViewController.swift
//  SpotUI
//
//  Created by Shawn Clovie on 27/09/2016.
//  Copyright © 2016 Shawn Clovie. All rights reserved.
//

import UIKit
import Spot

public struct ActionSheetStyleSet {
	public static var shared = ActionSheetStyleSet()
	
	public var view = Style()
		.backgroundColor{_ in StyleShared.maskBackgroundColor}
	
	public var panelHeight: CGFloat = 300
	public var panelView = Style()
		.backgroundColor(StyleShared.popupPanelBackgroundColorProducer)
		.shadow{_ in .init(color: .black, offset: .init(width: 0, height: -2), opacity: 0.5, radius: 4)}
	
	public var contentViewPadding: CGFloat = 10
	
	public var titleView = Style()
		.backgroundColor(StyleShared.clearColorProducer)
		.textColor(StyleShared.foregroundTextColorProducer)
		.font{_ in .systemFont(ofSize: 20)}
		.textAlignment(.center)
		.padding{_ in .init(top: 12, left: 12, bottom: 12, right: 12)}
	
	public var buttonHeight: CGFloat = 40
	public var buttonSpacing: CGFloat = 10
	public var button = Style()
		.font{_ in .systemFont(ofSize: 12)}
		.padding{_ in .init(top: 10, left: 10, bottom: 10, right: 10)}
	
	public var statefulButtons: [UIAlertAction.Style: Style] = [
		.cancel: Style().backgroundImage{_ in [.normal: .solidColor(DecimalColor(rgb: 0xc2c2c2).colorValue)]},
		.default: Style().backgroundImage{[.normal: .solidColor(StyleShared.tintColorProducer($0))]},
		.destructive: Style().backgroundImage{_ in [.normal: .solidColor(StyleShared.destructiveTintColor)]},
	]
}

open class ActionSheetViewController: UIViewController {
	
	public let panel = UIView()
	public let titleView = UITextView()
	public let contentView = UIView()
	
	public var actionSheetStyle = ActionSheetStyleSet.shared
	
	private var contentViewLeftConstraint: NSLayoutConstraint?
	private var contentViewRightConstraint: NSLayoutConstraint?
	private var contentViewBottomConstraint: NSLayoutConstraint?
	private var panelHeightConstraint: NSLayoutConstraint?
	private let buttonWrapper = UIView()
	private var buttonWrapperHeightConstraint: NSLayoutConstraint?
	private var buttonWrapperBottomConstraint: NSLayoutConstraint?

	public let touchUpOnEdgeEvent = EventObservable<ActionSheetViewController>()
	
	override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		modalPresentationStyle = .overCurrentContext
		modalTransitionStyle = .crossDissolve
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override open func viewDidLoad() {
		super.viewDidLoad()
		
		view.addSubview(panel)
		titleView.spot.disableInteraction()
		
		for sub in [titleView, buttonWrapper, contentView] as [UIView] {
			panel.addSubview(sub)
		}
		
		panelHeightConstraint = panel.heightAnchor.constraint(equalToConstant: 0).spot.setActived()
		contentViewLeftConstraint = contentView.leftAnchor.constraint(equalTo: panel.leftAnchor).spot.setActived()
		contentViewRightConstraint = contentView.rightAnchor.constraint(equalTo: panel.rightAnchor).spot.setActived()
		contentViewBottomConstraint = buttonWrapper.topAnchor.constraint(equalTo: contentView.bottomAnchor).spot.setActived()
		buttonWrapperBottomConstraint = buttonWrapper.bottomAnchor.constraint(equalTo: panel.bottomAnchor).spot.setActived()
		buttonWrapperHeightConstraint = buttonWrapper.heightAnchor.constraint(equalToConstant: 0).spot.setActived()
		[
			panel.leftAnchor.constraint(equalTo: view.leftAnchor),
			panel.rightAnchor.constraint(equalTo: view.rightAnchor),
			panel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			titleView.topAnchor.constraint(equalTo: panel.topAnchor),
			titleView.leftAnchor.constraint(equalTo: panel.leftAnchor),
			titleView.rightAnchor.constraint(equalTo: panel.rightAnchor),
			contentView.topAnchor.constraint(equalTo: titleView.bottomAnchor),
			buttonWrapper.leftAnchor.constraint(equalTo: panel.leftAnchor),
			buttonWrapper.rightAnchor.constraint(equalTo: panel.rightAnchor),
			].spot_set(active: true)
	}
	
	override open func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		if !buttonWrapper.subviews.isEmpty {
			let wrapperSize = buttonWrapper.bounds.size
			var buttonPos = CGPoint(x: 0, y: wrapperSize.height * 0.5)
			for sub in buttonWrapper.subviews {
				sub.center = buttonPos
				buttonPos.x += actionSheetStyle.buttonSpacing + sub.bounds.width
			}
			buttonWrapper.transform = .init(translationX: (wrapperSize.width - buttonPos.x) * 0.5, y: 0)
		}
	}
	
	override open func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		resetStyle()
		if animated {
			panel.transform = .init(translationX: 0, y: panel.bounds.height)
			UIView.animate(withDuration: 0.3, animations: {
				self.panel.transform = .identity
			})
		}
	}
	
	open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		resetStyle()
	}
	
	public func add(button: UIButton, style: UIAlertAction.Style) {
		setStyle(style, to: button)
		button.tag = style.rawValue
		button.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
		button.sizeToFit()
		buttonWrapper.addSubview(button)
	}
	
	override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		guard let touch = touches.first else {return}
		if panel.hitTest(touch.location(in: panel), with: nil) == nil {
			touchUpOnEdgeEvent.dispatch(self)
		}
	}
	
	open func resetStyle() {
		panelHeightConstraint?.constant = max(actionSheetStyle.panelHeight, actionSheetStyle.contentViewPadding * 2 + actionSheetStyle.buttonHeight)
		contentViewLeftConstraint?.constant = actionSheetStyle.contentViewPadding
		contentViewRightConstraint?.constant = -actionSheetStyle.contentViewPadding
		contentViewBottomConstraint?.constant = actionSheetStyle.contentViewPadding
		buttonWrapperBottomConstraint?.constant = -actionSheetStyle.contentViewPadding
		buttonWrapperHeightConstraint?.constant = actionSheetStyle.buttonHeight
		
		actionSheetStyle.view.apply(to: view, with: traitCollection)
		actionSheetStyle.panelView.apply(to: panel, with: traitCollection)
		actionSheetStyle.titleView.apply(to: titleView, with: traitCollection)
		for it in buttonWrapper.subviews {
			setStyle(UIAlertAction.Style(rawValue: it.tag) ?? .default, to: it)
		}
	}
	
	open func setStyle(_ style: UIAlertAction.Style, to: UIView) {
		ActionSheetStyleSet.shared.button.apply(to: to, with: traitCollection)
		ActionSheetStyleSet.shared.statefulButtons[style]?.apply(to: to, with: traitCollection)
	}
}
