//
//  MenuCell.swift
//  trid
//
//  Created by Black on 12/1/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {
    
    static let className = "MenuCell"

    // outlet
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fill(type: MenuType, icon name: String, text: String, section: Int){
        icon.image = UIImage(named: name)
        // text
        label.text = text
        if type == .allCities {
            label.textColor = UIColor(netHex: 0xF8E71C)
        }
        else{
            label.textColor = .white
        }
        label.font = UIFont(name: (section == 0 ? AppSetting.Font.roboto_medium : AppSetting.Font.roboto), size: AppSetting.FontSize.normalSmall)
    }
    
}
