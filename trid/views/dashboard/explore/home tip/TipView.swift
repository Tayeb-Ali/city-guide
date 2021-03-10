//
//  TipView.swift
//  trid
//
//  Created by Black on 2/23/17.
//  Copyright © 2017 Black. All rights reserved.
//

import UIKit

enum TipViewType {
    case Normal // Collection Cell
    case Small // Home Cell
    case Full // Detail
}

class TipView: UIView {
    // Outlet
    @IBOutlet weak var viewBody: UIView!
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelContent: UILabel!
    @IBOutlet weak var imgSeperator: UIImageView!
    @IBOutlet weak var constraintAvatarTop: NSLayoutConstraint!
    @IBOutlet weak var constraintAvatarLeading: NSLayoutConstraint!
    
    @IBOutlet weak var constraintContentTop: NSLayoutConstraint!
    @IBOutlet weak var constraintContentBottom: NSLayoutConstraint!
    
    // Love - Review
    @IBOutlet weak var viewReview: UIView!
    @IBOutlet weak var btnLove: CountButton!
    @IBOutlet weak var btnReview: CountButton!
    @IBOutlet weak var constraintLovedWith: NSLayoutConstraint!
    @IBOutlet weak var constraintReviewBottom: NSLayoutConstraint!
    
    // Under line
     @IBOutlet weak var imgUnderLine: UIImageView!
    var totalHeight : CGFloat = 0
    
    // Favorite
    @IBOutlet weak var btnFavorite: UIButton!
    
    
    // Variables
    var type : TipViewType? = nil
    var tip: FPlace?
    var parentViewController : UIViewController?
    
    class func makeTip(place: FPlace, parentController vc: UIViewController?, type t: TipViewType) -> TipView {
        let tip = UINib(nibName: "TipView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! TipView
        _ = tip.fill(place: place, parentController: vc, type: t)
        return tip
    }
    
    class func makeTip() -> TipView{
        let tip = UINib(nibName: "TipView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! TipView
        return tip
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewBody.layer.borderColor = UIColor(netHex: AppSetting.Color.veryLightGray).cgColor
        imgAvatar.layer.cornerRadius = imgAvatar.bounds.height/2.0
        imgAvatar.clipsToBounds = true
    }
    
    // Return Height of View
    func fill(place: FPlace, parentController vc: UIViewController?, type t: TipViewType) {
        // VC
        tip = place
        parentViewController = vc
        // UI
        setupUI(type: t)
        
        // Favorited
        btnFavorite.isSelected = AppState.checkFavorited(ofPlace: place)
        
        // Avatar & name
        let email = place.getTipEmail()
        let user = email != nil ? UserService.getUserWithEmail(email) : nil
        if user != nil {
            labelName.text = user?.getName()
            imgAvatar.sd_setImage(with: URL(string: user!.getAvatar()), placeholderImage: UIImage(named: "avatar-default"))
        }
        else{
            imgAvatar.image = UIImage(named: "avatar-default")
            labelName.text = ""
        }
        
        // Time
        labelTime.text = place.getDateTime().toDisplayString()
        
        // text
        let text = TipView.attributeTextFromContent(place.getTipContent() ?? "", type: type!)
        labelContent.attributedText = text
        
        // Love & review
        let loved = Utils.formatNumber((place.getLovedCount()))
        btnLove.text = loved
        constraintLovedWith.constant = (t == .Small ? 19 : 25) + loved.widthWithConstrainedHeight(height: 20, font: (btnLove.label?.font)!)
        btnLove.isSelected = place.checkLoved()
        
        let count = place.getCommentCount()
        let review = String(count) // + " " + (count > 1 ? Localized.reviews : Localized.review)
        btnReview.text = review
        
        // RETURN HEIGHT
        totalHeight = constraintAvatarTop.constant + imgAvatar.bounds.height + text.heightWith(width: AppSetting.App.screenSize.width - constraintAvatarLeading.constant - 20, font: TipView.attributeTextFont()) + constraintContentTop.constant + constraintContentBottom.constant + viewReview.bounds.height + constraintReviewBottom.constant
        
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
    
    // MARK: - Static
    
    static func attributeTextFont() -> UIFont {
        let size : CGFloat = AppSetting.FontSize.normal
        return UIFont(name: AppSetting.Font.roboto, size: size)!
    }
    
    static func attributeTextFromContent(_ content: String, type: TipViewType) -> NSAttributedString {
        let color = UIColor(netHex: AppSetting.Color.gray)
        let textFont = TipView.attributeTextFont()
        let textAttributes = [NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.font: textFont]
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = AppSetting.Text.lineSpacing
        paragraphStyle.paragraphSpacing = AppSetting.Text.paragraphSpacing
        paragraphStyle.lineBreakMode = type != .Small ? NSLineBreakMode.byWordWrapping : NSLineBreakMode.byTruncatingTail
        let text = NSMutableAttributedString()
        text.append(NSMutableAttributedString(string: content, attributes: textAttributes))
        text.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, text.length))
        return text
    }
    
    private func setupUI(type t: TipViewType) {
        if type != nil {
            return // Because setup before
        }
        type = t
        let margin : CGFloat = type == .Small ? 10 : 20
        constraintAvatarTop.constant = margin
        constraintReviewBottom.constant = margin
        constraintAvatarLeading.constant = margin
        viewBody.layer.borderWidth = 0
        imgSeperator.isHidden = true
        imgUnderLine.isHidden = true
        if type == .Normal{
            imgSeperator.isHidden = false
        }
        else if type == .Small {
            viewBody.layer.borderWidth = 1
        }
        else if type == .Full {
            imgUnderLine.isHidden = false
        }
        labelContent.numberOfLines = type != .Small ? 0 : 3
        constraintContentTop.constant = type == .Full ? 15 : 10
        constraintContentBottom.constant = type == .Full ? 15 : 10
        
        if type == .Small {
            btnLove.makeSmall()
            btnReview.makeSmall()
        }
    }
    
    // MARK: - Actions
    @IBAction func actionLove(_ sender: Any) {
        if tip == nil || parentViewController == nil {
            return
        }
        if tip!.checkLoved() {
            tip!.removeLoved()
        }
        else{
            Utils.viewController(parentViewController!, isSignUp: false, checkLoginWithCallback: {
                self.tip!.addLoved()
            })
        }
    }
    
    @IBAction func actionReview(_ sender: Any) {
        // Parent move to Tip Detail Page
        // Actualy don't need this action
        // Prevent button click (btnReview.isUserInteractionEnabled = false)
        // And use event cell did clicked
    }
    
    @IBAction func actionFavorite(_ sender: Any) {
        if tip == nil || tip?.objectId == nil {
            return
        }
        if btnFavorite.isSelected {
            // Remove
            AppState.removeFavorited(place: tip!, finish: {
                self.makeToast(Localized.Removed)
            })
        }
        else{
            // Add
            AppState.addFavorite(place: tip!, finish: {
                self.makeToast(Localized.Saved)
            })
        }
    }
    
    
    
    
    
    static func calculateHeightWithText(_ text: String, type: TipViewType) -> CGFloat {
        let alpha : CGFloat = 130.0
        let aText = TipView.attributeTextFromContent(text, type: type)
        return aText.heightWith(width: AppSetting.App.screenSize.width - 20 - 20, font: TipView.attributeTextFont()) + alpha
    }
}
