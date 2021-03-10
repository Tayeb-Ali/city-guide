//
//  MarkerIconView.swift
//  trid
//
//  Created by Black on 10/14/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit

class MarkerIconView: UIView {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        self.backgroundColor = UIColor.clear
    }
    
    class func create(target: Any) -> MarkerIconView {
        return Bundle.main.loadNibNamed("MarkerIconView", owner: target, options: nil)![0] as! MarkerIconView
    }
    
    public func make(type: FCategoryType, text: String) {
        icon.image = UIImage(named: String(format: "marker-%d", type.rawValue))
        label.text = text
    }
}
