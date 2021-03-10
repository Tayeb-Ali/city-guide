//
//  PaidFacilityCell.swift
//  trid
//
//  Created by Black on 10/5/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit

class PaidFacilityCell: UICollectionViewCell {
    
    // constant
    static let className : String = "PaidFacilityCell"
    
    // outlet
    @IBOutlet weak var labelName: UILabel!
    
    // value
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func makeName(_ name : String, color: UIColor = UIColor(netHex: AppSetting.Color.gray), size: CGFloat = AppSetting.FontSize.normal){
        labelName.text = name.trimmingCharacters(in: CharacterSet(charactersIn: "\n @"))
        labelName.textColor = color
        labelName.font = UIFont(name: AppSetting.Font.roboto, size: size)
    }
}
