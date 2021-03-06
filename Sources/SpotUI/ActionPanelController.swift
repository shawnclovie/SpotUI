//
//  ActionPanelController.swift
//  SpotUI
//
//  Created by Shawn Clovie on 14/10/2017.
//  Copyright © 2017 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import Spot

public struct ActionPanelStyleSet {
	public static var shared = ActionPanelStyleSet()
	
	public var view = Style()
		.backgroundColor{_ in StyleShared.maskBackgroundColor}
	
	public var panelPadding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
	
	public var panelView = Style()
		.backgroundColor(StyleShared.popupPanelBackgroundColorProducer)
		.cornerRadius{_ in 10}
		.maskToBounds(true)
		.padding{_ in .init(top: 10, left: 10, bottom: 10, right: 10)}
	
	public var titleView = Style()
		.textColor(StyleShared.foregroundTextColorProducer)
		.textAlignment(.center)
		.font{_ in .systemFont(ofSize: 20, weight: .bold)}
		.padding{_ in .init(top: 16, left: 16, bottom: 16, right: 16)}
		.backgroundColor(StyleShared.clearColorProducer)
	
	public var cancelButton = Style()
		.textColor{_ in StyleShared.secondForegroundTextColor}
		.padding{_ in .init(top: 12, left: 12, bottom: 12, right: 12)}
		.cornerRadius{_ in 10}
		.maskToBounds(true)
		.backgroundImage{[.normal: .solidColor(StyleShared.popupPanelBackgroundColorProducer($0))]}
}

/// ViewController to simulate ActionPanel
/// - StyleSheet
///   - view: action_panel_view_controller
///   - panel: action_panel_view_controller.panel
///   - title: action_panel_view_controller.title_view
///   - cancel: action_panel_view_controller.cancel_button
open class ActionPanelController: UIViewController {
	
	public let panel = UIView()
	public let titleView = UITextView()
	public let contentView = UIView()
	public let cancelButton = UIButton(type: .system)
	
	public var actionPanelStyle = ActionPanelStyleSet.shared
	
	public var touchUpPanelOutsideHandler: ((ActionPanelController)->Void)?
	public var touchUpCancelHandler: ((ActionPanelController)->Void)?
	
	override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		modalPresentationStyle = .overCurrentContext
		modalTransitionStyle = .crossDissolve
	}
	
	required public convenience init?(coder aDecoder: NSCoder) {
		self.init(nibName: nil, bundle: nil)
	}
	
	override open var title: String? {
		get {titleView.text}
		set {titleView.text = newValue}
	}
	
	override open func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(panel)
		
		titleView.spot.disableInteraction()
		panel.insertSubview(titleView, at: 0)
		panel.addSubview(contentView)
		
		cancelButton.setTitle("cancel".spot.localize(), for: .normal)
		cancelButton.addTarget(self, action: #selector(touchUp(cancel:)), for: .touchUpInside)
		view.addSubview(cancelButton)
		
		let padding = actionPanelStyle.panelPadding
		panel.spot.constraints(contentView, attributes: [.left, .right, .bottom])
		[
			panel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			panel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -(padding.left + padding.right)),
			titleView.topAnchor.constraint(equalTo: panel.topAnchor, constant: padding.top),
			titleView.leftAnchor.constraint(equalTo: panel.leftAnchor),
			titleView.rightAnchor.constraint(equalTo: panel.rightAnchor),
			contentView.topAnchor.constraint(equalTo: titleView.bottomAnchor),
			cancelButton.topAnchor.constraint(equalTo: panel.bottomAnchor, constant: padding.bottom),
			cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			cancelButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -(padding.left + padding.right)),
			cancelButton.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: -padding.bottom),
		].spot_set(active: true)
	}
	
	open override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		resetStyle()
	}
	
	open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		resetStyle()
	}
	
	open func resetStyle() {
		actionPanelStyle.view.apply(to: view, with: traitCollection)
		actionPanelStyle.panelView.apply(to: panel, with: traitCollection)
		actionPanelStyle.titleView.apply(to: titleView, with: traitCollection)
		actionPanelStyle.cancelButton.apply(to: cancelButton, with: traitCollection)
	}
	
	override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		guard presentedViewController == nil,
			let touch = touches.first else {
				return
		}
		if panel.hitTest(touch.location(in: panel), with: nil) == nil {
			touchUpPanelOutsideHandler?(self)
		}
	}
	
	@objc open func touchUp(cancel: UIButton) {
		touchUpCancelHandler?(self)
	}
}
#endif
