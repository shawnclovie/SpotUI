//
//  ActionTestCase.swift
//  SpotUITestApp
//
//  Created by Shawn Clovie on 12/22/15.
//  Copyright © 2015 Shawn Clovie. All rights reserved.
//

import UIKit
import AVFoundation
import Spot
import SpotUI

func initializeStoryboardViewController(name: String) -> UIViewController {
	let sb = UIStoryboard(name: "Main", bundle: nil)
	return sb.instantiateViewController(withIdentifier: name)
}

let rotateOrientations: [UIImage.Orientation] = [.left, .right, .up, .down, .leftMirrored, .rightMirrored, .upMirrored, .downMirrored]

class SimpleTestViewController: UIViewController {
	
	struct StyleSet {
		let view = Style()
			.backgroundColor(StyleShared.backgroundColorProducer)
	}
	
	private let logger = Logger(tag: "\(classForCoder())", for: .trace)
	var index = 0
	let testImage = UIImage(named: "images/186_52c0eca125447.jpg")!
	
	let deviceInfoText = UITextView()
	let testButton = UIButton(type: .custom)
	let testImageView = AnimatableImageView()
	
	let actionTableView = UITableView(frame: .zero, style: .plain)
	
	var internetObserver = NetworkObserver.withInternet!
	var wifiObserver = NetworkObserver.withWiFi
	
	private var style = StyleSheet()
	
	private var rotateIndex = -1
	private var progressLayer: ProgressLayer?
	private var progressTimer: WeakTimer?
	
	private let actions: [(title: String, action: (SimpleTestViewController)->Void)] = [
		("image: rotate", {vc in
			vc.rotateIndex += 1
			if vc.rotateIndex >= rotateOrientations.count {
				vc.rotateIndex = 0
			}
			let ori = rotateOrientations[vc.rotateIndex]
			print("rotate orientation:", ori.rawValue)
			let image = vc.testImage.spot.oriented(by: ori)!
			let data = image.cgImage!.spot.encode(as: .jpeg(quality: 1), orientation: .up)!
			vc.testImageView.image = UIImage(data: data, scale: 2)
		}),
		("image: resizing", {vc in
			let seed: CGFloat = 100
			let scale = CGFloat(arc4random() % UInt32(seed) + 1) / seed * 0.3
			let cg = vc.testImage.cgImage!
			print("resize with scale:", scale)
			if let resized = cg.spot.resizingImage(to: vc.testImage.size * scale) {
				vc.testImageView.image = UIImage(cgImage: resized)
			} else {
				print("resize failed")
			}
		}),
		("image: pdf", { vc in
			let path = Bundle.main.url(forResource: "images/action_color_picker.pdf", withExtension: nil)!
			let image = UIImage.spot_fromPDF(path, contentSize: vc.testImageView.bounds.size)
			vc.testImageView.contentMode = .scaleAspectFit
			vc.testImageView.image = image
			vc.testImageView.layer.borderColor = UIColor.black.cgColor
			vc.testImageView.layer.borderWidth = 2
		}),
		("image: still", { vc in
			let path = Bundle.main.url(forResource: "images/186_52c0eca125447.jpg", withExtension: nil)!
			setImage(path: path, to: vc.testImageView)
		}),
		("image: gif", { vc in
			let path = Bundle.main.url(forResource: "images/Cat-party.gif", withExtension: nil)!
			setImage(path: path, to: vc.testImageView)
		}),
		("image: animated", { vc in
			let path = Bundle.main.url(forResource: "images/Cat-party.gif", withExtension: nil)!
			let image = AnimatableImage(.path(path))!
			vc.testImageView.image = image.createAnimatedImages(scaleToFit: CGSize(width: 100, height: 100))
		}),
		("RectangleProgressLayer", { vc in
			vc.progressTimer?.invalidate()
			let progress = vc.progressLayer as? RectangleProgressLayer ?? .init()
			vc.progressLayer = progress
			progress.set(direction: .leftToRight, size: .init(width: vc.view.bounds.width, height: 200), UIColor.red.cgColor)
			prepareProgress(progress, parent: vc.view)
			vc.progressTimer = WeakTimer(interval: 0.05, repeats: true) { (timer) in
				progress.percentage += 0.03
				if progress.percentage > 1 {
					timer.invalidate()
					DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
						progress.removeFromSuperlayer()
					}
				}
			}
		}),
		("CircleProgressLayer", { vc in
			vc.progressTimer?.invalidate()
			let progress = vc.progressLayer as? CircleProgressLayer ?? .init()
			vc.progressLayer = progress
			progress.set(radius: vc.view.bounds.width * 0.4, lineWidth: 20)
			progress.set(color: .red)
			prepareProgress(progress, parent: vc.view)
			vc.progressTimer = WeakTimer(interval: 0.05, repeats: true) { (timer) in
				progress.percentage += 0.03
				if progress.percentage > 1 {
					timer.invalidate()
					DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
						progress.removeFromSuperlayer()
					}
				}
			}
		}),
		("DataSourceTable", { vc in
			let newVC = TestingDataSourceTableViewController(style: .grouped)
			vc.navigationController?.pushViewController(newVC, animated: true)
		}),
		("ActionPanelVC", { vc in
			let newVC = ActionPanelController(nibName: nil, bundle: nil)
			newVC.touchUpPanelOutsideHandler = {$0.dismiss(animated: true, completion: nil)}
			newVC.touchUpCancelHandler = newVC.touchUpPanelOutsideHandler
			newVC.titleView.text = "Title"
			let label = UILabel()
			label.text = "abc"
			label.sizeToFit()
			newVC.contentView.addSubview(label)
			newVC.contentView.spot.constraints(label)
			vc.present(newVC, animated: true, completion: nil)
		}),
		("AlertVC", { vc in
			let newVC = AlertController(title: "Title", message: "Message", actions: [
				.init(title: "OK", style: .default, handler: nil),
				.init(title: "cancel", style: .cancel, handler: nil),
				.init(title: "delete", style: .destructive, handler: nil),
				.init(title: "Alert", style: .default, handler: { (_) in
					vc.present(UIAlertController(title: nil, message: nil, preferredStyle: .alert, actions: [
					.init(title: "OK", style: .default, handler: nil)
					], popover: (vc.actionTableView, vc.actionTableView.bounds)), animated: true, completion: nil)
					}),
			])
			let data = try! Data(contentsOf: Bundle.main.url(forResource: "images/some.html", withExtension: nil)!)
			let label = UITextView()
			label.backgroundColor = .clear
			label.contentInset = .init(top: 8, left: 8, bottom: 8, right: 8)
			label.spot.disableInteraction()
			label.attributedText = try! .init(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
			newVC.contentView.addSubview(label)
			newVC.contentView.spot.constraints(label)
			vc.present(newVC, animated: true, completion: nil)
		}),
		("ActionSheet", { vc in
			let newVC = ActionSheetViewController(nibName: nil, bundle: nil)
			newVC.titleView.text = "Title"
			_ = newVC.touchUpOnEdgeEvent.subscribe { (newVC) in
				newVC.dismiss(animated: true, completion: nil)
			}
			vc.present(newVC, animated: true, completion: nil)
		}),
		("EmptyResultView", { vc in
			let view = EmptyResultView(frame: vc.view.bounds)
			view.set(title: "Title", image: nil, description: "79C2C73A-5860-470D-BAE1-DF5160B0815F", buttonTitle: "Close")
			view.onButtonTapped = {
				$0.removeFromSuperview()
			}
			vc.view.addSubview(view)
			view.alpha = 0
			UIView.animate(withDuration: 0.2) {
				view.alpha = 1
			}
		}),
		("UIImagePicker", { vc in
			guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {return}
			let picker = UIImagePickerController.spot(source: .photoLibrary, mediaTypes: [.image, .movie])
			picker.delegate = vc
			vc.present(picker, animated: true, completion: nil)
		}),
		("ScrollableTabBar", { vc in
			let root = ScrollableTabBarController()
			root.modalPresentationStyle = .fullScreen
			root.tabBarPosition = .bottom
			root.setBarStack(style: Style().stackDistribution(.fillEqually))
			root.setBarSideButton(of: .leading, .init(title: "close", style: Style().image{_ in .name("images/action_color_picker.pdf", size: .init(width: 16, height: 16))}) { [weak root] _ in
				root?.dismiss(animated: true, completion: nil)
				})
			root.setBarSideButton(of: .trailing, .init(title: "switch tab pos") { [weak root] _ in
				guard let root = root else {return}
				root.tabBarPosition = root.tabBarPosition == .top ? .bottom : .top
			})
			let vertical = UIViewController()
			let bar = ScrollableTabBarView(frame: .zero)
			bar.axis = .vertical
			bar.style.selectIndicatorPosition = .leading
			bar.style.buttonStack = Style()
				.stackDistribution(.fillEqually)
				.stackAlignment(.fill)
			let style = Style()
				.buttonTitleColor(for: [.normal, .highlighted], {(state, trait) in
					switch state {
					case .highlighted:return StyleShared.tintColorProducer(trait)
					default:return StyleShared.foregroundTextColorProducer(trait)
					}
				})
				.padding{_ in .init(top: 10, left: 10, bottom: 10, right: 10)}
			let fn: (Int)->Void = { [weak bar] (i) in
				bar?.selectedIndex = i
			}
			for i in 1...10 {
				bar.add(button: .init(title: "\(i)", style: style, handler: fn))
			}
			vertical.view.addSubview(bar)
			vertical.view.spot.constraints(bar, attributes: [.top, .left, .bottom])
			bar.widthAnchor.constraint(equalToConstant: 100).spot.setActived()
			root.add(viewController: vertical, tab: .init(title: "V"))
			root.add(viewControllers: ([
				"SQ": .red,
				"实现实现实现🂨😦实现实": .yellow,
				"🙀🎉": .blue,
				] as [String: UIColor]).map{
					let vc = UIViewController()
					vc.view.backgroundColor = $0.value
					return (vc, .init(title: $0.key))
				})
			vc.present(root, animated: true, completion: nil)
		}),
	]

	override func viewDidLoad() {
		super.viewDidLoad()
		
		style.bind(view, Style()
			.backgroundColor(StyleShared.backgroundColorProducer))
		let testButtonStyle = Style()
			.verticalAlignment(.top)
			.textAlignment(.left)
			.numberOfLines(0)
			.padding{_ in .init(top: 4, left: 15, bottom: 20, right: 50)}
			.textColor(StyleShared.foregroundTextColorProducer)
			.statefulImage{_ in [
				.normal: .solidColor(.red, size: .init(width: 10, height: 20)),
				.highlighted: .solidColor(.blue, size: .init(width: 20, height: 10)),
				]}
		print("testButton.padding=", testButtonStyle.getPadding(with: traitCollection))
		style.bind(testButton, testButtonStyle)
		style[Style()
			.textColor(StyleShared.foregroundTextColorProducer)] = deviceInfoText
		style["image"] = Style()
			.border{.init($0.spot.userInterfaceStyle == .dark ? .white : .black, width: 2)}
			.image{_ in .solidColor(.yellow, size: .init(width: 30, height: 30))}

		let device = UIDevice.current
		let text = "device\n" +
			"VendorUDID: \(device.identifierForVendor?.uuidString ?? "")\n" +
			"name: \(device.name)\n" +
			"model: \(device.model) - \(Version.deviceModelName)\n\n" +
			"locale: \(Locale.current.identifier)\n"
		logger.log(.info, text)
		let file = "foo/bar/abc.def"
		print("\(file): ext=\(file.spot.pathExtension!), last=\(file.spot.lastPathComponent!)")
		print("file.md5hashCode=", file.spot.md5HashCode)
		deviceInfoText.text = text
		deviceInfoText.spot.apply(styles: ["bg", "shadow", "border", "font"], with: traitCollection)
		deviceInfoText.isEditable = false
		view.addSubview(deviceInfoText)
		
		testButton.setTitle("Test Button", for: .normal)
		testButton.addTarget(self, action: #selector(touchUp(test:)), for: .touchUpInside)
		view.addSubview(testButton)
		
		testImageView.spot.apply(styles: ["image"], with: traitCollection)
		view.addSubview(testImageView)
		StyleSheet.shared.apply(styles: ["image"], to: view.layer, with: traitCollection)
		
		actionTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		actionTableView.delegate = self
		actionTableView.dataSource = self
		view.addSubview(actionTableView)
		
		let barItem = UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)
		StyleSheet.shared.apply(styles: ["bar-item"], to: barItem, with: traitCollection)
		navigationItem.rightBarButtonItem = barItem
		
		StyleSheet.shared.apply(styles: ["bar"], to: navigationController!.navigationBar, with: traitCollection)
		
		[
			deviceInfoText.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
			deviceInfoText.leftAnchor.constraint(equalTo: view.leftAnchor),
			deviceInfoText.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
			deviceInfoText.heightAnchor.constraint(equalToConstant: 120),
			testButton.topAnchor.constraint(equalTo: deviceInfoText.topAnchor),
			testButton.leftAnchor.constraint(equalTo: deviceInfoText.rightAnchor),
			testButton.rightAnchor.constraint(equalTo: view.rightAnchor),
			testButton.heightAnchor.constraint(equalTo: deviceInfoText.heightAnchor),
			actionTableView.topAnchor.constraint(equalTo: deviceInfoText.bottomAnchor),
			actionTableView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor),
			actionTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
			actionTableView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
			testImageView.topAnchor.constraint(equalTo: deviceInfoText.bottomAnchor),
			testImageView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor),
			testImageView.leftAnchor.constraint(equalTo: actionTableView.rightAnchor),
			testImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
		].spot_set(active: true)
		
		style.applyBounds(with: traitCollection)
		style.apply(styles: ["image"], to: testImageView, with: traitCollection)

		internetObserver.startObserve()
		wifiObserver!.startObserve()
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		style.applyBounds(with: traitCollection)
		style.apply(styles: ["image"], to: testImageView, with: traitCollection)
	}
	
	@IBAction func touchedPushVC(_ sender: UIBarButtonItem) {
		guard let vcID = sender.title else {
			return
		}
		let vc = initializeStoryboardViewController(name: vcID)
		navigationController?.pushViewController(vc, animated: true)
	}
	
	@objc private func touchUp(test: UIButton) {
		test.isHighlighted = test.state == .normal
	}
}

private func prepareProgress(_ layer: ProgressLayer, parent: UIView) {
	let viewSize = parent.bounds.size
	layer.position = .init(x: viewSize.width / 2, y: viewSize.height / 2)
	if layer.superlayer == nil {
		parent.layer.addSublayer(layer)
	}
	layer.resetPercentage()
//	layer.percentage = 0
}

private func setImage(path: URL, to: AnimatableImageView) {
	guard let image = AnimatableImage(.path(path)) else {
		return
	}
	if image.frameCount > 1 {
		to.animatableImage = image
	} else {
		to.image = image.createImage(at: 0)
	}
}

extension SimpleTestViewController: UITableViewDataSource, UITableViewDelegate {
	func numberOfSections(in tableView: UITableView) -> Int {
		1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		actions.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.textLabel!.text = actions[indexPath.row].title
		return cell
	}
	
	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		actions[indexPath.row].action(self)
		return nil
	}
}

extension SimpleTestViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		picker.dismiss(animated: true, completion: nil)
		let result = info.spot_parseResult()
		print(result, info)
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
}
