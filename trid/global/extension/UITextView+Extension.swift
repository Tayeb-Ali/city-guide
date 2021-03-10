//
//  UITextView+Extension.swift
//  trid
//
//  Created by Black on 4/12/17.
//  Copyright © 2017 Black. All rights reserved.
//

import UIKit

extension UITextView {
    func heightForAttributedText(_ text: NSAttributedString, width: CGFloat) -> CGFloat{
        self.attributedText = text
        return self.sizeThatFits(CGSize(width: width, height: 20000)).height
    }
    
    func getHeight(width: CGFloat) -> CGFloat {
        return self.sizeThatFits(CGSize(width: width, height: 20000)).height
    }
}
