//
//  Utils.swift
//  trid
//
//  Created by Black on 11/28/16.
//  Copyright © 2016 Black. All rights reserved.
//

import Foundation
import Firebase

enum MySignInError : Error {
    case UserInactive(String)
}

class Utils: NSObject {
    
    static let dateFormatter = DateFormatter()
    static let calendar = NSCalendar.current
    
    struct Formatter {
        static let number: NumberFormatter = NumberFormatter()
        static let date: DateFormatter = DateFormatter()
    }
    
    static func formatNumberString(_ num: NSString) -> String{
        Formatter.number.numberStyle = NumberFormatter.Style.decimal
        return Formatter.number.string(from: NSNumber(value: num.integerValue))!
    }
    
    static func formatNumber(_ num: Int) -> String{
        Formatter.number.numberStyle = NumberFormatter.Style.decimal
        return Formatter.number.string(from: NSNumber(value: num))!
    }
    
    // MARK: - Alert
    static func showAlert(title: String, message: String, inViewController vc: UIViewController){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Date
    static func getDayOfMonthSuffix(day n: Int) -> String{
        if (n >= 11 && n <= 13) {
            return "th"
        }
        switch (n % 10) {
            case 1:  return "st"
            case 2:  return "nd"
            case 3:  return "rd"
            default: return "th"
        }
    }
    
    static func openUrl(_ urlString: String?) {
        if urlString == nil {
            return
        }
        let url = URL(string: urlString!)!
        Utils.open(url: url)
    }
    
    static func call(phoneNumber: String){
        let s = "tel:".appending(phoneNumber).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let url = URL(string: s)!
        Utils.open(url: url)
    }
    
    static func open(url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    static func openMapDirection(place: FPlace){
        let latitute = place[FPlace.longitude] as? String ?? "0"
        let longitute = place[FPlace.latitude] as? String ?? "0"
        if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
            UIApplication.shared.openURL(URL(string:
                "comgooglemaps://?daddr=\(latitute),\(longitute)&views=traffic&directionsmode=driving")!)
        }
        else{
            let u = "http://maps.google.com/maps?daddr=\(latitute),\(longitute)"
            let url = URL(string: u)!
            Utils.open(url: url)
        }
    }
    
    static func openWeb(url: String, title: String, controller: UIViewController?, navigation: UINavigationController? = nil) {
        if controller == nil && navigation == nil {
            return
        }
        let web = WebViewController(nibName: "WebViewController", bundle: nil)
        web.webUrl = url
        web.webTitle = title
        if navigation != nil {
            navigation!.pushViewController(web, animated: true)
        }
        else {
            controller!.present(web, animated: true, completion: nil)
        }
    }
    
    // MARK: - ViewController
    static func viewController(_ vc: UIViewController, isSignUp: Bool, checkLoginWithCallback callback: (() -> Void)?) {
        // Check if not loged in -> Go to login page
        if AppState.currentUser == nil {
            let login = LoginViewController(nibName: "LoginViewController", bundle: nil)
            login.isModal = true
            login.isSignUpMode = isSignUp
            login.callback = {
                // Logged In
                if AppState.currentUser != nil {
                    AppLoading.showSuccess()
                    if callback != nil {
                        callback?()
                    }
                }
            }
            vc.present(login, animated: true, completion: nil)
        }
        else if callback != nil {
            callback!()
        }
    }
    
    static func checkActive(user: FUser) throws -> Bool {
        if user.checkUserActive() {
            return true
        }
        else{
            throw MySignInError.UserInactive(Localized.ThisUserWasDisabled)
        }
    }
    
    static func signInWith(user: FUser, signinInfo: SignInInfo) {
        // Check user info: inactive, uncommentable, ...
        do {
            let active = try Utils.checkActive(user: user)
            if (active){
                // send event
                MeasurementHelper.sendLoginEvent()
                // #set-current-user
                AppState.currentUser = user
                // handle
                NotificationCenter.default.post(name: NotificationKey.signedIn, object: signinInfo)
            }
        }
        catch {
            NotificationCenter.default.post(name: NotificationKey.signInError, object: error)
        }
    }
    
    // MARK: - In-app Purchase
    static func purchaseCity(_ c: FCity, viewcontroller: UIViewController){
        // Check connection
        if !TridService.shared.isOnline{
            viewcontroller.view.makeToast("Please check internet connection and try again")
            return
        }
        let id = c.getPurchaseId()
        AppLoading.showLoading()
        PurchaseManager.shared.fetchProductForCity(id: id, completed: {
            AppLoading.hideLoading()
            let vc = PurchaseViewController(nibName: "PurchaseViewController", bundle: nil)
            vc.city = c
            viewcontroller.present(vc, animated: true, completion: nil)
        })
    }
}
