//
//  UIView+Id.swift
//  CollectionView
//
//  Created by Tibor Bödecs on 2019. 04. 25..
//

import Foundation
import UIKit

extension UIView {
    
    var id: String? {
        get {
            return self.accessibilityIdentifier
        }
        set {
            self.accessibilityIdentifier = newValue
        }
    }
    
    func view(withId id: String) -> UIView? {
        if self.id == id {
            return self
        }
        for view in self.subviews {
            if let view = view.view(withId: id) {
                return view
            }
        }
        return nil
    }
}

extension Array {
    
    func element(at index: Int) -> Element? {
        return index < self.count && index >= 0 ? self[index] : nil
    }
}

extension CGFloat {
    
    var evenRounded: CGFloat {
        var newValue = self.rounded(.towardZero)
        if newValue.truncatingRemainder(dividingBy: 2) == 1 {
            newValue -= 1
        }
        return newValue
    }
}

extension UICollectionViewCell {
    
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
