//
//  DropdownButton.swift
//  trid
//
//  Created by Black on 10/20/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import PureLayout

class DropdownButton: UIButton {
    
    var text : UILabel!
    var icon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // add text & icon
        icon = UIImageView(forAutoLayout: ())
        icon.image = UIImage(named: "icon-dropdown")
        self.addSubview(icon)
        icon.autoPinEdge(toSuperviewEdge: ALEdge.trailing, withInset: 0)
        icon.autoAlignAxis(ALAxis.horizontal, toSameAxisOf: self, withOffset: 2)
        icon.autoSetDimensions(to: CGSize(width: 11, height: 6))
        
        text = UILabel(forAutoLayout: ())
        text.text = "All"
        text.textColor = UIColor.white
        text.font = UIFont(name: AppSetting.Font.roboto, size: AppSetting.FontSize.big)
        
        self.addSubview(text)
        text.autoPinEdge(toSuperviewEdge: ALEdge.leading, withInset: 0)
        text.autoPinEdge(ALEdge.trailing, to: ALEdge.leading, of: icon, withOffset: -10)
        text.autoAlignAxis(toSuperviewAxis: ALAxis.horizontal)
        
    }
    
    public func setNewText(_ string: String){
        text.text = string
    }
    
    public func getTextFont() -> UIFont {
        return text.font
    }
    
}
