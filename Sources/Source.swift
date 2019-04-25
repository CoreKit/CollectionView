//
//  CollectionViewSource.swift
//  CVVM
//
//  Created by Tibor Bödecs on 2018. 04. 11..
//  Copyright © 2018. Tibor Bödecs. All rights reserved.
//

import UIKit



open class Source: NSObject {
    
    private var indexPathSelected = false
    
    open var grid: Grid
    open var sections: [Section]
    
    public init(grid: Grid = Grid(), sections: [Section] = []) {
        self.grid = grid
        self.sections = sections
        
        super.init()
    }
    
    public convenience init(grid: Grid = Grid(), _ sections: [[ViewModelProtocol]]) {
        let sections = sections.map { items in
            return Section(grid: grid, header: nil, footer: nil, items: items)
        }
        self.init(grid: grid, sections: sections)
    }

    // MARK: - helpers
    
    public func add(_ section: Section) {
        self.sections.append(section)
    }
    
    public func by<T, U>(id: String) -> ViewModel<T, U>? {
        for section in self.sections {
            if let viewModel: ViewModel<T, U> = section.by(id: id) {
                return viewModel
            }
        }
        return nil
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
    
    public func itemAt(_ section: Int) -> Section? {
        return self.sections.element(at: section)
    }
    
    public func itemAt(_ indexPath: IndexPath) -> ViewModelProtocol? {
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

extension Source: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.sections.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.itemAt(section)?.items.count ?? 0
    }
    
    private func collectionView(_ collectionView: UICollectionView,
                                itemForIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let view = collectionView as? CollectionView,
            let viewModel = self.itemAt(indexPath),
            let cell = viewModel.cell.reuse(collectionView, indexPath: indexPath) as? Cell
        else {
            return Cell.reuse(collectionView, indexPath: indexPath)
        }
        viewModel.config(cell: cell, collectionView: view, indexPath: indexPath, grid: self.grid(indexPath.section))
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.collectionView(collectionView, itemForIndexPath: indexPath)
    }
   
    
    private func _collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView
    {
        let section = self.itemAt(indexPath.section)
        var optionalViewModel: ViewModelProtocol?
        if kind == UICollectionView.elementKindSectionHeader {
            optionalViewModel = section?.header
        }
        if kind == UICollectionView.elementKindSectionFooter {
            optionalViewModel = section?.footer
        }

        guard
            let viewModel = optionalViewModel,
            let view = collectionView as? CollectionView,
            let cell = viewModel.cell.reuse(collectionView,
                                            indexPath: indexPath,
                                            kind: kind) as? Cell
        else {
            return Cell.reuse(collectionView, indexPath: indexPath)
        }
        viewModel.config(cell: cell, collectionView: view, indexPath: indexPath, grid: self.grid(indexPath.section))
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView,
                               viewForSupplementaryElementOfKind kind: String,
                               at indexPath: IndexPath) -> UICollectionReusableView {
        return self._collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
}

extension Source: UICollectionViewDelegate {
    
    func selectItem(at indexPath: IndexPath) {
        guard !self.indexPathSelected else {
            return
        }
        self.itemAt(indexPath)?.callback(indexPath: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               didSelectItemAt indexPath: IndexPath) {
        self.selectItem(at: indexPath)
    }
}

extension Source: UICollectionViewDelegateFlowLayout {
    
    func grid(_ section: Int) -> Grid {
        return self.itemAt(section)?.grid ?? self.grid
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let viewModel = self.itemAt(indexPath) else {
            return .zero
        }
        return viewModel.size(collectionView: collectionView as! CollectionView, grid: self.grid(indexPath.section))
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
        guard let viewModel = self.itemAt(section)?.header else {
            return .zero
        }
        return viewModel.size(collectionView: collectionView as! CollectionView, grid: self.grid(section))
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let viewModel = self.itemAt(section)?.footer else {
            return .zero
        }
        return viewModel.size(collectionView: collectionView as! CollectionView, grid: self.grid(section))
    }
}
