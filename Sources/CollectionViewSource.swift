//
//  CollectionViewSource.swift
//  CVVM
//
//  Created by Tibor Bödecs on 2018. 04. 11..
//  Copyright © 2018. Tibor Bödecs. All rights reserved.
//

import UIKit

public extension Array {
    
    public func element(at index: Int) -> Element? {
        return index < self.count && index >= 0 ? self[index] : nil
    }
}

open class CollectionViewSource: NSObject {
    
    private var indexPathSelected = false
    
    open var grid: Grid
    open var sections: [CollectionViewSection]
    open var callback: CollectionViewCallback?
    
    public init(grid: Grid = Grid(),
                sections: [CollectionViewSection] = [],
                callback: CollectionViewCallback? = nil) {
        
        self.grid = grid
        self.sections = sections
        self.callback = callback
        
        super.init()
    }
    
    public func add(_ section: CollectionViewSection) {
        self.sections.append(section)
    }

    // MARK: - section indexes
    
    public var sectionIndexes: IndexSet? {
        if self.sections.isEmpty {
            return nil
        }
        if self.sections.count == 1 {
            return IndexSet(integer: 0)
        }
        return IndexSet(integersIn: 0..<self.sections.count - 1)
    }
    
    // MARK: - item helpers
    
    public func itemAt(_ section: Int) -> CollectionViewSection? {
        return self.sections.element(at: section)
    }
    
    public func itemAt(_ indexPath: IndexPath) -> CollectionViewViewModelProtocol? {
        return self.itemAt(indexPath.section)?.items.element(at: indexPath.item)
    }

    // MARK: - view registration
    
    public func register(itemsFor collectionView: UICollectionView) {
        
        for section in self.sections {
            section.header?.cell.register(itemFor: collectionView, kind: UICollectionView.elementKindSectionHeader)
            section.footer?.cell.register(itemFor: collectionView, kind: UICollectionView.elementKindSectionFooter)
            
            for cell in section.items.map({ $0.cell }) {
                cell.register(itemFor: collectionView)
            }
        }
    }
}

extension CollectionViewSource: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.sections.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.itemAt(section)?.items.count ?? 0
    }
    
    private func collectionView(_ collectionView: UICollectionView,
                                itemForIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let data = self.itemAt(indexPath),
            let item = data.cell.reuse(collectionView, indexPath: indexPath) as? CollectionViewCell
        else {
            return CollectionViewCell.reuse(collectionView, indexPath: indexPath)
        }
        data.config(cell: item, data: data.value, indexPath: indexPath, grid: self.grid(indexPath.section))
        return item
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.collectionView(collectionView, itemForIndexPath: indexPath)
    }
   
    
    private func _collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView
    {
        let grid = self.grid(indexPath.section)
        let section = self.itemAt(indexPath.section)
        
        if kind == UICollectionView.elementKindSectionHeader {
            guard
                let section = section,
                let data = section.header,
                let cell = data.cell.reuse(collectionView,
                                           indexPath: indexPath,
                                           kind: UICollectionView.elementKindSectionHeader) as? CollectionViewCell
            else {
                return CollectionViewCell.reuse(collectionView, indexPath: indexPath)
            }
            data.config(cell: cell, data: data.value, indexPath: indexPath, grid: grid)
            return cell
        }
        
        if kind == UICollectionView.elementKindSectionFooter {
            guard
                let section = section,
                let data = section.footer,
                let cell = data.cell.reuse(collectionView,
                                           indexPath: indexPath,
                                           kind: UICollectionView.elementKindSectionFooter) as? CollectionViewCell
            else {
                return CollectionViewCell.reuse(collectionView, indexPath: indexPath)
            }
            data.config(cell: cell, data: data.value, indexPath: indexPath, grid: grid)
            return cell
        }

        return CollectionViewCell.reuse(collectionView,
                                        indexPath: indexPath,
                                        kind: UICollectionView.elementKindSectionHeader)
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               viewForSupplementaryElementOfKind kind: String,
                               at indexPath: IndexPath) -> UICollectionReusableView {
        return self._collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
   
    public func collectionView(_ collectionView: UICollectionView,
                               canMoveItemAt indexPath: IndexPath) -> Bool
    {
        return false
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               moveItemAt sourceIndexPath: IndexPath,
                               to destinationIndexPath: IndexPath) {
        
    }
}

extension CollectionViewSource: UICollectionViewDelegate {
    
    func selectItem(at indexPath: IndexPath) {
        guard let data = self.itemAt(indexPath), !self.indexPathSelected else {
            return
        }
        
        //source
        self.callback?(data.value, indexPath)
        //section
        self.itemAt(indexPath.section)?.callback?(data.value, indexPath)
        //view-model
        data.callback(data: data.value, indexPath: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               didSelectItemAt indexPath: IndexPath) {
        self.selectItem(at: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               willDisplay cell: UICollectionViewCell,
                               forItemAt indexPath: IndexPath) {

    }
}

extension CollectionViewSource: UICollectionViewDelegateFlowLayout {
    
    func grid(_ section: Int) -> Grid {
        return self.itemAt(section)?.grid ?? self.grid
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let data = self.itemAt(indexPath) else {
            return .zero
        }
        let grid = self.grid(indexPath.section)
        
        return data.size(data: data.value, indexPath: indexPath, grid: grid, view: collectionView)
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAt section: Int) -> UIEdgeInsets {
        return self.grid(section).margin
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.grid(section).verticalPadding
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return self.grid(section).horizontalPadding
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let data = self.itemAt(section)?.header else {
            return .zero
        }
        let indexPath = IndexPath(item: -1, section: section)
        let grid = self.grid(section)
        return data.size(data: data.value, indexPath: indexPath, grid: grid, view: collectionView)
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let data = self.itemAt(section)?.footer else {
            return .zero
        }
        let indexPath = IndexPath(item: -1, section: section)
        let grid = self.grid(section)
        return data.size(data: data.value, indexPath: indexPath, grid: grid, view: collectionView)
    }
}
