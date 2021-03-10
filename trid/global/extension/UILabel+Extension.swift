//
//  UILabel+Extension.swift
//  trid
//
//  Created by Black on 10/8/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit

extension UILabel {
    func heightForText(_ text: String, width: CGFloat) -> CGFloat{
        self.text = text
        return self.sizeThatFits(CGSize(width: width, height: CGFloat(MAXFLOAT))).height
    }
    
    func heightForAttributedText(_ text: NSAttributedString, width: CGFloat) -> CGFloat{
        self.attributedText = text
        return self.sizeThatFits(CGSize(width: width, height: CGFloat(MAXFLOAT))).height
    }
    
    func getHeight(width: CGFloat) -> CGFloat {
        return self.sizeThatFits(CGSize(width: width, height: CGFloat(MAXFLOAT))).height
    }
}


