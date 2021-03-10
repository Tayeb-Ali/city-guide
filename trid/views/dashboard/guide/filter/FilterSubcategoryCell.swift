//
//  FilterSubcategoryCell.swift
//  trid
//
//  Created by Black on 12/26/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit

class FilterSubcategoryCell: UITableViewCell {
    
    static let className = "FilterSubcategoryCell"
    
    // block
    var changedState : ((Bool) -> Void)?
    
    // outlet
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelCount: UILabel!
    @IBOutlet weak var imgSelected: UIImageView!
    @IBOutlet weak var btnSelect: UIButton!
    
    
    var selectedState : Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func fill(subCategory: FSubcategory) {
        labelName.text = subCategory.getName()
        labelCount.text = "(\(subCategory.resultCount))"
        selectedState = subCategory.selected
        applyFilterSelected(subCategory.selected)
    }
    
    func applyFilterSelected(_ selected: Bool){
        // self.accessoryType = selected ? .checkmark : .none
        imgSelected.image = selected ? UIImage(named: "checked") : UIImage(named: "uncheck")
    }
    
    @IBAction func actionSelect(_ sender: Any) {
        // let s = self.accessoryType == .checkmark
        selectedState = !selectedState
        applyFilterSelected(selectedState)
        if changedState != nil {
            changedState!(selectedState)
        }
    }
    
    
    static func cellHeight() -> CGFloat {
        return 45
    }
    
}
