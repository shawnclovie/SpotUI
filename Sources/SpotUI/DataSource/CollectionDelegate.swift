//
//  CollectionDelegate.swift
//  SpotUI
//
//  Created by Shawn Clovie on 5/20/16.
//  Copyright © 2016 Shawn Clovie. All rights reserved.
//

#if canImport(UIKit)
import UIKit

open class CollectionDelegate<SectionType: DataSourceSectionType>: NSObject,
UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	open var data = DataSource<SectionType>()
	
	// MARK: UICollectionViewDataSource
	
	open var configureCell: ((CollectionDelegate, UICollectionView, IndexPath, _ item: SectionType.Item?)->UICollectionViewCell)?
	
	open var configureSupplementry: ((CollectionDelegate, UICollectionView, _ kind: String, IndexPath, _ title: String)->UICollectionReusableView)?
	
	open var canMoveItem: ((CollectionDelegate, UICollectionView, IndexPath)->Bool)?
	
	open var moveItem: ((CollectionDelegate, UICollectionView, _ from: IndexPath, _ to: IndexPath)->Void)?
	
	// MARK: UICollectionViewDelegate
	
	open var shouldHighlightItem: ((CollectionDelegate, UICollectionView, IndexPath)->Bool)?
	
	open var didHighlightItem: ((CollectionDelegate, UICollectionView, IndexPath)->Void)?
	
	open var didUnhighlightItem: ((CollectionDelegate, UICollectionView, IndexPath)->Void)?
	
	open var shouldSelectItem: ((CollectionDelegate, UICollectionView, IndexPath)->Bool)?
	
	open var shouldDeselectItem: ((CollectionDelegate, UICollectionView, IndexPath)->Bool)?
	
	open var didSelectItem: ((CollectionDelegate, UICollectionView, IndexPath)->Void)?
	
	open var didDeselectItem: ((CollectionDelegate, UICollectionView, IndexPath)->Void)?
	
	open var willDisplayCell: ((CollectionDelegate, UICollectionView, UICollectionViewCell, IndexPath)->Void)?
	
	open var willDisplaySupplementaryView: ((CollectionDelegate, UICollectionView, UICollectionReusableView, _ kind: String, IndexPath)->Void)?
	
	open var didEndDisplayingCell: ((CollectionDelegate, UICollectionView, UICollectionViewCell, IndexPath)->Void)?
	
	open var didEndDisplayingSupplementaryView: ((CollectionDelegate, UICollectionView, UICollectionReusableView, _ kind: String, IndexPath)->Void)?
	
	open var shouldShowMenuForItem: ((CollectionDelegate, UICollectionView, IndexPath )->Bool)?
	
	open var canPerformAction: ((CollectionDelegate, UICollectionView, IndexPath, _ action: Selector, _ sender: Any?)->Bool)?
	
	open var performAction: ((CollectionDelegate, UICollectionView, IndexPath, _ action: Selector, _ sender: Any?)->Void)?
	
	// MARK: UICollectionViewDelegateFlowLayout
	
	open var layoutItemSize: ((CollectionDelegate, UICollectionView, UICollectionViewLayout, IndexPath, SectionType.Item?)->CGSize)?
	
	open var layoutSupplementrySize: ((CollectionDelegate, UICollectionView, UICollectionViewLayout, _ kind: String, _ section: Int)->CGSize)?
	
	open var layoutSectionInset: ((CollectionDelegate, UICollectionView, UICollectionViewLayout, _ section: Int)->UIEdgeInsets)?
	
	open var layoutMinimumLineSpacing: ((CollectionDelegate, UICollectionView, UICollectionViewLayout, _ section: Int)->CGFloat)?
	
	open var layoutMinimumInteritemSpacing: ((CollectionDelegate, UICollectionView, UICollectionViewLayout, _ section: Int)->CGFloat)?
	
	public override init() {
		super.init()
	}
	
	open func delegate(_ collection: UICollectionView) {
		collection.dataSource = self
		collection.delegate = self
	}
	
	// MARK: UICollectionViewDataSource
	
	open func numberOfSections(in collectionView: UICollectionView) -> Int {
		data.sections.count
	}
	
	open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		section < data.sections.count ? data.sections[section].items.count : 0
	}
	
	open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		configureCell?(self, collectionView, indexPath, data.cell(at: indexPath))
			?? collectionView.dequeueReusableCell(withReuseIdentifier: data.cellReuseID,
			                                      for: indexPath)
	}
	
	open func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
		canMoveItem?(self, collectionView, indexPath) ?? false
	}
	
	open func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		moveItem?(self, collectionView,
		          sourceIndexPath, destinationIndexPath)
	}
	
	open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		configureSupplementry?(self, collectionView, kind, indexPath,
							   data.sections[indexPath.section].description)
			?? collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath)
	}
	
	// MARK: UICollectionViewDelegate
	
	open func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
		shouldHighlightItem?(self, collectionView, indexPath)
			?? true
	}
	
	open func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
		didHighlightItem?(self, collectionView, indexPath)
	}
	
	open func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
		didUnhighlightItem?(self, collectionView, indexPath)
	}
	
	open func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		shouldSelectItem?(self, collectionView, indexPath)
			?? true
	}
	
	// called when the user taps on an already-selected item in multi-select mode
	open func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
		shouldDeselectItem?(self, collectionView, indexPath)
			?? true
	}
	
	open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		didSelectItem?(self, collectionView, indexPath)
	}
	
	open func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		didDeselectItem?(self, collectionView, indexPath)
	}
	
	open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		willDisplayCell?(self, collectionView, cell, indexPath)
	}
	
	open func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
		willDisplaySupplementaryView?(self, collectionView, view, elementKind, indexPath)
	}
	
	open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		didEndDisplayingCell?(self, collectionView, cell, indexPath)
	}
	
	open func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
		didEndDisplayingSupplementaryView?(self, collectionView, view, elementKind, indexPath)
	}
	
	// These methods provide support for copy/paste actions on cells.
	// All three should be implemented if any are.
	open func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
		shouldShowMenuForItem?(self, collectionView, indexPath)
			?? false
	}
	
	open func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
		canPerformAction?(self, collectionView, indexPath, action, sender)
			?? false
	}
	
	open func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
		performAction?(self, collectionView, indexPath, action, sender)
	}
	
	// MARK: UICollectionViewDelegateFlowLayout
	
	open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		layoutItemSize?(self, collectionView, collectionViewLayout, indexPath, data.cell(at: indexPath))
			?? (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize
			?? .zero
	}
	
	open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		layoutSectionInset?(self, collectionView, collectionViewLayout, section)
			?? UIEdgeInsets()
	}
	
	open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		layoutMinimumLineSpacing?(self, collectionView, collectionViewLayout, section)
			?? (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing
			?? 0
	}
	
	open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		layoutMinimumInteritemSpacing?(self, collectionView, collectionViewLayout, section)
			?? (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing
			?? 0
	}
	
	open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		layoutSupplementrySize?(self, collectionView, collectionViewLayout, UICollectionView.elementKindSectionHeader, section)
			?? .zero
	}
	
	open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
		layoutSupplementrySize?(self, collectionView, collectionViewLayout, UICollectionView.elementKindSectionFooter, section)
			?? .zero
	}
}
#endif
