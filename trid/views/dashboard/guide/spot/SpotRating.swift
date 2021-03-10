//
//  SpotRating.swift
//  trid
//
//  Created by Black on 10/8/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import PureLayout

class SpotRating: UIView {

    var labelRating: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        make()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        make()
    }
    
    private func make(){
        self.backgroundColor = UIColor(netHex: 0x2196F1)
        self.layer.cornerRadius = 2
        labelRating = UILabel(forAutoLayout: ())
        labelRating.textColor = UIColor.white
        labelRating.font = UIFont(name: AppSetting.Font.roboto, size: 14)
        self.addSubview(labelRating)
        labelRating.autoAlignAxis(toSuperviewAxis: ALAxis.horizontal)
        labelRating.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        labelRating.text = "3.9"
    }
    
    public func makeRating(_ rating: String){
        labelRating?.text = rating
    }

}
