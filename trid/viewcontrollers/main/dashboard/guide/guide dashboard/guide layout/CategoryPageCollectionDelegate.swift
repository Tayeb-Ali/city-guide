//
//  CategoryPageCollectionDelegate.swift
//  trid
//
//  Created by Black on 10/11/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit

protocol CategoryPageCollectionProtocol {
    func categoryPageCollectionSelectedAt(index: Int, ofPage page: Int)
}

class CategoryPageCollectionDelegate: NSObject, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // delegate
    var delegate : CategoryPageCollectionProtocol?
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("cell no: \((indexPath as NSIndexPath).row) of collection view: \(collectionView.tag)")
        delegate?.categoryPageCollectionSelectedAt(index: indexPath.row, ofPage: collectionView.tag)
    }
    
    // category collectionview
    fileprivate let sectionInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 10.0, right: 20.0)
    fileprivate let itempadding = CGFloat(7.0)
    fileprivate let itemsPerRow: CGFloat = 3
    
    // UICollectionViewDelegateFlowLayout
    //1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let paddingSpace = sectionInsets.left + sectionInsets.right
        let availableWidth : CGFloat = AppSetting.App.screenSize.width - paddingSpace - (itemsPerRow - 1) * itempadding
        let widthPerItem : CGFloat = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return itempadding
    }
    
}
