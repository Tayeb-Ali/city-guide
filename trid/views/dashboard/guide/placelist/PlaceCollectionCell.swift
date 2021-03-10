//
//  PlaceCollectionCell.swift
//  trid
//
//  Created by Black on 2/14/17.
//  Copyright © 2017 Black. All rights reserved.
//

import UIKit

class PlaceCollectionCell: UICollectionViewCell {
    
    static let className = "PlaceCollectionCell"
    
    @IBOutlet weak var imgIntro: UIImageView!
    
    @IBOutlet weak var viewGradientBody: GradientLayer!
    
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var constraintPriceWidth: NSLayoutConstraint!
    
    @IBOutlet weak var labelDistance: UILabel!
    @IBOutlet weak var constraintNameTrailing: NSLayoutConstraint!
    
    @IBOutlet weak var constraintPriceHeight: NSLayoutConstraint!
    
    // Info
    @IBOutlet weak var viewInfo: UIView!
    @IBOutlet weak var constraintInfoWidth: NSLayoutConstraint!
    @IBOutlet weak var viewTourInfo: UIView!
    @IBOutlet weak var labelTourDuration: UILabel!
    @IBOutlet weak var labelTourSize: UILabel!
    
    @IBOutlet weak var viewTimeInfo: UIView!
    @IBOutlet weak var labelTime: UILabel!
    
    // Review
    @IBOutlet weak var viewReview: UIView!
    @IBOutlet weak var btnLove: CountButton!
    @IBOutlet weak var btnReviewCount: CountButton!
    @IBOutlet weak var constraintLoveWidth: NSLayoutConstraint!
    
    // Favorited
    @IBOutlet weak var btnFavorite: UIButton!
    
    
    // Variables
    var categoryType : FCategoryType?
    var place: FPlace?
    var parentViewController: UIViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
        btnLove.makeSmall()
        btnReviewCount.makeSmall()
    }
    
    public func makePlace(_ p: FPlace, categoryType type: FCategoryType?, parentController: UIViewController?, isSmall: Bool){
        parentViewController = parentController
        place = p
        categoryType = type
        
        // Photo
        let photos = p[FPlace.photos] as? [String]
        let photo = photos == nil ? "" : photos?[0]
        imgIntro.sd_setImage(with: URL(string: photo!), placeholderImage: UIImage(named: "img-default"))
        
        // If Banner -> Not display anything except image
        let banner = p.isBanner()
        viewGradientBody.isHidden = banner
        if banner {
            return
        }
        
        // Name
        labelName.text = p.getName()
        let nameFont = labelName.font
        labelName.font = UIFont(name: nameFont!.fontName, size: (isSmall ? 18 : 20))
        constraintNameTrailing.constant = isSmall ? 10: 70
        
        // Favorited
        btnFavorite.isSelected = AppState.checkFavorited(ofPlace: p)
        
        // Info
        constraintInfoWidth.constant = 0
        viewTourInfo.isHidden = true
        viewTimeInfo.isHidden = true
        if !isSmall {
            // Just show on full size
            if type == .Tours {
                viewTourInfo.isHidden = false
                labelTourDuration.text = p.getTourDuration()
                labelTourSize.text = p.getTourGroupSize()
                constraintInfoWidth.constant = 48.0 + (labelTourDuration.text?.widthWithConstrainedHeight(height: 15, font: labelTourDuration.font!))! + (labelTourSize.text?.widthWithConstrainedHeight(height: 15, font: labelTourSize.font!))!
            }
            else if type != .Sleep { // Sleep thì ko cần hiện time
                let openTime = p.getOpeningTime()
                if (openTime ?? "") != "" {
                    viewTimeInfo.isHidden = false
                    labelTime.text = p.getOpeningTime()
                    constraintInfoWidth.constant = 25.0 + (labelTime.text?.widthWithConstrainedHeight(height: 15, font: labelTime.font!))!
                }
            }
        }
        
        // Love & review
        let loved = Utils.formatNumber((p.getLovedCount()))
        btnLove.text = loved
        constraintLoveWidth.constant = 19 + loved.widthWithConstrainedHeight(height: 20, font: (btnLove.label?.font)!)
        btnLove.isSelected = p.checkLoved()
        
        let count = p.getCommentCount()
        let review = String(count) // + " " + (count > 1 ? Localized.reviews : Localized.review)
        btnReviewCount.text = review
        
        // Price
        let price = p.getPriceString(categoryType: type, short: true)
        labelPrice.text = price
        constraintPriceWidth.constant = price.widthWithConstrainedHeight(height: 30, font: labelPrice.font) + 5
        constraintPriceHeight.constant = isSmall ? 30 : 40
        labelPrice.font = UIFont(name: (isSmall ? AppSetting.Font.roboto_medium : AppSetting.Font.roboto_light), size: (isSmall ? 14 : 24))
        
        // Register Notification
        NotificationCenter.default.removeObserver(self)
        if p.objectId != nil {
            NotificationCenter.default.addObserver(self, selector: #selector(handleFavoriteAdded), name: NotificationKey.favoriteAdded(p.objectId!), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleFavoriteDeleted), name: NotificationKey.favoriteDeleted(p.objectId!), object: nil)
        }
        
        // Distance
        let long = p.getLongitute()
        let lat = p.getLatitude()
        if long != 0 && lat != 0 {
            labelDistance.text = Le2Location.getDistanceFrom(long: long, lat: lat)
        }
    }
    
    // MARK: - Handle Notification
    @objc func handleFavoriteAdded(notification: Notification){
        btnFavorite.isSelected = true
    }
    
    @objc func handleFavoriteDeleted(notification: Notification){
        btnFavorite.isSelected = false
    }
    
    // MARK: - Actions
    
    @IBAction func actionLove(_ sender: Any) {
        if place == nil || parentViewController == nil {
            return
        }
        if place!.checkLoved() {
            place!.removeLoved()
        }
        else{
            Utils.viewController(parentViewController!, isSignUp: false, checkLoginWithCallback: {
                self.place!.addLoved()
            })
        }
    }
    
    @IBAction func actionFavorite(_ sender: Any) {
        if place == nil || place?.objectId == nil {
            return
        }
        if btnFavorite.isSelected {
            // Remove
            AppState.removeFavorited(place: place!, finish: {
                self.makeToast(Localized.Removed)
            })
        }
        else{
            // Add
            AppState.addFavorite(place: place!, finish: {
                self.makeToast(Localized.Saved)
            })
        }
    }
    
    
    static func size() -> CGSize {
        let size = AppSetting.App.screenSize
        return CGSize(width: size.width, height: PlaceCell.cellHeight())
    }
}
