//
//  PopupText.swift
//  trid
//
//  Created by Black on 10/10/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import PureLayout

class PopupText: PopupBase {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var labelTitle : UILabel!
    var labelContent : UILabel!
    
    public static func popupWith(title: String, content: String) -> PopupText {
        let popup = PopupText(forAutoLayout: ())
        popup.make(title: title, content: content)
        return popup
    }
    
    public static func popupWith(title: String, attributedContent: NSAttributedString) -> PopupText {
        let popup = PopupText(forAutoLayout: ())
        popup.make(title: title, attributedContent: attributedContent)
        return popup
    }
    
    func makeUI(){
        // title
        labelTitle = UILabel(forAutoLayout: ())
        labelTitle.textAlignment = NSTextAlignment.center
        labelTitle.numberOfLines = 0
        labelTitle.textColor = UIColor(netHex: AppSetting.Color.black)
        labelTitle.font = UIFont(name: AppSetting.Font.roboto, size: AppSetting.FontSize.veryBig)
        self.viewBg.addSubview(labelTitle)
        labelTitle.autoPinEdge(toSuperviewEdge: ALEdge.top)
        labelTitle.autoPinEdge(toSuperviewEdge: ALEdge.leading, withInset: AppSetting.Common.margin)
        labelTitle.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        
        // crossline
        let cross = UIView(forAutoLayout: ())
        cross.backgroundColor = UIColor(netHex: AppSetting.Color.lightGray)
        self.viewBg.addSubview(cross)
        cross.autoPinEdge(toSuperviewEdge: ALEdge.leading)
        
        // content
        labelContent = UILabel(forAutoLayout: ())
        labelContent.textAlignment = NSTextAlignment.center
        labelContent.numberOfLines = 0
        labelContent.textColor = UIColor(netHex: AppSetting.Color.black)
        labelContent.font = UIFont(name: AppSetting.Font.roboto, size: AppSetting.FontSize.normal)
        self.viewBg.addSubview(labelContent)
        labelContent.autoPinEdge(toSuperviewEdge: ALEdge.leading, withInset: AppSetting.Common.margin)
        labelContent.autoPinEdge(toSuperviewEdge: ALEdge.trailing, withInset: AppSetting.Common.margin)
        labelContent.autoPinEdge(toSuperviewEdge: ALEdge.bottom, withInset: AppSetting.Common.margin)
        labelContent.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: labelTitle, withOffset: AppSetting.Common.margin)
    }
    
    func make(title: String, content: String) {
        makeUI()
        // assign text
        labelTitle.text = title
        labelContent.text = content
        // calculate popup height
        let heightTitle = title.heightWithConstrainedWidth(width: self.widthContent, font: labelTitle.font)
        let heightContent = content.heightWithConstrainedWidth(width: self.widthContent, font: labelContent.font)
        // set constraint
        labelTitle.autoSetDimension(ALDimension.height, toSize: heightTitle)
        labelContent.autoSetDimension(ALDimension.height, toSize: heightContent)
        makePopupHeight(contentHeight: heightTitle + heightContent + AppSetting.Common.margin * 3)
    }
    
    func make(title: String, attributedContent: NSAttributedString) {
        makeUI()
        // assign text
        labelTitle.text = title
        labelContent.attributedText = attributedContent
        // calculate popup height
        let heightTitle = title.heightWithConstrainedWidth(width: self.widthContent, font: labelTitle.font)
        let heightContent = labelContent.getHeight(width: self.widthContent)
        // set constraint
        labelTitle.autoSetDimension(ALDimension.height, toSize: heightTitle)
        labelContent.autoSetDimension(ALDimension.height, toSize: heightContent)
        makePopupHeight(contentHeight: heightTitle + heightContent + AppSetting.Common.margin * 3)
    }
    
    
}
