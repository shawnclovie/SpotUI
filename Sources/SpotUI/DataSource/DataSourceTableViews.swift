//
//  DataSourceViews.swift
//  SpotUI
//
//  Created by Shawn Clovie on 3/17/16.
//  Copyright © 2016 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import Spot

public struct DataSourceCell {
	public enum Accessory {
		case none
		case image(UIImage)
		case text(String)
		case system(UITableViewCell.AccessoryType)
		case view(UIView)
		/// Create accessory on runtime
		case handler(()->Accessory)
	}
	
	public typealias SelectHandler = (UITableView, IndexPath)->Void
	
	public var title: NSAttributedString
	public var subtitle: NSAttributedString?
	public var image: UIImage?
	public var mark: Any?
	public var accessory: Accessory
	public var selectedHandler: SelectHandler?
	public var selectionStyle: UITableViewCell.SelectionStyle = .default
	
	public var brimmingView: UIView?
	
	public init(brimming: UIView, mark: Any? = nil, selectedHandler: SelectHandler? = nil) {
		title = .init()
		accessory = .none
		brimmingView = brimming
		self.mark = mark
		self.selectedHandler = selectedHandler
	}
	
	public init(title: String,
				subtitle: String? = nil,
				image: UIImage? = nil,
				accessory: Accessory = .system(.none),
				mark: Any? = nil,
				selectedHandler: SelectHandler? = nil) {
		self.init(title: .init(string: title), subtitle: subtitle.map(NSAttributedString.init), image: image, accessory: accessory, mark: mark, selectedHandler: selectedHandler)
	}
	
	public init(title: NSAttributedString,
	            subtitle: NSAttributedString? = nil,
	            image: UIImage? = nil,
	            accessory: Accessory = .system(.none),
	            mark: Any? = nil,
	            selectedHandler: SelectHandler? = nil) {
		self.title = title
		self.subtitle = subtitle
		self.image = image
		self.mark = mark
		self.accessory = accessory
		self.selectedHandler = selectedHandler
	}
	
	public func apply(on cell: UITableViewCell) {
		if let it = brimmingView {
			if !it.isDescendant(of: cell) {
				cell.contentView.addSubview(it)
				cell.contentView.spot.constraints(it)
			}
		}
		cell.textLabel?.attributedText = title
		cell.detailTextLabel?.attributedText = subtitle
		cell.imageView?.image = image
		cell.selectionStyle = selectionStyle
		var accessory = self.accessory
		if case .handler(let handler) = accessory {
			accessory = handler()
		}
		switch accessory {
		case .none:
			cell.accessoryType = .none
			cell.accessoryView = nil
		case .system(let type):
			cell.accessoryType = type
			cell.accessoryView = nil
		case .image(let image):
			cell.accessoryView = UIImageView(image: image)
		case .view(let view):
			cell.accessoryView = view
		case .text(let text):
			let view = UILabel()
			view.text = text
			view.sizeToFit()
			cell.accessoryView = view
		default:break
		}
	}
	
	public func didEndDisplaying(on cell: UITableViewCell) {
		brimmingView?.removeFromSuperview()
	}
}

open class DataSourceTableViewCell: UITableViewCell {
	public static var cellReuseID = "cell"
	
	public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
		selectionStyle = .none
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}

open class DataSourceTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	public typealias Section = DataSourceSection<DataSourceCell>
	
	public var dataSource = DataSource<Section>()
	public let tableView: UITableView
	
	public init(style: UITableView.Style = .plain) {
		tableView = UITableView(frame: .zero, style: style)
		super.init(nibName: nil, bundle: nil)
	}
	
	required public convenience init?(coder aDecoder: NSCoder) {
		self.init()
	}
	
	override open func viewDidLoad() {
		super.viewDidLoad()
		initTableView()
	}
	
	open func initTableView() {
		guard tableView.superview == nil else {
			return
		}
		view.addSubview(tableView)
		tableView.register(DataSourceTableViewCell.self, forCellReuseIdentifier: DataSourceTableViewCell.cellReuseID)
		tableView.dataSource = self
		tableView.delegate = self
		tableView.reloadData()
		view.spot.constraints(tableView)
	}
	
	open func numberOfSections(in tableView: UITableView) -> Int {
		dataSource.sections.count
	}
	
	open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		dataSource.section(at: section)?.items.count ?? 0
	}
	
	open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: DataSourceTableViewCell.cellReuseID, for: indexPath)
		dataSource.cell(at: indexPath)?.apply(on: cell)
		return cell
	}
	
	public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		dataSource.cell(at: indexPath)?.didEndDisplaying(on: cell)
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		dataSource.cell(at: indexPath)?.selectedHandler?(tableView, indexPath)
	}
}
#endif
