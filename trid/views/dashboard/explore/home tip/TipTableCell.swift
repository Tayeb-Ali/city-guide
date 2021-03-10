//
//  TipTableCell.swift
//  trid
//
//  Created by Black on 3/13/17.
//  Copyright © 2017 Black. All rights reserved.
//

import UIKit

class TipTableCell: UITableViewCell {

    static let className = "TipTableCell"
    
    // Variables
    var tipView : TipView?
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tipView = TipView.makeTip()
        self.addSubview(tipView!)
        tipView?.autoPinEdgesToSuperviewEdges()
    }
    
    func fill(place: FPlace, parentController vc: UIViewController?, type: TipViewType) {
        _ = tipView?.fill(place: place, parentController: vc, type: type)
    }
    
    static func sizeFull(withHeight height : CGFloat = 172) -> CGSize{
        let size = AppSetting.App.screenSize
        return CGSize(width: size.width, height: height)
    }
    
    static func sizeSmall(height: CGFloat) -> CGSize {
        return CGSize(width: 240, height: height)
    }
    
}
