//
//  DataSource.swift
//  SpotUI
//
//  Created by Shawn Clovie on 5/19/16.
//  Copyright © 2016 Shawn Clovie. All rights reserved.
//

import Foundation
import Spot

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
	
	public var description: String {title}
	
	public func item(at index: Int) -> Item? {
		(0..<items.count).contains(index) ? items[index] : nil
	}
	
	@discardableResult
	public mutating func setItem(_ item: Item, at index: Int) -> Bool {
		if items.indices.contains(index) {
			items[index] = item
			return true
		}
		return false
	}
}

public struct DataSource<SectionType: DataSourceSectionType> {
	public var sections: [SectionType]
	
	public init(sections: [SectionType] = []) {
		self.sections = sections
	}
	
	@inlinable
	public func section(at: Int) -> SectionType? {
		sections.indices.contains(at) ? sections[at] : nil
	}
	
	@inlinable
	public func cell(at indexPath: IndexPath) -> SectionType.Item? {
		cell(at: indexPath.row, section: indexPath.section)
	}
	
	@inlinable
	public func cell(at row: Int, section: Int) -> SectionType.Item? {
		self.section(at: section)?.items.spot_value(at: row)
	}
	
	@discardableResult
	public mutating func setCell(_ cell: SectionType.Item, section: Int, row: Int) -> Bool {
		guard sections.indices.contains(section) && sections[section].items.indices.contains(row) else {
			return false
		}
		sections[section].items[row] = cell
		return true
	}
}
