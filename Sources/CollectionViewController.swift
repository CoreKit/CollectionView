//
//  CollectionViewController.swift
//  CVVM
//
//  Created by Tibor Bödecs on 2018. 04. 11..
//  Copyright © 2018. Tibor Bödecs. All rights reserved.
//

import UIKit

open class CollectionViewController: UIViewController {

    @IBOutlet open weak var collectionView: CollectionView!
    
    // MARK: - init

    public init() {
        super.init(nibName: nil, bundle: nil)
        
        self.initialize()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initialize()
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.initialize()
    }
    
    open func initialize() {
        // do nothing...
    }
    
    open func layoutConstraints() -> [NSLayoutConstraint] {
        return [
            self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
        ]
    }

    // MARK: - view controller
    
    open override func loadView() {
        super.loadView()
        
        let collectionView = CollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView = collectionView
        self.view.addSubview(self.collectionView)
        NSLayoutConstraint.activate(self.layoutConstraints())
    }
    
     open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white

        self.collectionView.backgroundColor = .clear
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.showsVerticalScrollIndicator = true
    }

    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        if self.isViewLoaded && self.view.window == nil {
            //self.collectionView = nil
        }
    }
    
    // MARK: - handle autorotation
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard
            let previousTraitCollection = previousTraitCollection,
            self.traitCollection.verticalSizeClass != previousTraitCollection.verticalSizeClass ||
            self.traitCollection.horizontalSizeClass != previousTraitCollection.horizontalSizeClass
        else {
            return
        }
        
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.collectionView.reloadData()
    }
    
    open override func viewWillTransition(to size: CGSize,
                                          with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.collectionView.bounds.size = size
        
        coordinator.animate(alongsideTransition: { context in
            context.viewController(forKey: UITransitionContextViewControllerKey.from)
            
        }, completion: { [weak self] _ in
            self?.collectionView.collectionViewLayout.invalidateLayout()
        })
    }
}

