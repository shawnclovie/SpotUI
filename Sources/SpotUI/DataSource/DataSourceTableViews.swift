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
	public var title: NSAttributedString
	public var subtitle: NSAttributedString?
	public var image: UIImage?
	public var mark: Any?
	public var accessory: Accessory
	public var selectedHandler: (()->Void)?
	
	public var selectionStyle: UITableViewCell.SelectionStyle = .default
	
	public init(title: String,
				subtitle: String? = nil,
				image: UIImage? = nil,
				accessory: Accessory = .system(.none),
				mark: Any? = nil,
				selectedHandler: (()->Void)? = nil) {
		self.init(title: .init(string: title), subtitle: subtitle.map(NSAttributedString.init), image: image, accessory: accessory, mark: mark, selectedHandler: selectedHandler)
	}
	
	public init(title: NSAttributedString,
	            subtitle: NSAttributedString? = nil,
	            image: UIImage? = nil,
	            accessory: Accessory = .system(.none),
	            mark: Any? = nil,
	            selectedHandler: (()->Void)? = nil) {
		self.title = title
		self.subtitle = subtitle
		self.image = image
		self.mark = mark
		self.accessory = accessory
		self.selectedHandler = selectedHandler
	}
	
	public func apply(on cell: UITableViewCell) {
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
}

open class DataSourceTableViewCell: UITableViewCell {
	public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
		selectionStyle = .none
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}

open class DataSourceTableViewController: UIViewController {
	public typealias Section = DataSourceSection<DataSourceCell>
	
	public let delegate = TableDelegate<Section>()
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
		tableView.register(DataSourceTableViewCell.self,
		                   forCellReuseIdentifier: delegate.data.cellReuseID)
		delegate.delegate(tableView)
		delegate.configureCell = { dele, table, ip, item in
			let cell = table.dequeueReusableCell(withIdentifier: dele.data.cellReuseID, for: ip)
			item?.apply(on: cell)
			return cell
		}
		tableView.reloadData()
		view.spot.constraints(tableView)
	}
}
#endif
