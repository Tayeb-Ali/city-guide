//
//  CityCell.swift
//  trid
//
//  Created by Black on 9/28/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import SDWebImage

class CityCell: UITableViewCell {

    static let className = "CityCell"
    
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelVisitor: UILabel!
    @IBOutlet weak var imgState: UIImageView!
    @IBOutlet weak var btnVideo: UIButton!
    @IBOutlet weak var labelComingSoon: UILabel!
    
    var openVideoIntro : (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .red
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func makeCity(_ city: FCity){
        self.labelName.text = city.getName()
        self.labelVisitor.text = city.getIntro()
        let photo = city.getPhotoUrl()
        self.imgBackground.sd_setImage(with: URL(string: photo), placeholderImage: UIImage(named: "img-default"))
        // Video intro button
        btnVideo.isHidden = city.getVideoIntroUrl() ?? "" == ""
        // Unlock city
        setCityState(city.getState())
        // Coming soon
        labelComingSoon.isHidden = !city.getDeactived()
    }
    
    func setCityState(_ state: FCityState){
        if state == .Paid {
            imgState.image = UIImage(named: "icon-locked")
        }
        else if state == .Offline {
            imgState.image = UIImage(named: "icon-available-offline")
        }
        else {
            imgState.image = nil
        }
    }
    
    @IBAction func actionPlayVideo(_ sender: Any) {
        if openVideoIntro != nil {
            openVideoIntro!()
        }
    }
    
    static func cellHeight() -> CGFloat {
        return 200
    }
}
