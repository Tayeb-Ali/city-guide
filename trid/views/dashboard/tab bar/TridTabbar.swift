//
//  TridTabbar.swift
//  trid
//
//  Created by Black on 9/27/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import PureLayout

protocol TridTabbarProtocol {
    func tabbarShowAllCities()
    func tabbarShowGuide()
    func tabbarShowFavorite()
    func tabbarAdd()
    func tabbarShowAskAndShare()
}

class TridTabbar: UIView {
    // delegate
    var delegate : TridTabbarProtocol?
    
    // outlet
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var btnAddTip: UIButton!
    
    //var btnAllCities: TabbarButton!
    var btnGuide: TabbarButton!
    var btnFavorite: TabbarButton!
    var btnAskShare: TabbarButton!
    
    class func createTabbar() -> TridTabbar{
        let tab = UINib(nibName: "TridTabbar", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? TridTabbar
        return tab!;
    }
    
    override func awakeFromNib() {
        // calculate
        var tabwidth : CGFloat = (AppSetting.App.screenSize.width)/5
        if tabwidth < 80 {
            tabwidth = 70
        }
        else if tabwidth > 90 {
            tabwidth = 90
        }
        
        // Add TIP
        btnAddTip.setTitle(Localized.Ask, for: .normal)
        btnAddTip.layer.cornerRadius = btnAddTip.bounds.height/2.0
        btnAddTip.layer.shadowRadius = 2
        btnAddTip.layer.shadowColor = UIColor(hex6: UInt32(AppSetting.Color.veryLightGray), alpha: 0.3).cgColor
        
        // 31/08/17 Change design by Mr.Tho require
//        // cities
//        self.btnAllCities = TabbarButton.initWithTitle(Localized.AllCities, image: "tab-allcities", imageSelected: "tab-allcities-active")
//        btnAllCities.backgroundColor = .clear
//        self.viewContent.addSubview(self.btnAllCities)
        
        // explore
        self.btnGuide = TabbarButton.initWithTitle(Localized.Explore, image: "tab-guide", imageSelected: "tab-guide-active")
        btnGuide.backgroundColor = .clear
        self.viewContent.addSubview(self.btnGuide)
        
        // fav
        self.btnFavorite = TabbarButton.initWithTitle(Localized.Saved, image: "tab-fav", imageSelected: "tab-fav-active")
        btnFavorite.backgroundColor = .clear
        self.viewContent.addSubview(self.btnFavorite)
        
        // ask and share
        self.btnAskShare = TabbarButton.initWithTitle(Localized.AskShare, image: "tab-ask", imageSelected: "tab-ask-active")
        btnAskShare.backgroundColor = .clear
        self.viewContent.addSubview(self.btnAskShare)
        
        // - Constraint
//        // cities
//        btnAllCities.addTarget(self, action: #selector(TridTabbar.actionAllCities), for: UIControlEvents.touchUpInside)
//        btnAllCities.tag = -1
//        btnAllCities.autoPinEdge(toSuperviewEdge: ALEdge.leading, withInset: 10)
//        btnAllCities.autoPinEdge(toSuperviewEdge: ALEdge.top)
//        btnAllCities.autoPinEdge(toSuperviewEdge: ALEdge.bottom)
//        btnAllCities.autoSetDimension(ALDimension.width, toSize: tabwidth)
        
        // guide
        btnGuide.addTarget(self, action: #selector(TridTabbar.actionTabGuide), for: UIControl.Event.touchUpInside)
        btnGuide.isSelected = true
        btnGuide.tag = 0
        btnGuide.autoPinEdge(toSuperviewEdge: ALEdge.leading, withInset: 5)
        btnGuide.autoPinEdge(toSuperviewEdge: ALEdge.top)
        btnGuide.autoPinEdge(toSuperviewEdge: ALEdge.bottom)
        btnGuide.autoSetDimension(ALDimension.width, toSize: tabwidth)
        
        // fav
        btnFavorite.addTarget(self, action: #selector(TridTabbar.actionFavorite), for: UIControl.Event.touchUpInside)
        btnFavorite.tag = 1
        self.btnFavorite.autoPinEdge(ALEdge.leading, to: ALEdge.trailing, of: self.btnGuide)
        self.btnFavorite.autoPinEdge(toSuperviewEdge: ALEdge.top)
        self.btnFavorite.autoPinEdge(toSuperviewEdge: ALEdge.bottom)
        btnFavorite.autoSetDimension(ALDimension.width, toSize: tabwidth)
        
        // ask
        btnAskShare.addTarget(self, action: #selector(TridTabbar.actionAskAndShare), for: UIControl.Event.touchUpInside)
        btnAskShare.tag = 2
        self.btnAskShare.autoPinEdge(ALEdge.leading, to: ALEdge.trailing, of: self.btnFavorite)
        self.btnAskShare.autoPinEdge(toSuperviewEdge: ALEdge.top)
        self.btnAskShare.autoPinEdge(toSuperviewEdge: ALEdge.bottom)
        btnFavorite.autoSetDimension(ALDimension.width, toSize: tabwidth)
        
        // set selected tab
        selectedOnTab(index: AppState.shared.selectedTab)
    }
    
    // Actions
    @IBAction func actionAddTip(_ sender: Any) {
        if delegate != nil {
            delegate?.tabbarAdd()
        }
    }
    
    @objc func actionTabGuide(_ sender: AnyObject) {
        selectedOnTab(index: btnGuide.tag)
        delegate?.tabbarShowGuide()
    }
    
    @objc func actionFavorite(_ sender: AnyObject) {
        selectedOnTab(index: btnFavorite.tag)
        delegate?.tabbarShowFavorite()
    }
    
    func actionAllCities(_ sender: AnyObject) {
        delegate?.tabbarShowAllCities()
    }
    
    @objc func actionAskAndShare(_ sender: AnyObject) {
        selectedOnTab(index: btnAskShare.tag)
        delegate?.tabbarShowAskAndShare()
    }
    
    func selectedOnTab(index: Int){
        AppState.shared.selectedTab = index
        btnGuide.isSelected = index == btnGuide.tag
        btnFavorite.isSelected = index == btnFavorite.tag
        //btnAllCities.isSelected = index == btnAllCities.tag
        btnAskShare.isSelected = index == btnAskShare.tag
    }
    
    public func checkSelectedTab(){
        // set selected tab
        selectedOnTab(index: AppState.shared.selectedTab)
    }
    
}
