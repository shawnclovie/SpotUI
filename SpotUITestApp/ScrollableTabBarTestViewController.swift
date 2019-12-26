//
//  ScrollableTabBarTestViewController.swift
//  SpotUITestApp
//
//  Created by Shawn Clovie on 11/12/2019.
//  Copyright © 2019 Shawn Clovie. All rights reserved.
//

import UIKit
import Spot
import SpotUI

class ScrollableTabBarTestViewController: UIViewController {
	let tabController = ScrollableTabBarController(barAlignment: .leading)
	let testBar = ScrollableTabBarView(frame: .zero, axis: .horizontal, alignment: .leading)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tabController.setBar(position: .top, cover: false)
		tabController.setBar(styles: [
			\.buttonStack: Style().stackDistribution(.fill),
			\.selectIndicator: ScrollableTabBarStyleSet.shared.selectIndicator.duplicate.cornerRadius{_ in 2},
		])
		struct BarTest {
			static let size: CGFloat = 44
			let attr: NSLayoutConstraint.Attribute
			let count: Int
			let align: ScrollableTabBarView.Alignment
		}
		var info = ScrollableTabBarButton(title: "HV")
		info.style.font{_ in .systemFont(ofSize: 30)}
		info.selectedStyle.textColor(StyleShared.tintColorProducer)
		tabController.add(viewController: {
			let vc = UIViewController()
			vc.view.backgroundColor = .lightGray
			vc.view.layer.borderColor = UIColor.green.cgColor
			vc.view.layer.borderWidth = 10
			let viewV = UIView()
			var info = ScrollableTabBarButton()
			info.style
				.textColor(StyleShared.foregroundTextColorProducer)
				.buttonTitleColor(for: [.normal, .highlighted], {
					$0 == .highlighted ? StyleShared.tintColorProducer($1) : StyleShared.foregroundTextColorProducer($1)
				})
				.padding{_ in .init(top: 10, left: 10, bottom: 10, right: 10)}
			info.selectedStyle
				.textColor(StyleShared.tintColorProducer)
				.padding{_ in .init(top: 10, left: 10, bottom: 10, right: 10)}
			for (i, it) in ([
				.init(attr: .left, count: 5, align: .leading),
				.init(attr: .left, count: 5, align: .center),
				.init(attr: .left, count: 5, align: .trailing),
				.init(attr: .left, count: 5, align: .justified),
				.init(attr: .left, count: 30, align: .leading),
				] as [BarTest]).enumerated()
			{
				let bar = ScrollableTabBarView(frame: .zero, axis: .vertical, alignment: it.align)
				bar.style.selectIndicatorPosition = i >= 1 ? .leading : .trailing
				bar.style.buttonStack = Style()
					.stackAlignment(.fill)
					.stackDistribution(.fillProportionally)
				info.handler = { [weak bar] (_, i) in
					bar?.set(selectedIndex: CGFloat(i), highlightButton: true, animated: true)
				}
				for i in 1...it.count {
					info.title = "\(i)"
					bar.add(button: info)
				}
				viewV.addSubview(bar)
				viewV.spot.constraints(bar, attributes: [.top, .bottom])
				viewV.spot.constraints(bar, attributes: [it.attr], constant: BarTest.size * CGFloat(i))
				bar.widthAnchor.constraint(equalToConstant: BarTest.size).spot.setActived()
				bar.set(selectedIndex: 0, highlightButton: true, animated: false)
			}
			let viewH = UIView()
			for (i, it) in ([
				.init(attr: .top, count: 5, align: .leading),
				.init(attr: .top, count: 5, align: .center),
				.init(attr: .top, count: 5, align: .trailing),
				.init(attr: .top, count: 5, align: .justified),
				.init(attr: .top, count: 30, align: .leading),
				] as [BarTest]).enumerated()
			{
				let bar = ScrollableTabBarView(frame: .zero, axis: .horizontal, alignment: it.align)
				bar.style.selectIndicatorPosition = i >= 1 ? .leading : .trailing
				bar.style.buttonStack = Style()
					.stackAlignment(.fill)
					.stackDistribution(.fillProportionally)
				info.handler = { [weak bar] (_, i) in
					bar?.set(selectedIndex: CGFloat(i), highlightButton: true, animated: true)
				}
				for i in 1...it.count {
					info.title = "\(i)"
					bar.add(button: info)
				}
				viewH.addSubview(bar)
				viewH.spot.constraints(bar, attributes: [.left, .right])
				viewH.spot.constraints(bar, attributes: [it.attr], constant: BarTest.size * CGFloat(i))
				bar.heightAnchor.constraint(equalToConstant: BarTest.size).spot.setActived()
				bar.set(selectedIndex: 0, highlightButton: true, animated: false)
			}
			let stack = UIStackView(arrangedSubviews: [viewV, viewH])
			stack.axis = .vertical
			stack.distribution = .fillEqually
			stack.alignment = .fill
			vc.view.addSubview(stack)
			vc.view.spot.constraints(stack)
			return vc
		}(), tab: info)
		tabController.add(viewControllers: ([
			"SQ": .red,
			"实现实现实现🂨😦实现实": .yellow,
			"🙀🎉": .blue,
			] as [String: UIColor]).map{
				let vc = UIViewController()
				vc.view.backgroundColor = $0.value
				vc.view.layer.borderColor = UIColor.green.cgColor
				vc.view.layer.borderWidth = 10
				info.title = $0.key
				return (vc, info)
			})
		let leftButton = ScrollableTabBarButton(title: "🚫") { [weak self] _, _ in
			self?.dismiss(animated: true, completion: nil)
		}
		leftButton.style.font{_ in .systemFont(ofSize: 12)}
			.image{_ in .name("images/action_color_picker.pdf", size: .init(width: 16, height: 16))}
		tabController.setBar(sideButtons: [
			.leading: leftButton,
		])
		spot.addChild(tabController)
		view.spot.constraints(tabController.view)
		
		let actionBar = ScrollableTabBarView(frame: .zero, axis: .horizontal, alignment: .justified)
		actionBar.add(button: .init(title: "🔃Hidden") { [weak self] (_, _) in
			guard let self = self else {return}
			self.tabController.setBar(hidden: !self.tabController.isBarHidden)
		})
		actionBar.add(button: .init(title: "🔃TabPos") { [weak self] (_, _) in
			guard let self = self else {return}
			self.tabController.setBar(position: self.tabController.tabBarPosition == .top ? .bottom : .top, cover: false)
		})
		actionBar.add(button: .init(title: "🔃TestBar") { [weak self] (_, _) in
			self?.resetTestBar()
		})
		view.addSubview(actionBar)
		view.spot.constraints(actionBar, attributes: [.centerX, .centerY, .width])
		view.addSubview(testBar)
		view.spot.constraints(testBar, attributes: [.centerX, .width])
		testBar.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 50).spot.setActived()
	}
	
	func resetTestBar() {
		let count = Int.random(in: 10...25)
		testBar.reset(buttons: (1...count).map{
			ScrollableTabBarButton(title: "\($0)") { [weak self] (_, index) in
				self?.testBar.set(selectedIndex: CGFloat(index), highlightButton: true, animated: true)
			}
		})
		testBar.set(selectedIndex: CGFloat(count - 1), highlightButton: true, animated: true)
	}
}

class ScrollableTabBarEqualTestViewController: UIViewController {
	let tabController = ScrollableTabBarController(barAlignment: .justified)
	override func viewDidLoad() {
		super.viewDidLoad()
		tabController.setBar(position: .bottom, cover: true)
		tabController.setBar(styles: [\.buttonStack : Style()
			.stackDistribution(.fillProportionally).spacing{_ in 10}])
		let style = Style()
			.textColor(StyleShared.foregroundTextColorProducer)
			.padding{_ in .init(top: 10, left: 20, bottom: 10, right: 20)}
		for color in [UIColor.red, UIColor.yellow, UIColor.blue] {
			let vc = UIViewController()
			vc.view.backgroundColor = color
			vc.view.layer.borderColor = UIColor.green.cgColor
			vc.view.layer.borderWidth = 10
			tabController.add(viewController: vc, tab: .init(title: "\(DecimalColor(with: color).hexString)", style: style))
		}
		spot.addChild(tabController)
		view.spot.constraints(tabController.view)
		
		let actionBar = ScrollableTabBarView(frame: .zero, axis: .horizontal, alignment: .justified)
		actionBar.add(button: .init(title: "🚫") { [weak self] (_, _) in
			self?.dismiss(animated: true, completion: nil)
		})
		actionBar.add(button: .init(title: "🔃Hidden") { [weak self] (_, _) in
			guard let self = self else {return}
			self.tabController.setBar(hidden: !self.tabController.isBarHidden)
		})
		actionBar.add(button: .init(title: "🔃Position") { [weak self] (_, _) in
			guard let self = self else {return}
			self.tabController.setBar(position: self.tabController.tabBarPosition == .top ? .bottom : .top, cover: true)
		})
		view.addSubview(actionBar)
		view.spot.constraints(actionBar, attributes: [.centerX, .centerY, .width])
	}
}
