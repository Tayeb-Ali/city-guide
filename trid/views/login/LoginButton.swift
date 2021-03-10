//
//  LoginButton.swift
//  trid
//
//  Created by Black on 9/26/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import PureLayout

class LoginButton: UIView {
    
    var button : UIButton?
    var label : UILabel?

    override init(frame: CGRect){
        super.init(frame: frame);
        makeUI();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI();
    }
    
    convenience init(){
        self.init(frame: CGRect.zero);
    }
    
    func makeUI(){
        // button bg
        self.button = UIButton.init(forAutoLayout: ());
        self.addSubview(self.button!);
        self.button?.autoPinEdgesToSuperviewEdges();
        self.button?.layer.cornerRadius = 5;
        self.button?.layer.borderWidth = 1;
        // title
        self.label = UILabel.init(forAutoLayout: ());
        self.addSubview(self.label!);
        self.label?.autoPinEdgesToSuperviewEdges();
        self.label?.textAlignment = NSTextAlignment.center;
    }
    
    public func makeContent(bgColor: UIColor, borderColor: UIColor, title: String){
        self.button?.backgroundColor = bgColor;
        self.button?.layer.borderColor = borderColor.cgColor;
        self.label?.text = title;
    }

}
