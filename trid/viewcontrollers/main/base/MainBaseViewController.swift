//
//  MainBaseViewController.swift
//  trid
//
//  Created by Black on 9/30/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import PureLayout
import FirebaseDatabase

class MainBaseViewController: UIViewController {

    var header : TridHeaderBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // pop gesture
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        
        // add header
        if let header2 = Bundle.main.loadNibNamed("TridHeaderBar", owner: self, options: nil)?[0] as? TridHeaderBar {
            header = header2
            self.view.addSubview(header)
            header.autoPinEdge(toSuperviewEdge: ALEdge.top)
            header.autoPinEdge(toSuperviewEdge: ALEdge.leading)
            header.autoPinEdge(toSuperviewEdge: ALEdge.trailing)
            header.autoSetDimension(ALDimension.height, toSize: AppSetting.App.headerHeight)
            header.delegate = self
        }
        
        
        // remove header scrollview space
        self.automaticallyAdjustsScrollViewInsets = false
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
    
    // goto city
    func goto(city: FCity){
        AppState.shared.currentCity = city
        // load data for city
        var _progress = 0
        var isdone = false
        AppLoading.showLoading()
        let handlefinish = {() -> Void in
            _progress += 1
            if _progress >= 2 && !isdone{
                AppLoading.hideLoading()
                isdone = true
                // Save - Set available offline
                city.setAvailableOffline()
                // navigate to dashboard
                let dashboard = DashboardViewController()
                self.navigationController?.pushViewController(dashboard, animated: true)
            }
        }
        // place
        PlaceService.shared.configureDatabase(citykey: city.objectId!, finish: {()->Void in
            handlefinish()
        })
        // city-category
        CityCategoryService.shared.configureDatabase(citykey: city.objectId!, finish: { ()-> Void in
            handlefinish()
        })
    }
    
    // Header bar go back ipml
    func headerBarGoBackImpl() {
        if (self.navigationController != nil) {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func headerBarFilterImpl() {
        // for override
    }
    
    func headerBarResetImpl() {
        // for override
    }
    
    func headerBarSearchImpl() {
        if (self.navigationController != nil) {
            let controller = SearchPlaceViewController(nibName: "SearchPlaceViewController", bundle: nil)
            controller.setAllPlace(PlaceService.shared.places)
            _ = self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension MainBaseViewController : TridHeaderBarProtocol {
    // MARK: - TridHeaderBarProtocol
    func headerBarGoback() {
        headerBarGoBackImpl()
    }
    
    func headerBarSearch() {
        headerBarSearchImpl()
    }
    
    func headerBarFilter() {
        headerBarFilterImpl()
    }
    
    func headerBarReset() {
        headerBarResetImpl()
    }
}
