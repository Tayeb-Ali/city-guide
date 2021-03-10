//
//  PlaceCell.swift
//  trid
//
//  Created by Black on 10/3/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import SDWebImage

class PlaceCell: UITableViewCell {
    
    static let className = "PlaceCell"
    
    @IBOutlet weak var imgIntro: UIImageView!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var constraintPriceWidth: NSLayoutConstraint!
    
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
    
    // Favorite
    @IBOutlet weak var btnFavorite: UIButton!
    @IBOutlet weak var labelDistance: UILabel!
    
    // Variables
    var categoryType : FCategoryType?
    var place: FPlace?
    var parentViewController: UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnLove.makeSmall()
        btnReviewCount.makeSmall()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func makePlace(_ p: FPlace, categoryType type: FCategoryType?, parentController: UIViewController?){
        parentViewController = parentController
        place = p
        categoryType = type
        
        // NAME
        labelName.text = p.getName()
        
        // Favorited
        btnFavorite.isSelected = AppState.checkFavorited(ofPlace: p)
        
        // Info
        constraintInfoWidth.constant = 0
        viewTourInfo.isHidden = true
        viewTimeInfo.isHidden = true
        if type == .Tours {
            viewTourInfo.isHidden = false
            labelTourDuration.text = p.getTourDuration()
            labelTourSize.text = p.getTourGroupSize()
            constraintInfoWidth.constant = 48.0 + (labelTourDuration.text?.widthWithConstrainedHeight(height: 15, font: labelTourDuration.font!))! + (labelTourSize.text?.widthWithConstrainedHeight(height: 15, font: labelTourSize.font!))!
        }
        else {
            let openTime = p.getOpeningTime()
            if openTime != nil {
                viewTimeInfo.isHidden = false
                labelTime.text = p.getOpeningTime()
                constraintInfoWidth.constant = 25.0 + (labelTime.text?.widthWithConstrainedHeight(height: 15, font: labelTime.font!))!
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
        
        // photo
        let photos = p[FPlace.photos] as? [String]
        let photo = photos == nil ? "" : photos?[0]
        imgIntro.sd_setImage(with: URL(string: photo!), placeholderImage: UIImage(named: "img-default"))
        
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
    
    static func cellHeight() -> CGFloat {
        return 200
    }
    
}
