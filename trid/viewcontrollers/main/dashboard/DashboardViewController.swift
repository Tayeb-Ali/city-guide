//
//  DashboardViewController.swift
//  trid
//
//  Created by Black on 9/27/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit

class DashboardViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // guide
        let guide = DiscoverViewController(nibName: "DiscoverViewController", bundle: nil)
        let navGuide = UINavigationController(rootViewController: guide)
        navGuide.isNavigationBarHidden = true
        
        // fav
        let favorite = SearchPlaceViewController(nibName: "SearchPlaceViewController", bundle: nil)
        favorite.isSearchPage = false
        let navFav = UINavigationController(rootViewController: favorite)
        navFav.isNavigationBarHidden = true
        
        // ask & share
        let ask = AskShareViewController(nibName: "AskShareViewController", bundle: nil)
        let navAsk = UINavigationController(rootViewController: ask)
        navAsk.isNavigationBarHidden = true
        
        // init
        self.viewControllers = [navGuide, navFav, navAsk]
        self.tabBar.isHidden = true
        
        // reset selected tab
        AppState.shared.selectedTab = 0
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

}
