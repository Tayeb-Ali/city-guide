//
//  CategoryPageCell.swift
//  trid
//
//  Created by Black on 10/11/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit

class CategoryPageCell: UICollectionViewCell {

    // static
    static let className = "CategoryPageCell"
    
    // outlet
    @IBOutlet weak var collectionCategory: UICollectionView!
    
    // variables
    var collectionViewDataSource : UICollectionViewDataSource!
    var collectionViewDelegate : UICollectionViewDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func initializeCollectionViewWithDataSource<D: UICollectionViewDataSource,E: UICollectionViewDelegate>(_ dataSource: D, delegate :E, forRow row: Int) {
        // delegate & data-source
        self.collectionViewDataSource = dataSource
        self.collectionViewDelegate = delegate as UICollectionViewDelegate
        // register cell
        collectionCategory.register(UINib(nibName: CategoryCell.className, bundle: nil), forCellWithReuseIdentifier: CategoryCell.className)
        collectionCategory.dataSource = self.collectionViewDataSource
        collectionCategory.delegate = self.collectionViewDelegate
        collectionCategory.tag = row
        collectionCategory.reloadData()
    }


}
