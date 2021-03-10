//
//  PopupForgotPassword.swift
//  trid
//
//  Created by Black on 11/30/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import PureLayout
import Toast_Swift

class PopupForgotPassword: PopupBase {
    
    var labelTitle : UILabel!
    var labelDescription : UILabel!
    var tfEmail : TridTextField!
    var btnSend : UIButton!
    
    var sendEvent : ((_ email: String)->())?

    public static func create() -> PopupForgotPassword {
        let popup = PopupForgotPassword(forAutoLayout: ())
        popup.make(title: Localized.forgotPassword, description: Localized.forgotPasswordIntro)
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
        labelTitle.autoPinEdge(toSuperviewEdge: ALEdge.top, withInset: AppSetting.Common.margin)
        labelTitle.autoPinEdge(toSuperviewEdge: ALEdge.leading, withInset: AppSetting.Common.margin)
        labelTitle.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        // description
        labelDescription = UILabel(forAutoLayout: ())
        labelDescription.numberOfLines = 0
        labelDescription.textColor = UIColor(netHex: AppSetting.Color.gray)
        labelDescription.font = UIFont(name: AppSetting.Font.roboto, size: AppSetting.FontSize.normal)
        self.viewBg.addSubview(labelDescription)
        labelDescription.autoPinEdge(toSuperviewEdge: ALEdge.trailing, withInset: AppSetting.Common.margin)
        labelDescription.autoPinEdge(toSuperviewEdge: ALEdge.leading, withInset: AppSetting.Common.margin)
        labelDescription.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: labelTitle, withOffset: AppSetting.Common.margin)
        // textfield email
        tfEmail = TridTextField.create()
        tfEmail.placeholder = Localized.email
        tfEmail.makeIcon(name: "icon-email")
        tfEmail.textColor = UIColor(netHex: AppSetting.Color.black)
        tfEmail.font = UIFont(name: AppSetting.Font.roboto, size: AppSetting.FontSize.normal)
        tfEmail.keyboardType = .emailAddress
        tfEmail.autocapitalizationType = .none
        tfEmail.autocorrectionType = .no
        self.viewBg.addSubview(tfEmail)
        tfEmail.autoPinEdge(toSuperviewEdge: ALEdge.trailing, withInset: AppSetting.Common.margin)
        tfEmail.autoPinEdge(toSuperviewEdge: ALEdge.leading, withInset: AppSetting.Common.margin)
        tfEmail.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: labelDescription, withOffset: AppSetting.Common.margin)
        tfEmail.autoSetDimension(ALDimension.height, toSize: 40)
        // btn send
        btnSend = UIButton(forAutoLayout: ())
        btnSend.backgroundColor = UIColor(netHex: AppSetting.Color.blue)
        btnSend.setTitle(Localized.Send, for: UIControl.State.normal)
        btnSend.titleLabel?.font = UIFont(name: AppSetting.Font.roboto_medium, size: AppSetting.FontSize.normal)
        btnSend.titleLabel?.textColor = UIColor.white
        btnSend.setTitleColor(UIColor.gray, for: UIControl.State.highlighted)
        self.viewBg.addSubview(btnSend)
        btnSend.autoPinEdge(toSuperviewEdge: ALEdge.trailing, withInset: AppSetting.Common.margin)
        btnSend.autoPinEdge(toSuperviewEdge: ALEdge.leading, withInset: AppSetting.Common.margin)
        btnSend.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: tfEmail, withOffset: AppSetting.Common.margin * 1.5)
        btnSend.autoSetDimension(ALDimension.height, toSize: 54)
        btnSend.autoPinEdge(toSuperviewEdge: ALEdge.bottom, withInset: AppSetting.Common.margin * 1.5)
        btnSend.layer.cornerRadius = 54/2
        btnSend.addTarget(self, action: #selector(PopupForgotPassword.handleSend), for: UIControl.Event.touchUpInside)
    }
    
    func make(title: String, description: String){
        makeUI()
        // assign text
        labelTitle.text = title
        labelDescription.text = description
        
        // calculate popup height
        let width = self.widthContent - AppSetting.Common.margin*2
        let heightTitle = title.heightWithConstrainedWidth(width: width, font: labelTitle.font)
        let heightDescription = description.heightWithConstrainedWidth(width: width, font: labelDescription.font) + 5
        // set constraint
        labelTitle.autoSetDimension(ALDimension.height, toSize: heightTitle)
        labelDescription.autoSetDimension(ALDimension.height, toSize: heightDescription)
        let height = heightTitle + heightDescription + AppSetting.Common.margin * 7 + 110 // tfEmail.bounds.height + btnSend.bounds.height
        makePopupHeight(contentHeight: height)
    }
    
    @objc func handleSend(_ sender: AnyObject){
        print("send")
        let mail = tfEmail.text
        if mail == nil || mail == "" {
             viewBg.makeToast(Localized.emailEmpty)
        }
        else if !(mail?.isValidEmail())! {
            viewBg.makeToast(Localized.emailInvalid)
        }
        else {
            if sendEvent != nil {
                sendEvent!(mail!)
            }
            self.close()
        }
    }
}
