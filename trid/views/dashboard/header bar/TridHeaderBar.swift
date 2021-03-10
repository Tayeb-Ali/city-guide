//
//  TridHeaderBar.swift
//  trid
//
//  Created by Black on 9/27/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit

protocol TridHeaderBarProtocol: class {
    func headerBarGoback()
    func headerBarSearch()
    func headerBarFilter()
    func headerBarReset()
}

class TridHeaderBar: UIView {
    
    @IBOutlet weak var btnSetting: UIButton!
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var btnReset: UIButton!
    @IBOutlet weak var labelCategoryName: UILabel!
    @IBOutlet weak var constraintFilterWidth: NSLayoutConstraint!
    
    var delegate: TridHeaderBarProtocol?
    
    let filterWidth = CGFloat(36.0)
    
    override func awakeFromNib() {
        self.backgroundColor = UIColor(netHex: AppSetting.Color.blue) // AppState.shared.currentCategoryColor
        // hidden some button
        btnBack.isHidden = true
        labelCategoryName.isHidden = true
        constraintFilterWidth.constant = 0
    }
    
    private func hideAll(){
        btnSetting.isHidden = true
        imgLogo.isHidden = true
        btnSearch.isHidden = true
        btnBack.isHidden = true
        btnFilter.isHidden = true
        btnReset.isHidden = true
        labelCategoryName.isHidden = true
        constraintFilterWidth.constant = 0
    }
    
    // MARK: - make ui
    func makeHeaderWeather(name: String) {
        hideAll()
        self.backgroundColor = .clear
        // left
        btnBack.isHidden = false
        // center
        labelCategoryName.isHidden = false
        labelCategoryName.text = name
    }
    
    func makeHeaderAllCity() {
        hideAll()
        // left
        btnSetting.isHidden = false
        // center
        imgLogo.isHidden = false
        // right
        btnSearch.isHidden = false
    }
    
    public func makeHeaderHomeGuide(){
        hideAll()
        // bg
        self.backgroundColor = UIColor.clear
        // left
        //btnSetting.isHidden = false
        btnBack.isHidden = false
        // right
        btnSearch.isHidden = false
    }
    
    func makeHeaderAskShare() {
        hideAll()
        // title
        labelCategoryName.isHidden = false
        labelCategoryName.text = Localized.AskShare
        // left
        btnBack.isHidden = false
        // right
        //btnSearch.isHidden = false
    }
    
    func makeHeaderFavorite() {
        hideAll()
        // bg
        self.backgroundColor = UIColor(netHex: AppSetting.Color.blue)
        // center
        labelCategoryName.isHidden = false
        labelCategoryName.text = Localized.favorite
    }
    
    public func makeHeaderCategory(name: String){
        hideAll()
        // left
        btnBack.isHidden = false
        // center
        labelCategoryName.isHidden = false
        labelCategoryName.text = name
        // right
        btnSearch.isHidden = false
        btnFilter.isHidden = false
        constraintFilterWidth.constant = filterWidth
    }
    
    public func makeHeaderDetail(title: String){
        hideAll()
        // bg
        self.backgroundColor = UIColor.clear
        // center
        labelCategoryName.isHidden = false
        labelCategoryName.text = title
        labelCategoryName.alpha = 0
        
        // left
        btnBack.isHidden = false
    }
    
    func makeHeaderWebview(title: String?){
        hideAll()
        // bg
        self.backgroundColor = UIColor(netHex: AppSetting.Color.blue)
        // center
        labelCategoryName.isHidden = false
        labelCategoryName.text = title
        // left
        btnBack.isHidden = false
    }
    
    public func makeHeaderDetailReadmorePlace(name: String){
        hideAll()
        // left
        btnBack.isHidden = false
        // center
        labelCategoryName.isHidden = false
        labelCategoryName.text = name
    }
    
    func makeHeaderFilter(){
        hideAll()
        // left
        btnBack.isHidden = false
        // center
        labelCategoryName.isHidden = false
        labelCategoryName.text = Localized.filter
        // right
        btnReset.isHidden = false
    }
    
    // MARK: - actions
    @IBAction func actionOpenSetting(_ sender: AnyObject) {
        NotificationCenter.default.post(name: NotificationKey.openSettingMenu, object: nil)
    }
    
    @IBAction func actionSearch(_ sender: AnyObject) {
        if delegate != nil {
            delegate?.headerBarSearch()
        }
    }

    @IBAction func actionBack(_ sender: AnyObject) {
        if delegate != nil {
            delegate?.headerBarGoback()
        }
    }
    
    @IBAction func actionFilter(_ sender: AnyObject) {
        if delegate != nil {
            delegate?.headerBarFilter()
        }
    }
    
    @IBAction func actionReset(_ sender: Any) {
        if delegate != nil {
            delegate?.headerBarReset()
        }
    }
    
    
}
