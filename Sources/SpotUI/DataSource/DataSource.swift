//
//  DataSource.swift
//  SpotUI
//
//  Created by Shawn Clovie on 5/19/16.
//  Copyright © 2016 Shawn Clovie. All rights reserved.
//

import Foundation

public protocol DataSourceSectionType: CustomStringConvertible {
	associatedtype Item: Any
	var items: [Item] {get set}
	init(original: Self, items: [Item])
}

public struct DataSourceSection<ItemType: Any>: DataSourceSectionType {
	public typealias Item = ItemType
	public var title: String
	public var items: [ItemType]
	public var mark: Any?
	
	public init(_ title: String, items: [ItemType] = [], mark: Any? = nil) {
		self.title = title
		self.items = items
		self.mark = mark
	}
	
	public init(original: DataSourceSection, items: [ItemType]) {
		self.init(original.title, items: items, mark: original.mark)
	}
	
	public var description: String {
		title
	}
	
	public func item(at index: Int) -> Item? {
		(0..<items.count).contains(index) ? items[index] : nil
	}
	
	@discardableResult
	public mutating func setItem(_ item: Item, at index: Int) -> Bool {
		if (0..<items.count).contains(index) {
			items[index] = item
			return true
		}
		return false
	}
}

public struct DataSource<SectionType: DataSourceSectionType> {
	public var cellReuseID = "Cell"
	public var sections: [SectionType]
	
	public init(sections: [SectionType] = []) {
		self.sections = sections
	}
	
	public func section(at: Int) -> SectionType? {
		sections.indices.contains(at) ? sections[at] : nil
	}
	
	public func cell(at indexPath: IndexPath) -> SectionType.Item? {
		cell(at: indexPath.row, section: indexPath.section)
	}
	
	public func cell(at row: Int, section: Int) -> SectionType.Item? {
		guard sections.indices.contains(section) else {
			return nil
		}
		return sections[section].items[row]
	}
	
	@discardableResult
	public mutating func setCell(_ cell: SectionType.Item, section: Int, row: Int) -> Bool {
		if section >= 0 && row >= 0
			&& section < sections.count
			&& row < sections[section].items.count {
			sections[section].items[row] = cell
			return true
		}
		return false
	}
}
