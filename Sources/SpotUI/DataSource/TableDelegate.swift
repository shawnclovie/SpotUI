//
//  TableDelegate.swift
//  SpotUI
//
//  Created by Shawn Clovie on 5/20/16.
//  Copyright © 2016 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit

open class TableDelegate<SectionType: DataSourceSectionType>: NSObject,
UITableViewDataSource, UITableViewDelegate {
	open var data = DataSource<SectionType>()
	
	open var deleteConfirmationButtonText = "Remove".spot.localize()
	
	open var deletingRowAnimation = UITableView.RowAnimation.left
	
	open var configureCell:			((TableDelegate, UITableView, IndexPath, _ item: SectionType.Item?)->UITableViewCell)?
	
	open var configureHeaderView:	((TableDelegate, UITableView, Int)->UIView?)?
	open var configureFooterView:	((TableDelegate, UITableView, Int)->UIView?)?
	
	open var canEditRow:			((TableDelegate, UITableView, IndexPath)->Bool)?
	
	open var willDisplayHeader:		((TableDelegate, UITableView, UIView, Int)->Void)?
	open var willDisplayFooter:		((TableDelegate, UITableView, UIView, Int)->Void)?
	open var willDisplayCell:		((TableDelegate, UITableView, IndexPath)->Void)?
	
	open var accessoryButtonTapped:	((TableDelegate, UITableView, IndexPath)->Void)?
	open var shouldHighlightCell:	((TableDelegate, UITableView, IndexPath)->Bool)?
	
	open var selectedCell:			((TableDelegate, UITableView, IndexPath)->Void)?
	
	open var deletedCell:			((TableDelegate, UITableView, SectionType.Item)->Void)?
	
	open var shouldDeleteSection:	((TableDelegate, UITableView, Int)->Bool)?
	
	open var shouldShowMenu:		((TableDelegate, UITableView, IndexPath)->Bool)?
	
	open var canPerformAction:		((TableDelegate, UITableView, IndexPath, _ action: Selector, _ sender: Any?) -> Bool)?
	
	open var performAction:			((TableDelegate, UITableView, IndexPath, _ action: Selector, _ sender: Any?)->Void)?
	
	public override init() {
		super.init()
	}
	
	open func delegate(_ table: UITableView) {
		table.delegate = self
		table.dataSource = self
	}
	
	// MARK: UITableViewDataSource
	
	open func numberOfSections(in tableView: UITableView) -> Int {
		data.sections.count
	}
	
	open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		section < data.sections.count ? data.sections[section].items.count : 0
	}
	
	open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		guard section < data.sections.count else {return nil}
		let title = data.sections[section].description
		return title.isEmpty ? nil : title
	}
	
	open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		configureHeaderView?(self, tableView, section)
	}
	
	open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		configureFooterView?(self, tableView, section)
	}
	
	open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		configureCell?(self, tableView, indexPath, data.cell(at: indexPath))
			?? tableView.dequeueReusableCell(withIdentifier: data.cellReuseID,
			                                 for: indexPath)
	}
	
	// MARK: UITableViewDelegate
	
	open func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		willDisplayHeader?(self, tableView, view, section)
	}
	
	open func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
		willDisplayFooter?(self, tableView, view, section)
	}
	
	open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		willDisplayCell?(self, tableView, indexPath)
	}
	
	open func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
		accessoryButtonTapped?(self, tableView, indexPath)
	}
	
	open func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		shouldHighlightCell?(self, tableView, indexPath) ?? true
	}
	
	open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		(data.cell(at: indexPath) as? DataSourceCell)?.selectedHandler?()
		selectedCell?(self, tableView, indexPath)
	}
	
	open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		canEditRow?(self, tableView, indexPath) ?? false
	}
	
	open func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
		shouldShowMenu?(self, tableView, indexPath) ?? false
	}
	
	open func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
		canPerformAction?(self, tableView, indexPath, action, sender) ?? false
	}
	
	open func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
		performAction?(self, tableView, indexPath, action, sender)
	}
	
	open func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
		deleteConfirmationButtonText
	}
	
	open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			let section = indexPath.section
			let removedItem = data.sections[section].items.remove(at: indexPath.row)
			tableView.deleteRows(at: [indexPath],
			                     with: deletingRowAnimation)
			deletedCell?(self, tableView, removedItem)
			if data.sections[section].items.isEmpty
				&& shouldDeleteSection?(self, tableView, section) ?? true {
				data.sections.remove(at: section)
				tableView.deleteSections(IndexSet(integer: section),
				                         with: deletingRowAnimation)
			}
		}
	}
}
#endif
