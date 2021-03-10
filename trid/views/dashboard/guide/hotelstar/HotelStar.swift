//
//  HotelStar.swift
//  trid
//
//  Created by Black on 10/8/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import PureLayout

class HotelStar: UIView {

    var label: UILabel!
    var icon: UIImageView!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        make()
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        make()
    }
    
    func make(){
        self.backgroundColor = UIColor(netHex: 0xFFBB3A)
        self.layer.cornerRadius = 2
        // icon
        icon = UIImageView(forAutoLayout: ())
        icon.image = UIImage(named: "icon-hotel-star")
        icon.contentMode = UIView.ContentMode.center
        self.addSubview(icon)
        icon.autoSetDimensions(to: CGSize(width: 10, height: 10))
        icon.autoAlignAxis(toSuperviewAxis: ALAxis.horizontal)
        icon.autoAlignAxis(ALAxis.vertical, toSameAxisOf: self, withOffset: 5)
        // label
        label = UILabel(forAutoLayout: ())
        label.text = "3"
        label.textColor = UIColor.white
        label.font = UIFont(name: AppSetting.Font.roboto, size: 14)
        self.addSubview(label)
        label.autoAlignAxis(toSuperviewAxis: ALAxis.horizontal)
        label.autoPinEdge(ALEdge.trailing, to: ALEdge.leading, of: icon)
    }
    
    public func makeStar(level: String) {
        if label != nil {
            label.text = level
        }
    }

}
