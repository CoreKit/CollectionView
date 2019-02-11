//
//  CollectionViewSection.swift
//  CVVM
//
//  Created by Tibor Bödecs on 2018. 04. 11..
//  Copyright © 2018. Tibor Bödecs. All rights reserved.
//

import UIKit

public typealias CollectionViewCallback = (Any, IndexPath) -> Void

open class CollectionViewSection {
    
    public var grid: Grid?
    public var header: CollectionViewViewModelProtocol?
    public var footer: CollectionViewViewModelProtocol?
    public var items: [CollectionViewViewModelProtocol]
    public var callback: CollectionViewCallback?
    
    public init(grid: Grid? = nil,
                header: CollectionViewViewModelProtocol? = nil,
                footer: CollectionViewViewModelProtocol? = nil,
                items: [CollectionViewViewModelProtocol] = [],
                callback: CollectionViewCallback? = nil) {
        self.grid = grid
        self.header = header
        self.footer = footer
        self.items = items
        self.callback = callback
    }
    
    public func add(_ item: CollectionViewViewModelProtocol) {
        self.items.append(item)
    }
}
