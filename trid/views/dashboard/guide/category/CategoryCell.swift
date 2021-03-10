//
//  CategoryCell.swift
//  trid
//
//  Created by Black on 10/1/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    
    static let className = "CategoryCell"

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.borderColor = UIColor(netHex: 0xEEEEEE).cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 7
    }
    
    public func makeName(_ name: String, type: FCategoryType?){
        labelName.text = name
        icon.image = UIImage(named: FCategory.iconForType(type))
    }
}
