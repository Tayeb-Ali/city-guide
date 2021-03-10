//
//  ForecastTableCell.swift
//  trid
//
//  Created by Black on 4/20/17.
//  Copyright © 2017 Black. All rights reserved.
//

import UIKit

class ForecastTableCell: UITableViewCell {
    
    static let className = "ForecastTableCell"
    
    // outlet
    @IBOutlet weak var labelDay: UILabel!
    @IBOutlet weak var labelTempLow: UILabel!
    @IBOutlet weak var labelTempHigh: UILabel!
    @IBOutlet weak var labelCondition: UILabel!
    @IBOutlet weak var imgForecast: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fillData(day: ForecastDay) {
        labelDay.text = day.weekday()
        labelTempLow.text = day.tempLowC
        labelTempHigh.text = day.tempHighC
        labelCondition.text = day.condition
        imgForecast.image = UIImage(named: day.icon + "_s")
    }
    
}
