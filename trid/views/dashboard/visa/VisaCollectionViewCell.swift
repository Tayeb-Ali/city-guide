//
//  VisaCollectionViewCell.swift
//  trid
//
//  Created by Black on 7/11/17.
//  Copyright © 2017 Black. All rights reserved.
//

import UIKit

class VisaCollectionViewCell: UICollectionViewCell {
    
    static let name = "VisaCollectionViewCell"
    
    var onBookVisa : (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func actionBookVisa(_ sender: Any) {
        if onBookVisa != nil {
            onBookVisa!()
        }
    }
}
