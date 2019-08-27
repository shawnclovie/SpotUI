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
	let testImageView = AnimatableImageView()
	
	let actionTableView = UITableView(frame: .zero, style: .plain)
	
	var internetObserver = NetworkObserver.withInternet!
	var wifiObserver = NetworkObserver.withWiFi
	
	private var style = StyleSheet()
	
	private var rotateIndex = -1
	
	private let actions: [(title: String, action: (SimpleTestViewController)->Void)] = [
		("rotate image", {vc in
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
		("resizingCGImage", {vc in
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
		("pdf image", { vc in
			let path = Bundle.main.url(forResource: "images/action_color_picker.pdf", withExtension: nil)!
			let image = UIImage.spot_fromPDF(path, contentSize: vc.testImageView.bounds.size)
			vc.testImageView.contentMode = .scaleAspectFit
			vc.testImageView.image = image
			vc.testImageView.layer.borderColor = UIColor.black.cgColor
			vc.testImageView.layer.borderWidth = 2
		}),
		("gif", { vc in
			let path = Bundle.main.url(forResource: "images/Cat-party.gif", withExtension: nil)!
			vc.testImageView.setImage(path: path)
//			vc.testImageView.image = vc.testImageView.image?.spot.flipped(axisX: false, axisY: true)
		}),
		("animatedImage", { vc in
			let path = Bundle.main.url(forResource: "images/Cat-party.gif", withExtension: nil)!
			let image = AnimatableImage(.url(path))!
			vc.testImageView.image = image.createAnimatedImages(scaleToFit: CGSize(width: 100, height: 100))
		}),
		("ProgressLayer with URLTask", { vc in
			let qs = "abc=2&xyz=fff".spot.parsedQueryString
			print(qs)
			let progressLayer = RectangleProgressLayer(direction: .bottomToTop, size: vc.view.bounds.size, UIColor.gray.cgColor)
			vc.view.layer.addSublayer(progressLayer)
			progressLayer.percentage = 1
			let cn = URLConnection()
			cn.config.requestCachePolicy = .reloadIgnoringLocalCacheData
			cn.config.urlCache = nil
			URLTask(.spot(.get, URL(string: "https://tb1.bdstatic.com/tb/cms/frs/bg/default_head20141014.jpg")!))
				.request(with: cn, progression: { progress in
					progressLayer.percentage = 1 - progress.percentage
				}) { task, result in
					print(result)
					progressLayer.removeFromSuperlayer()
			}
		}),
		("DataSourceTable", { vc in
			let newVC = DataSourceTableViewController(style: .grouped)
			newVC.delegate.data.sections = [
				DataSourceSection("Section A", items: [
					DataSourceCell(
						title: .init(string: "Cell A", attributes: [.font: UIFont.systemFont(ofSize: 40)]),
						subtitle: .init(string: "Description A", attributes: [.font: UIFont.systemFont(ofSize: 10)]),
						mark: "cell_a"),
					DataSourceCell(title: "Cell B", mark: "cell_b")
					], mark: "section_a"),
				DataSourceSection("", items: [
					DataSourceCell(title: "Cell 2A"),
					]),
			]
			newVC.delegate.selectedCell = { [weak vc] dele, table, ip in
				table.deselectRow(at: ip, animated: true)
				if let mark = dele.data.cell(at: ip)?.mark as? String {
					vc?.logger.log(.trace, mark)
				}
			}
			vc.navigationController?.pushViewController(newVC, animated: true)
		}),
		("ActionPanelVC", { vc in
			let newVC = ActionPanelController(nibName: nil, bundle: nil)
			newVC.touchUpPanelOutsideHandler = {$0.dismiss(animated: true, completion: nil)}
			newVC.touchUpCancelHandler = newVC.touchUpPanelOutsideHandler
			let label = UILabel()
			label.text = "abc"
			label.sizeToFit()
			newVC.panel.addSubview(label)
			vc.present(newVC, animated: true, completion: nil)
		}),
		("AlertVC", { vc in
			let newVC = AlertController(nibName: nil, bundle: nil)
			newVC.set(title: "Title", message: "Message")
			newVC.addAction(.init(title: "OK", style: .default, handler: nil))
			newVC.addAction(.init(title: "cancel", style: .cancel, handler: nil))
			newVC.addAction(.init(title: "delete", style: .destructive, handler: nil))
			newVC.addAction(.init(title: "Alert", style: .default, handler: { (_) in
				vc.present(UIAlertController(title: nil, message: nil, preferredStyle: .alert, actions: [
					.init(title: "OK", style: .default, handler: nil)
				], popover: (vc.actionTableView, vc.actionTableView.bounds)), animated: true, completion: nil)
			}))
			newVC.panelView.backgroundColor = .white
			let label = UITextField()
			label.text = "abc"
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
		})
	]

	override func viewDidLoad() {
		super.viewDidLoad()
		
		style.bind(view, Style()
			.backgroundColor(StyleShared.backgroundColorProducer))
		style[Style()
			.textColor(StyleShared.foregroundTextColorProducer)] = deviceInfoText
		style["image"] = Style().border{($0.spot.userInterfaceStyle == .dark ? .white : .black, 2)}

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
			deviceInfoText.rightAnchor.constraint(equalTo: view.rightAnchor),
			deviceInfoText.heightAnchor.constraint(equalToConstant: 300),
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
