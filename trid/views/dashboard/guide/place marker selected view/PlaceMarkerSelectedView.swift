//
//  PlaceMarkerSelectedView.swift
//  trid
//
//  Created by Black on 10/17/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit

protocol PlaceMarkerSelectedViewProtocol {
    func markerSelectedViewTouched(view: PlaceMarkerSelectedView)
}

class PlaceMarkerSelectedView: UIView {
    
    static let className = "PlaceMarkerSelectedView"
    
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var ratingview: SpotRating!
    @IBOutlet weak var starview: HotelStar!
    
    @IBOutlet weak var constraintStarTrailing: NSLayoutConstraint!
    @IBOutlet weak var constraintPriceWidth: NSLayoutConstraint!
    
    var delegate : PlaceMarkerSelectedViewProtocol?
    var categoryType: FCategoryType?
    var place: FPlace?
    
    
    override func awakeFromNib() {
        setup()
    }
    
    func setup(){
        imageview.layer.cornerRadius = 50/2
    }
    
    public func makePlace(place p: FPlace, categoryType type: FCategoryType?) {
        place = p
        categoryType = type
        // photo
        let photos = p[FPlace.photos] as? Array<String>
        if photos != nil && (photos?.count)! > 0 {
            imageview.sd_setImage(with: URL(string: (photos?[0])!), placeholderImage: UIImage(named: "img-default"))
        }
        // name
        let name = p[FPlace.name] as? String
        labelName.text = name
        // address -> show price
        labelAddress.text = p.getAddress()
        // price
        let price = p.getPriceString(categoryType: categoryType)
        labelPrice.text = price
        constraintPriceWidth.constant = price.widthWithConstrainedHeight(height: 20, font: labelPrice.font) + 5.0
        // star & rate
        ratingview.isHidden = true
        constraintStarTrailing.constant = 10
        let star = (p[FPlace.starlevel] as? String) ?? ""
        if star == "" {
            starview.isHidden = true
        }
        else{
            starview.isHidden = false
            starview.makeStar(level: star)
        }
    }
    
    public func makeEmpty(){
        imageview.image = UIImage(named: "")
        labelName.text = ""
        labelAddress.text = ""
        labelPrice.text = ""
        labelPrice.attributedText = NSAttributedString(string: "")
    }

    @IBAction func actionShowDetail(_ sender: AnyObject) {
        if delegate != nil {
            delegate?.markerSelectedViewTouched(view: self)
        }
    }
}
