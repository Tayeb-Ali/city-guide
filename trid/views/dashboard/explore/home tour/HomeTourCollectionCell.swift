//
//  HomeTourCollectionCell.swift
//  trid
//
//  Created by Black on 2/20/17.
//  Copyright © 2017 Black. All rights reserved.
//

import UIKit

class HomeTourCollectionCell: UICollectionViewCell {

    static let className = "HomeTourCollectionCell"
    
    @IBOutlet weak var btnFavorite: UIButton!
    @IBOutlet weak var imgIntro: UIImageView!
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelTourDuration: UILabel!
    @IBOutlet weak var labelTourAmount: UILabel!
    
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var constraintPriceWidth: NSLayoutConstraint!
    
    // Variables
    var tour : FPlace?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func fill(_ place: FPlace){
        tour = place
        // Name
        labelName.text = place[FPlace.name] as? String ?? ""
        
        // Favorited
        btnFavorite.isSelected = AppState.checkFavorited(ofPlace: place)
        
        // price
        let price = place.getPriceString(categoryType: .Tours, short: true)
        labelPrice.text = price
        constraintPriceWidth.constant = price.widthWithConstrainedHeight(height: 30, font: labelPrice.font) + 5
        
        // photo
        let photos = place[FPlace.photos] as? [String]
        let photo = photos == nil ? "" : photos?[0]
        imgIntro.sd_setImage(with: URL(string: photo!))
        
        // Tour
        labelTourDuration.text = place.getTourDuration()
        labelTourAmount.text = place.getTourGroupSize()
        
        // Register Notification
        NotificationCenter.default.removeObserver(self)
        if place.objectId != nil {
            NotificationCenter.default.addObserver(self, selector: #selector(handleFavoriteAdded), name: NotificationKey.favoriteAdded(place.objectId!), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleFavoriteDeleted), name: NotificationKey.favoriteDeleted(place.objectId!), object: nil)
        }
    }
    
    // MARK: - Handle Notification
    @objc func handleFavoriteAdded(notification: Notification){
        btnFavorite.isSelected = true
    }
    
    @objc func handleFavoriteDeleted(notification: Notification){
        btnFavorite.isSelected = false
    }
    
    // MARK: - ACtion
    @IBAction func actionFavorite(_ sender: Any) {
        if tour == nil || tour?.objectId == nil {
            return
        }
        if btnFavorite.isSelected {
            // Remove
            AppState.removeFavorited(place: tour!, finish: {
                self.makeToast(Localized.Removed)
            })
        }
        else{
            // Add
            AppState.addFavorite(place: tour!, finish: {
                self.makeToast(Localized.Saved)
            })
        }
    }
    
    // MARK: - Static
    
    static func size() -> CGSize {
        let size = AppSetting.App.screenSize
        return CGSize(width: size.width, height: size.width/2 - 1)
    }
    
    static func sizeSmall(height: CGFloat) -> CGSize {
        return CGSize(width: 240, height: height)
    }

}
