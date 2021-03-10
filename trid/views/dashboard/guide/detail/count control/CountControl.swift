//
//  LoveCountControl.swift
//  trid
//
//  Created by Black on 2/8/17.
//  Copyright © 2017 Black. All rights reserved.
//

import UIKit
import PureLayout

//@IBDesignable
class CountButton: UIButton {
    
    // Outlet
    var label: UILabel?
    var imgIcon: UIImageView?
    var constraintIconWidth : NSLayoutConstraint?
    var constraintIconHeight : NSLayoutConstraint?
    
    @IBInspectable var textColor: UIColor = UIColor(netHex: AppSetting.Color.gray) {
        didSet {
            setLabel()
        }
    }
    
    @IBInspectable var text: String = "" {
        didSet {
            setLabel()
        }
    }
    
    @IBInspectable var textFont: UIFont? = UIFont(name: AppSetting.Font.roboto, size: AppSetting.FontSize.normal) {
        didSet {
            setLabel()
        }
    }
    
    @IBInspectable var icon: UIImage? = nil {
        didSet {
            setIcon()
        }
    }
    
    @IBInspectable var selectedIcon: UIImage? = nil {
        didSet {
            setIcon()
        }
    }
    
    override var isSelected: Bool {
        didSet{
            setIcon()
        }
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        make()
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        make()
    }
    
    func make(){
        self.backgroundColor = .clear
        // icon
        imgIcon = UIImageView(forAutoLayout: ())
        imgIcon?.image = UIImage(named: "icon-love")
        imgIcon?.contentMode = UIView.ContentMode.scaleAspectFit
        self.addSubview(imgIcon!)
        constraintIconWidth = imgIcon!.autoSetDimension(.width, toSize: 20)
        constraintIconHeight = imgIcon!.autoSetDimension(.height, toSize: 16)
        imgIcon?.autoAlignAxis(toSuperviewAxis: ALAxis.horizontal)
        imgIcon?.autoPinEdge(toSuperviewEdge: ALEdge.leading)
        // label
        label = UILabel(forAutoLayout: ())
        self.addSubview(label!)
        setLabel()
        label?.autoAlignAxis(toSuperviewAxis: ALAxis.horizontal)
        label?.autoPinEdge(ALEdge.leading, to: ALEdge.trailing, of: imgIcon!, withOffset: 5)
        label?.autoPinEdge(toSuperviewEdge: ALEdge.trailing)
    }
    
    private func setLabel(){
        if label != nil {
            label?.text = text
            label?.textColor = textColor
            label?.font = textFont
        }
    }
    
    private func setIcon() {
        if imgIcon == nil {
            return
        }
        if !isSelected {
            imgIcon?.image = icon
        }
        else{
            imgIcon?.image = selectedIcon != nil ? selectedIcon : icon
        }
    }
    
    func makeSmall() {
        if constraintIconWidth != nil && constraintIconHeight != nil {
            constraintIconWidth!.constant = 12
            constraintIconHeight!.constant = 12
        }
        textFont = UIFont(name: AppSetting.Font.roboto, size: AppSetting.FontSize.normalSmall)
    }
    
    
}
