//
//  PopupBase.swift
//  trid
//
//  Created by Black on 10/5/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import PureLayout

class PopupBase: UIView {
    
    var scrollViewBg : UIScrollView!
    var viewBg : UIView!
    var btnClose: UIButton!
    var constraintBgHeight : NSLayoutConstraint!
    var constraintBgAlignY : NSLayoutConstraint!
    
    // variable
    let width : CGFloat = AppSetting.App.screenSize.width - 40
    let widthContent: CGFloat = AppSetting.App.screenSize.width - 80
    let maxHeight : CGFloat = AppSetting.App.screenSize.height * 0.85
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeBg()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeBg()
    }
    
    private func makeBg() {
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        // button bg close
        let btnBgClose = UIButton(forAutoLayout: ())
        btnBgClose.backgroundColor = UIColor.clear
        btnBgClose.addTarget(self, action: #selector(PopupBase.close), for: UIControl.Event.touchUpInside)
        self.addSubview(btnBgClose)
        btnBgClose.autoPinEdgesToSuperviewEdges()
        
        // bg view
        scrollViewBg = UIScrollView(forAutoLayout: ())
        scrollViewBg.backgroundColor = UIColor.white
        scrollViewBg.layer.cornerRadius = 20
        scrollViewBg.clipsToBounds = true
        scrollViewBg.showsHorizontalScrollIndicator = false
        scrollViewBg.showsVerticalScrollIndicator = false
        scrollViewBg.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        self.addSubview(scrollViewBg)
        scrollViewBg.autoPinEdge(toSuperviewEdge: ALEdge.leading, withInset: AppSetting.Common.margin/2)
        scrollViewBg.autoPinEdge(toSuperviewEdge: ALEdge.trailing, withInset: AppSetting.Common.margin/2)
        constraintBgAlignY = scrollViewBg.autoAlignAxis(toSuperviewAxis: ALAxis.horizontal)
        constraintBgHeight = scrollViewBg.autoSetDimension(ALDimension.height, toSize: 100)
        
        // view
        viewBg = UIView(forAutoLayout: ())
        scrollViewBg.addSubview(viewBg)
        viewBg.autoPinEdgesToSuperviewEdges()
        viewBg.autoSetDimension(ALDimension.width, toSize: AppSetting.App.screenSize.width - AppSetting.Common.margin)
        let constraintViewBgHeight = viewBg.autoSetDimension(ALDimension.height, toSize: 100)
        viewBg.clipsToBounds = true
        constraintViewBgHeight.priority = UILayoutPriority(rawValue: 250)
        constraintViewBgHeight.isActive = true
    }
    
    @objc func close() {
        hide()
    }
    
    public func show(completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        Global.appDelegate.window?.addSubview(self)
        self.autoPinEdgesToSuperviewEdges()
        self.alpha = 0.0
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIView.AnimationOptions.curveLinear, animations: {
            self.alpha = 1.0
            }, completion: completion)
    }
    
    public func hide(completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        self.alpha = 1.0
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIView.AnimationOptions.curveLinear, animations: {
            self.alpha = 0.0
            }, completion: {(finished: Bool) -> Void in
                self.removeFromSuperview()
                completion(finished)
        })
    }
    
    func makePopupHeight(contentHeight: CGFloat){
        constraintBgHeight.constant = min(contentHeight, self.maxHeight)
    }
    
    
    
    
}
