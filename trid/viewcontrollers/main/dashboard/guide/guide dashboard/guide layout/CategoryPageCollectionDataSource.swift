//
//  CategoryPageCollectionDataSource.swift
//  trid
//
//  Created by Black on 10/11/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CategoryPageCollectionDataSource : NSObject, UICollectionViewDataSource {
    
    var data : [FCategory]!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.className, for: indexPath) as! CategoryCell
        let cat = data[indexPath.row]
        cell.makeName(cat.getName(), type: cat.getType())
        return cell
    }
    
}
