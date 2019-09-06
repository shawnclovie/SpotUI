//
//  AlertController.swift
//  SpotUI
//
//  Created by Shawn Clovie on 25/10/2017.
//  Copyright © 2017 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import Spot

public struct AlertStyleSet {
	public static var shared = AlertStyleSet()
	
	public let view = Style()
		.backgroundColor{_ in StyleShared.maskBackgroundColor}
	
	public let titleView = Style()
		.backgroundColor(StyleShared.clearColorProducer)
		.padding {_ in .init(top: 20, left: 10, bottom: 20, right: 10)}
		.textAlignment(.center)
	
	public let panelView = Style()
		.backgroundColor(StyleShared.popupPanelBackgroundColorProducer)
		.cornerRadius {$0.userInterfaceIdiom == .pad ? 28 : 20}
		.maskToBounds(true)
	
	public let contentView = Style()
		.backgroundColor(StyleShared.clearColorProducer)
	
	public let titleText = Style()
		.font {_ in .systemFont(ofSize: 20, weight: .bold)}
		.textColor(StyleShared.foregroundTextColorProducer)
	
	public let messageText = Style()
		.font {_ in .systemFont(ofSize: 14)}
		.textColor(StyleShared.foregroundTextColorProducer)
		.padding {_ in .init(top: 0, left: 8, bottom: 0, right: 8)}
	
	public var buttonHeight: CGFloat = 44
	
	public let button = Style()
		.padding {_ in .init(top: 4, left: 10, bottom: 4, right: 10)}
		.lineBreakMode(.byWordWrapping)
	
	public let buttonFontDefault = Style()
		.buttonTitleColor(StyleShared.statefulTintColorProducer)
		.font {.systemFont(ofSize: $0.userInterfaceIdiom == .pad ? 24 : 18)}
	
	public var buttonForStyles: [UIAlertAction.Style: Style] = [
		.cancel: Style()
			.buttonTitleColor(StyleShared.statefulTintColorProducer)
			.font{.systemFont(ofSize: $0.userInterfaceIdiom == .pad ? 22 : 18, weight: .medium)},
		.destructive: Style()
			.buttonTitleColor {_, _  in StyleShared.destructiveTintColor}
			.font{.systemFont(ofSize: $0.userInterfaceIdiom == .pad ? 22 : 18, weight: .medium)},
	]
}

open class AlertController: UIViewController {
	
	public struct Action {
		public var title: String?
		public var image: UIImage?
		public var style: UIAlertAction.Style
		public var mark: Any?
		public var handler: ((Action)->Void)?
		
		public init(title: String?, image: UIImage? = nil, style: UIAlertAction.Style, mark: Any? = nil, handler: ((Action)->Void)?) {
			self.title = title
			self.image = image
			self.style = style
			self.mark = mark
			self.handler = handler
		}
	}
	
	public let contentView = UIView()
	public let panelView = UIView()
	public let titleView = UITextView()
	public var titleViewTexts: (title: String, message: String?) = ("", nil)
	public var shouldDismissOnActionTouchUp = true
	
	private var titleViewHeightConstraint: NSLayoutConstraint?
	private let buttonsView = UIView()
	private var buttonsViewHeightConstraint: NSLayoutConstraint?
	private var actions: [UIButton: Action] = [:]
	
	convenience public init(title: String, message: String?, actions: [Action] = []) {
		self.init(nibName: nil, bundle: nil)
		titleViewTexts = (title, message)
		actions.forEach(addAction(_:))
	}
	
	override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		modalPresentationStyle = .overCurrentContext
		modalTransitionStyle = .crossDissolve
	}
	
	required convenience public init?(coder aDecoder: NSCoder) {
		self.init(nibName: nil, bundle: nil)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	override open func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(panelView)
		titleView.spot.disableInteraction()
		panelView.addSubview(titleView)
		panelView.addSubview(contentView)
		panelView.addSubview(buttonsView)
		
		let screenSize = UIScreen.main.bounds.size
		
		titleViewHeightConstraint = titleView.heightAnchor.constraint(equalToConstant: 0).spot.setActived()
		[
			panelView.widthAnchor.constraint(equalToConstant: (UIDevice.current.userInterfaceIdiom == .pad ? 0.5 : 0.8) * min(screenSize.width, screenSize.height)),
			panelView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			panelView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			titleView.topAnchor.constraint(equalTo: panelView.topAnchor),
			titleView.leftAnchor.constraint(equalTo: panelView.leftAnchor),
			titleView.rightAnchor.constraint(equalTo: panelView.rightAnchor),
			contentView.topAnchor.constraint(equalTo: titleView.bottomAnchor),
			contentView.leftAnchor.constraint(equalTo: panelView.leftAnchor),
			contentView.rightAnchor.constraint(equalTo: panelView.rightAnchor),
			buttonsView.topAnchor.constraint(equalTo: contentView.bottomAnchor),
			buttonsView.leftAnchor.constraint(equalTo: panelView.leftAnchor),
			buttonsView.rightAnchor.constraint(equalTo: panelView.rightAnchor),
			buttonsView.bottomAnchor.constraint(equalTo: panelView.bottomAnchor),
			].spot_set(active: true)
		buttonsViewHeightConstraint = buttonsView.heightAnchor.constraint(equalToConstant: AlertStyleSet.shared.buttonHeight).spot.setActived()
		
		panelView.spot.addHorizontalLine(with: buttonsView, .top)
		
		let center = NotificationCenter.default
		center.addObserver(self, selector: #selector(notify(keyboardFrameChanged:)),
						   name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
		center.addObserver(self, selector: #selector(notify(keyboardHide:)),
						   name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	open override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		resetStyle()
	}
	
	open func resetStyle() {
		let style = AlertStyleSet.shared
		style.view.apply(to: view, with: traitCollection)
		style.panelView.apply(to: panelView, with: traitCollection)
		style.titleView.apply(to: titleView, with: traitCollection)
		let empty = titleViewTexts.title.isEmpty && (titleViewTexts.message?.isEmpty ?? true)
		titleViewHeightConstraint?.isActive = empty
		if empty {
			titleView.attributedText = nil
		} else {
			let attrText = NSMutableAttributedString(string: titleViewTexts.title, attributes: style.titleText.stringAttributes(with: traitCollection))
			if let value = titleViewTexts.message {
				attrText.append(.init(string: "\n"))
				attrText.append(.init(string: value, attributes: style.messageText.stringAttributes(with: traitCollection)))
			}
			let paraStyle = NSMutableParagraphStyle()
			paraStyle.alignment = style.titleView.getTextAlignment(default: .center)
			attrText.addAttributes([.paragraphStyle: paraStyle], range: .init(location: 0, length: attrText.length))
			titleView.attributedText = attrText
		}
		for (button, action) in actions {
			setStyle(for: action, to: button)
		}
	}
	
	private func setStyle(for action: Action, to: UIButton) {
		let style = AlertStyleSet.shared
		[
			style.button,
			style.buttonForStyles[action.style] ?? style.buttonFontDefault,
			].forEach{$0.apply(to: to, with: traitCollection)}
	}
	
	open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		resetStyle()
	}
	
	override open func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		if !buttonsView.subviews.isEmpty {
			let horizontalButtonCount = 2
			let containerWidth = panelView.bounds.width
			let subs: [UIView] = buttonsView.subviews.sorted(by: {$0.tag > $1.tag})
			var horizontal = true
			if subs.count == horizontalButtonCount {
				var contentsWidth: CGFloat = 0
				for sub in subs {
					sub.sizeToFit()
					contentsWidth += sub.bounds.width
					if contentsWidth > containerWidth {
						horizontal = false
						break
					}
				}
			} else {
				horizontal = false
			}
			let buttonHeight = AlertStyleSet.shared.buttonHeight
			if horizontal {
				var frame = CGRect(x: 0, y: 0, width: containerWidth / CGFloat(horizontalButtonCount), height: buttonHeight)
				for sub in subs {
					sub.frame = frame
					frame.origin.x += frame.width
				}
				buttonsViewHeightConstraint?.constant = buttonHeight
			} else {
				var frame = CGRect(x: 0, y: 0, width: containerWidth, height: buttonHeight)
				for sub in subs {
					sub.frame = frame
					frame.origin.y += frame.height
				}
				buttonsViewHeightConstraint?.constant = frame.origin.y
			}
		}
	}
	
	open override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		actions.removeAll()
	}
	
	public func set(title: String, message: String? = nil) {
		titleViewTexts = (title, message)
		view.setNeedsLayout()
	}
	
	open func shouldAutoDismiss(for action: Action) -> Bool {
		shouldDismissOnActionTouchUp
	}
	
	public func addAction(_ action: Action) {
		let button = UIButton(type: .system)
		button.setTitle(action.title, for: .normal)
		button.setImage(action.image, for: .normal)
		button.addTarget(self, action: #selector(touchUp(button:)), for: .touchUpInside)
		setStyle(for: action, to: button)
		button.tag = action.style.rawValue
		actions[button] = action
		buttonsView.addSubview(button)
		view.setNeedsLayout()
	}
	
	public func setActions(enabled: Bool, for style: UIAlertAction.Style) {
		for it in actions where it.value.style == style {
			it.key.isEnabled = enabled
		}
	}
	
	@objc private func touchUp(button: UIButton) {
		guard let action = actions[button] else {return}
		if shouldAutoDismiss(for: action) {
			dismiss(animated: true) {
				action.handler?(action)
			}
		} else {
			action.handler?(action)
		}
	}
	
	@objc private func notify(keyboardFrameChanged note: Notification) {
		set(panelOffsetY: -note.spot.keyboardHeight / 2)
	}
	
	@objc private func notify(keyboardHide note: Notification) {
		set(panelOffsetY: 0)
	}
	
	private func set(panelOffsetY value: CGFloat) {
		UIView.animate(withDuration: 0.3, animations: {
			self.panelView.transform.ty = value
		})
	}
}
#endif
