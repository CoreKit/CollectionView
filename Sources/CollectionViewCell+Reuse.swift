//
//  CollectionViewCell+Reuse.swift
//  CVVM
//
//  Created by Tibor Bödecs on 2018. 04. 11..
//  Copyright © 2018. Tibor Bödecs. All rights reserved.
//

import UIKit

public extension UICollectionViewCell {

    static var uniqueIdentifier: String {
        return String(describing: self)
    }
    
    var uniqueIdentifier: String {
        return type(of: self).uniqueIdentifier
    }
    
    static var hasNib: Bool {
        return Bundle.main.path(forResource: self.uniqueIdentifier, ofType: "nib") != nil
    }
    
    static var nib: UINib {
        return UINib(nibName: self.uniqueIdentifier, bundle: nil)
    }
    
    // MARK: - cells
    
    static func register(nibFor collectionView: UICollectionView) {
        collectionView.register(self.nib, forCellWithReuseIdentifier: self.uniqueIdentifier)
    }
    
    static func register(classFor collectionView: UICollectionView) {
        collectionView.register(self, forCellWithReuseIdentifier: self.uniqueIdentifier)
    }

    static func register(itemFor collectionView: UICollectionView) {
        if self.hasNib {
            return self.register(nibFor: collectionView)
        }
        self.register(classFor: collectionView)
    }
    
    static func reuse(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: self.uniqueIdentifier, for: indexPath)
    }

    // MARK: - supplementary views

    static func register(nibFor collectionView: UICollectionView, kind: String) {
        collectionView.register(self.nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: self.uniqueIdentifier)
    }

    static func register(classFor collectionView: UICollectionView, kind: String) {
        collectionView.register(self, forSupplementaryViewOfKind: kind, withReuseIdentifier: self.uniqueIdentifier)
    }

    static func register(itemFor collectionView: UICollectionView, kind: String) {
        if self.hasNib {
            return self.register(nibFor: collectionView, kind: kind)
        }
        self.register(classFor: collectionView, kind: kind)
    }

    static func reuse(_ collectionView: UICollectionView, indexPath: IndexPath, kind: String) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: self.uniqueIdentifier, for: indexPath)
    }
}
