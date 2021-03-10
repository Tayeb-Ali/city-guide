//
//  MainViewController.swift
//  trid
//
//  Created by Black on 9/27/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit

class MainViewController: SSASideMenu, SSASideMenuDelegate {
    // static
    static let menuWidth : Float = 235
    static let offsetX: Float = MainViewController.menuWidth - Float(AppSetting.App.screenSize.width/2.0)
    var menu : MenuViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        let allcities = AllCitiesViewController(nibName: "AllCitiesViewController", bundle: nil)
        let nav = UINavigationController(rootViewController: allcities)
        nav.isNavigationBarHidden = true
        self.contentViewController = nav
        menu = MenuViewController(nibName: "MenuViewController", bundle: nil)
        menu.delegate = self
        self.leftMenuViewController = menu
        self.configure(SSASideMenu.SideMenuOptions(type: .scale))
        self.configure(SSASideMenu.MenuViewEffect(fade: true,
                                                  scale: false,
                                                  scaleBackground: false,
                                                  parallaxEnabled: true))
        self.configure(SSASideMenu.ContentViewEffect(alpha: 1.0,
                                                     scale: 0.93,
                                                     landscapeOffsetX: 0,
                                                     portraitOffsetX: MainViewController.offsetX))
        self.configure(SSASideMenu.ContentViewShadow(enabled: true,
                                                     color: UIColor.black,
                                                     opacity: 0.3,
                                                     radius: 2.0))
        self.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         NotificationCenter.default.addObserver(self, selector: #selector(openSetting), name: NotificationKey.openSettingMenu, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Notification
    @objc func openSetting(n: Notification) {
        MeasurementHelper.openMenu()
        self._presentLeftMenuViewController()
    }
    
    func handleSignIn(_ isIn: Bool) {
        menu.handleSigned(out: !isIn)
    }
    
    // SSASideMenu delegate
    func sideMenuWillShowMenuViewController(_ sideMenu: SSASideMenu, menuViewController: UIViewController) {
        print("Will Show \(menuViewController)")
    }
    
    func sideMenuDidShowMenuViewController(_ sideMenu: SSASideMenu, menuViewController: UIViewController) {
        print("Did Show \(menuViewController)")
    }
    
    func sideMenuDidHideMenuViewController(_ sideMenu: SSASideMenu, menuViewController: UIViewController) {
        print("Did Hide \(menuViewController)")
    }
    
    func sideMenuWillHideMenuViewController(_ sideMenu: SSASideMenu, menuViewController: UIViewController) {
        print("Will Hide \(menuViewController)")
    }
    
    func sideMenuDidRecognizePanGesture(_ sideMenu: SSASideMenu, recongnizer: UIPanGestureRecognizer) {
        print("Did Recognize PanGesture \(recongnizer)")
    }

}

extension MainViewController : MenuViewControllerDelegate {
    func menuPopToSignIn() {
        popToLogin(isSignUp: false)
    }
    
    func menuPopToSignUp() {
        popToLogin(isSignUp: true)
    }
    
    func popToLogin(isSignUp: Bool){
        Utils.viewController(self, isSignUp: isSignUp, checkLoginWithCallback: {
            // Không cần handle callback vì Menu đã register Notification rồi
            // self.menu.handleSigned(out: AppState.currentUser == nil)
        })
    }
}
