//
//  TipCollectionCell.swift
//  trid
//
//  Created by Black on 2/18/17.
//  Copyright © 2017 Black. All rights reserved.
//

import UIKit
import PureLayout

class TipCollectionCell: UICollectionViewCell {
    static let className = "TipCollectionCell"
    
    // Variables
    var tipView : TipView?
    
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
