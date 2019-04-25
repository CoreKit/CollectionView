//
//  CollectionViewViewModel.swift
//  CVVM
//
//  Created by Tibor Bödecs on 2018. 04. 11..
//  Copyright © 2018. Tibor Bödecs. All rights reserved.
//

import UIKit

public protocol ViewModelProtocol {

    var id: String { get }
    var cell: Cell.Type { get }
    
    func config(cell: Cell, collectionView: CollectionView, indexPath: IndexPath, grid: Grid)
    func size(collectionView: CollectionView, grid: Grid) -> CGSize
    func callback(indexPath: IndexPath)
}

open class ViewModel<View, Model>: ViewModelProtocol where View: Cell, Model: Any {

    public typealias ViewModelHandler = ((ViewModel<View, Model>) -> Void)

    public var explicitId: String?
    public var model: Model
    public var cell: Cell.Type { return View.self }
    public var value: Any { return self.model }

    public weak var view: View?
    public weak var collectionView: CollectionView!
    public var indexPath: IndexPath!
    
    public var selectionHandler: ViewModelHandler?
    
    open var height: CGFloat {
        return 44
    }

    public var id: String {
        if let id = self.explicitId {
            return id
        }
        return "\(self.indexPath.section)/\(self.indexPath.item)"
    }

    // MARK: - init

    public init(id explicitId: String? = nil, _ data: Model) {
        self.explicitId = explicitId
        self.model = data
        self.initialize()
    }
    
    open func initialize() {
        
    }
    
    // MARK: - CollectionViewViewModelProtocol
    
    public func config(cell: Cell, collectionView: CollectionView, indexPath: IndexPath, grid: Grid) {
        self.collectionView = collectionView
        self.indexPath = indexPath
        self.view = (cell as! View)
        
        self.updateView()
    }

    public func size(collectionView: CollectionView, grid: Grid) -> CGSize {
        self.collectionView = collectionView
        return self.size(grid: grid)
    }
    
    public func callback(indexPath: IndexPath) {
        self.selectionHandler?(self)
    }
    
    // MARK: - API methods
    
    open func updateView() {
        
    }

    open func size(grid: Grid) -> CGSize {
        return grid.size(for: self.collectionView, height: self.height, items: grid.columns, gaps: grid.columns - 1)
    }

    open func onSelect(_ handler: @escaping ViewModelHandler) -> Self {
        self.selectionHandler = handler
        return self
    }

    public func by<T, U>(id: String) -> ViewModel<T, U>? {
        return self.collectionView?.source?.by(id: id)
    }
}
