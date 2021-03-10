//
//  CommentCell.swift
//  trid
//
//  Created by Black on 12/6/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import SDWebImage

class CommentCell: UITableViewCell {
    
    static let className = "CommentCell"
    
    // outlet
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelComment: UILabel!
    @IBOutlet weak var imgSeparator: UIImageView!
    @IBOutlet weak var constraintAvatarLeading: NSLayoutConstraint!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgAvatar.layer.cornerRadius = imgAvatar.bounds.height/2
        imgAvatar.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func fill(comment: FComment, categoryType: FCategoryType?, isLastCell: Bool){
        // Layout
        constraintAvatarLeading.constant = categoryType == FCategoryType.Tips ? 40 : 10
        
        // separator
        imgSeparator.isHidden = isLastCell
        // time
        let interval = comment[FComment.updatedAt] as! TimeInterval
        let date = Date(timeIntervalSince1970: interval)
        labelTime.text = date.toDisplayString() 
        // text
        labelComment.attributedText = CommentCell.attributeTextFromContent(comment[FComment.text] as? String ?? "")
        
        // user
        let user = UserService.getUser(withId: comment[FComment.senderId] as! String)
        labelName.text = user?[FUser.name] as? String
        // avatar
        if user != nil {
            imgAvatar.sd_setImage(with: URL(string: user!.getAvatar()), placeholderImage: UIImage(named: "avatar-default"))
        }
        else{
            imgAvatar.image = UIImage(named: "avatar-default")
        }
    }
    
    static func attributeTextFont() -> UIFont {
        let size : CGFloat = AppSetting.FontSize.normal
        return UIFont(name: AppSetting.Font.roboto, size: size)!
    }
    
    static func attributeTextFromContent(_ content: String) -> NSAttributedString {
        let color = UIColor(netHex: AppSetting.Color.gray)
        let size : CGFloat = AppSetting.FontSize.normalSmall
        let textFont = UIFont(name: AppSetting.Font.roboto, size: size)!
        let textAttributes = [NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.font: textFont]
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = AppSetting.Text.lineSpacing
        paragraphStyle.paragraphSpacing = AppSetting.Text.paragraphSpacing
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        let text = NSMutableAttributedString()
        text.append(NSMutableAttributedString(string: content, attributes: textAttributes))
        text.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, text.length))
        return text
    }
    
    
    static func heightForComment(_ text: String, categoryType: FCategoryType) -> CGFloat {
        let padding : CGFloat = categoryType == .Tips ? 40 + 40 + 10 + 10 : 10 + 40 + 10 + 10
        let width = AppSetting.App.screenSize.width - padding
        let alpha : CGFloat = 90.0
        let aText = CommentCell.attributeTextFromContent(text)
        return aText.heightWith(width: width, font: UIFont(name: AppSetting.Font.roboto, size: AppSetting.FontSize.normalSmall)!) + alpha
    }
    
}
