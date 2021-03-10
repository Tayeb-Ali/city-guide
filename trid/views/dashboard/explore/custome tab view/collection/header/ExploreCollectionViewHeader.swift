//
//  ExploreCollectionViewHeader.swift
//  trid
//
//  Created by Black on 3/6/17.
//  Copyright © 2017 Black. All rights reserved.
//

import UIKit

class ExploreCollectionViewHeader: UIView {
    
    static let Height : CGFloat = 48
    
    // Outlet
    @IBOutlet weak var segmentio: Segmentio!
    @IBOutlet weak var viewRecommended: UIView!
    @IBOutlet weak var btnRecommended: UIButton!
    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var constraintSegmentWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintSegmentHeight: NSLayoutConstraint!
    
    // Callback
    var callbackFilter : (()->Void)?
    var callbackRecentTips : (()->Void)?
    var callbackTopTips : (()->Void)?
    
    // Variables
    var categoryType: FCategoryType?

    class func create(categoryType type: FCategoryType?) -> ExploreCollectionViewHeader {
        let header = Bundle.main.loadNibNamed("ExploreCollectionViewHeader", owner: self, options: nil)?[0] as! ExploreCollectionViewHeader
        header.categoryType = type
        header.make()
        return header
    }
    
    override func layoutSubviews() {
        if constraintSegmentHeight.constant != ExploreCollectionViewHeader.Height {
            constraintSegmentHeight.constant = ExploreCollectionViewHeader.Height
        }
    }
    
    override func awakeFromNib() {
        constraintSegmentWidth.constant = AppSetting.App.screenSize.width
        constraintSegmentHeight.constant = ExploreCollectionViewHeader.Height
    }
    
    func make() {
        viewRecommended.isHidden = categoryType == .Tips
        segmentio.isHidden = categoryType != .Tips
        if categoryType == .Tips {
            // Setup tip segmentio
            setupSegmentio()
        }
    }
    
    func setupSegmentio() {
        // Make segment categories of this city
        let tip = SegmentioItem(title: Localized.Questions, image: UIImage(named: ""))
        let top = SegmentioItem(title: Localized.Tips, image: UIImage(named: ""))
        let segments = [tip, top]
        let option = segmentio.segmentioOptions(background: UIColor.white,
                                                maxVisibleItems: 2,
                                                font: UIFont(name: AppSetting.Font.roboto_medium, size: AppSetting.FontSize.big)!,
                                                textColor: UIColor(netHex: AppSetting.Color.gray),
                                                textColorSelected: UIColor(netHex: AppSetting.Color.blue),
                                                verticalColor: UIColor.clear,
                                                horizontalColor: UIColor(netHex: AppSetting.Color.veryLightGray),
                                                isFlexibleWidth: false,
                                                indicatorColor: UIColor(netHex: AppSetting.Color.blue),
                                                indicatorHeight: 2,
                                                indicatorOverSeperator: true)
        segmentio.setup(
            content: segments,
            style: SegmentioStyle.onlyLabel,
            options: option
        )
        segmentio.valueDidChange = { [weak self] _, segmentIndex in
            // scroll change page
            if self?.callbackRecentTips != nil && segmentIndex == 0 {
                self?.callbackRecentTips!()
            }
            else if self?.callbackTopTips != nil && segmentIndex == 1 {
                self?.callbackTopTips!()
            }
        }
        // Default tab = 0
        segmentio.selectedSegmentioIndex = 0
    }
    
    // Actions
    @IBAction func actionFilter(_ sender: Any) {
        if callbackFilter != nil {
            callbackFilter!()
        }
    }
    
    func changeStateFiltering(_ filtering: Bool){
        btnFilter.isSelected = filtering
    }
}
