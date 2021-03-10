//
//  TabbarButton.swift
//  trid
//
//  Created by Black on 9/30/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import Foundation
import PureLayout

class TabbarButton: UIButton {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    var image : UIImage?
    var imageSelected: UIImage?
    
    override var isSelected: Bool {
        didSet {
            //print("changing from \(selected) to \(newValue)")
            // icon
            self.icon?.image = isSelected ? self.imageSelected : self.image
            // color
            self.label?.textColor = isSelected ? UIColor(netHex: AppSetting.Color.blue) : UIColor(netHex: AppSetting.Color.gray)
        }
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        // makeContent()
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        // makeContent()
    }
    
    class func initWithTitle(_ title: String, image: String? = nil, imageSelected: String? = nil) -> TabbarButton
    {
        let tab = UINib(nibName: "TabbarButton", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! TabbarButton
        // let tab = TabbarButton(forAutoLayout: ())
        tab.makeTitle(title, image: image!, imageSelected: imageSelected!)
        return tab
    }
    
    public func makeTitle(_ title: String, image: String, imageSelected: String){
        self.image = UIImage(named: image)!
        self.imageSelected = UIImage(named: imageSelected)!
        self.label?.text = title
        self.isSelected = false
    }
    
//    func makeContent(){
//        label = UILabel(forAutoLayout: ())
//        self.addSubview(label)
//        label.autoPinEdge(toSuperviewEdge: ALEdge.leading)
//        label.autoPinEdge(toSuperviewEdge: ALEdge.trailing)
//        label.autoPinEdge(toSuperviewEdge: ALEdge.bottom, withInset: 10)
//        label.autoSetDimension(ALDimension.height, toSize: 16)
//        // icon
//        icon = UIImageView(forAutoLayout: ())
//        icon.contentMode = UIView.ContentMode.center
//        self.addSubview(icon)
//        icon.autoPinEdge(toSuperviewEdge: ALEdge.leading)
//        icon.autoPinEdge(toSuperviewEdge: ALEdge.top)
//        icon.autoPinEdge(toSuperviewEdge: ALEdge.trailing)
//        icon.autoPinEdge(ALEdge.bottom, to: ALEdge.top, of: label)
//    }
    
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
