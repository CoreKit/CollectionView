//
//  CollectionView.swift
//  CollectionView
//
//  Created by Tibor Bödecs on 2019. 04. 25..
//

import Foundation
import UIKit

open class CollectionView: UICollectionView {

    open var source: Source? = nil {
        didSet {
            self.source?.register(itemsFor: self)

            self.dataSource = self.source
            self.delegate = self.source
        }
    }
}
