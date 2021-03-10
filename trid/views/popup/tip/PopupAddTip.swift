//
//  PopupAddTip.swift
//  trid
//
//  Created by Black on 2/21/17.
//  Copyright © 2017 Black. All rights reserved.
//

import UIKit
import PureLayout
import IQKeyboardManagerSwift

class PopupAddTip: PopupBase {
    
    static let ContentHeight : CGFloat = 180.0

    var labelTitle : UILabel!
    var tvContent : UITextView!
    var btnSubmit : UIButton!
    
    var actionAdd : ((_ content: String?) -> Void)?
    
    public static func popupWith(title: String) -> PopupAddTip {
        let popup = PopupAddTip(forAutoLayout: ())
        popup.make(title: title)
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
        cross.backgroundColor = UIColor(netHex: AppSetting.Color.veryLightGray)
        self.viewBg.addSubview(cross)
        cross.autoPinEdge(toSuperviewEdge: ALEdge.leading, withInset: AppSetting.Common.margin)
        cross.autoPinEdge(toSuperviewEdge: ALEdge.trailing, withInset: AppSetting.Common.margin)
        cross.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: labelTitle, withOffset: AppSetting.Common.margin/2)
        cross.autoSetDimension(.height, toSize: 1)
        
        // content
        tvContent = UITextView(forAutoLayout: ())
        tvContent.font = UIFont(name: AppSetting.Font.roboto, size: AppSetting.FontSize.normal)
        tvContent.textColor = UIColor.lightGray
        tvContent.text = Localized.TypeHere
        tvContent.delegate = self
        self.viewBg.addSubview(tvContent)
        tvContent.autoPinEdge(toSuperviewEdge: ALEdge.leading, withInset: AppSetting.Common.margin)
        tvContent.autoPinEdge(toSuperviewEdge: ALEdge.trailing, withInset: AppSetting.Common.margin)
        tvContent.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: cross, withOffset: AppSetting.Common.margin/2)
        tvContent.autoSetDimension(.height, toSize: PopupAddTip.ContentHeight)
        
        // Button Submit
        btnSubmit = UIButton(forAutoLayout: ())
        btnSubmit.backgroundColor = UIColor(netHex: AppSetting.Color.blue)
        btnSubmit.setTitle(Localized.Add, for: UIControl.State.normal)
        btnSubmit.titleLabel?.font = UIFont(name: AppSetting.Font.roboto_medium, size: AppSetting.FontSize.normal)
        btnSubmit.titleLabel?.textColor = UIColor.white
        btnSubmit.setTitleColor(UIColor.lightGray, for: UIControl.State.highlighted)
        self.viewBg.addSubview(btnSubmit)
        btnSubmit.autoPinEdge(toSuperviewEdge: ALEdge.trailing, withInset: AppSetting.Common.margin)
        btnSubmit.autoPinEdge(toSuperviewEdge: ALEdge.leading, withInset: AppSetting.Common.margin)
        btnSubmit.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: tvContent, withOffset: AppSetting.Common.margin)
        btnSubmit.autoSetDimension(ALDimension.height, toSize: 50)
        btnSubmit.autoPinEdge(toSuperviewEdge: ALEdge.bottom, withInset: AppSetting.Common.margin * 1.5)
        btnSubmit.layer.cornerRadius = 50/2
        btnSubmit.addTarget(self, action: #selector(actionSubmitTip), for: UIControl.Event.touchUpInside)
    }
    
    func make(title: String) {
        makeUI()
        // assign text
        labelTitle.text = title
        // calculate popup height
        let heightTitle = title.heightWithConstrainedWidth(width: self.widthContent, font: labelTitle.font)
        // set constraint
        labelTitle.autoSetDimension(ALDimension.height, toSize: heightTitle)
        // Popup Height
        makePopupHeight(contentHeight: heightTitle + PopupAddTip.ContentHeight + 50 + AppSetting.Common.margin * 3.5)
        // Disable scroll
        scrollViewBg.isScrollEnabled = false
    }
    
    // Action
    @objc func actionSubmitTip(_ sender : UIButton){
        if actionAdd != nil {
            let text = tvContent.textColor == UIColor.lightGray ? nil : tvContent.text
            actionAdd?(text)
        }
    }

}

extension PopupAddTip : UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        IQKeyboardManager.shared.enable = false
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.constraintBgAlignY.constant = -PopupAddTip.ContentHeight/2.0
            self.layoutIfNeeded()
        }, completion: nil)
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if tvContent.textColor == UIColor.lightGray {
            tvContent.text = nil
            tvContent.textColor = UIColor(netHex: AppSetting.Color.black)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if tvContent.text.isEmpty {
            tvContent.text = Localized.AddTipPlaceholder
            tvContent.textColor = UIColor.lightGray
        }
        // Enalbe IQKeyboard
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.constraintBgAlignY.constant = 0
            self.layoutIfNeeded()
        }, completion: {f in
            IQKeyboardManager.shared.enable = true
        })
    }
}



