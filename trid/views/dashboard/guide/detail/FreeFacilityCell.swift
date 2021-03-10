//
//  FreeFacilityCell.swift
//  trid
//
//  Created by Black on 10/5/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit

class FreeFacilityCell: UICollectionViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func make(facility: FFacility){
        icon.image = UIImage(named: facility.getIcon())
        labelName.text = facility.getName()
    }

}
