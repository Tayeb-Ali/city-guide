//
//  DashboardBaseViewController.swift
//  trid
//
//  Created by Black on 9/27/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import Foundation
import PureLayout

class DashboardBaseViewController: MainBaseViewController {

    var tabbar: TridTabbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add footer
        tabbar = TridTabbar.createTabbar()
        self.view.addSubview(tabbar)
        tabbar.autoPinEdge(toSuperviewEdge: ALEdge.bottom)
        tabbar.autoPinEdge(toSuperviewEdge: ALEdge.leading)
        tabbar.autoPinEdge(toSuperviewEdge: ALEdge.trailing)
        tabbar.autoSetDimension(ALDimension.height, toSize: AppSetting.App.tabbarHeight)
        tabbar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabbar.checkSelectedTab()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func showPopupAddTip() {
        // Logged in -> Show popup add
        var title = Localized.NewTip
        if AppState.shared.currentCity != nil {
            title = Localized.AskAQuestionOrShareYourTips //Localized.TipFor + " " + AppState.shared.currentCity!.getName()
        }
        let popup = PopupAddTip.popupWith(title: title)
        popup.actionAdd = {text in
            popup.hide()
            if text == nil {
                self.view.makeToast(Localized.ContentIsEmpty)
            }
            else{
                // !!!
                // Add new tip
                let tip = FPlace.tipWithContent(text!)
                if tip != nil {
                    tip?.saveInBackground({e in
                        if e != nil {
                            self.view.makeToast(e!.localizedDescription)
                        }
                        else{
                            self.view.makeToast(Localized.Success)
                        }
                    })
                }
                else{
                    self.view.makeToast(Localized.SomethingWrong)
                }
            }
        }
        popup.show()
    }
}

extension DashboardBaseViewController : TridTabbarProtocol {
    func tabbarShowAskAndShare() {
        setTabbarIndex(2)
    }

    // MARK: - tabbar delegate
    func tabbarAdd() {
        // Check if not loged in -> Go to login page ELSE Perform action
        Utils.viewController(self, isSignUp: false, checkLoginWithCallback: {
            self.showPopupAddTip()
        })
    }
    
    func tabbarShowAllCities() {
        _ = self.tabBarController?.navigationController?.popViewController(animated: true)
    }
    
    func tabbarShowGuide() {
        setTabbarIndex(0)
    }
    
    func tabbarShowFavorite() {
        MeasurementHelper.openSavedTab()
        setTabbarIndex(1)
    }
    
    func setTabbarIndex(_ index: Int){
        if self.tabBarController?.selectedIndex != index {
            self.tabBarController?.selectedIndex = index
        }
        else{
            // already stay at index -> pop to root
            _ = self.navigationController?.popToRootViewController(animated: true)
        }
    }
}
