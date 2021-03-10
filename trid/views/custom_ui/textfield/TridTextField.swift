//
//  TridTextField.swift
//  trid
//
//  Created by Black on 11/29/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit

class TridTextField: UITextField {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var border = CALayer()
    let iconWidth: CGFloat = 26
    var icon : UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // setup content
        createContent()
    }
    
    public static func create() -> TridTextField {
        let field = TridTextField(forAutoLayout: ())
        field.createContent()
        return field
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        border.frame = CGRect(x: iconWidth, y: self.bounds.height - 1, width: self.bounds.width - iconWidth, height: 1)
    }
    
    fileprivate func createContent(){
        self.backgroundColor = UIColor.clear
        self.borderStyle = UITextField.BorderStyle.none
        
        // left icon
        self.leftViewMode = UITextField.ViewMode.always
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: iconWidth, height: self.bounds.height - 6))
        icon = UIImageView(image: UIImage(named: "icon-email"))
        icon.frame = (self.leftView?.frame)!
        icon.contentMode = UIView.ContentMode.left
        self.leftView?.addSubview(icon)
        
        // underline
        border.borderColor = UIColor(netHex: AppSetting.Color.veryLightGray).cgColor
        border.borderWidth = 1
        border.frame = CGRect(x: iconWidth, y: self.bounds.height - 1, width: self.bounds.width - iconWidth, height: 1)
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
        
    }
    
    func makeIcon(name: String){
        icon.image = UIImage(named: name)
    }
    
    

}
