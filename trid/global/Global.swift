//
//  Global.swift
//  trid
//
//  Created by Black on 10/10/16.
//  Copyright © 2016 Black. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class Global : NSObject {
    // Default
    static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    static var isRabitPhone: Bool {
        return UIScreen.main.bounds.height >= 812.0
    }
    
    // MARK: - Feedback
    static let shared = Global()
    static func sendFeedback(controller: UIViewController){
        let mail = AppSetting.App.email
        if MFMailComposeViewController.canSendMail() {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = Global.shared
            composeVC.setToRecipients([mail])
            composeVC.setSubject("\(AppSetting.App.name) Feedback")
            composeVC.setMessageBody("", isHTML: false)
            controller.present(composeVC, animated: true, completion: nil)
        }
        else{
            // send by gmail
            GmailManager.shared.composeMailTo(email: mail, name: AppSetting.App.name, viewController: controller)
        }
    }
    
    // MARK: - Rate app
    static func openRateApp(){
        let url = URL(string : AppSetting.App.iOSAppStoreURLFormat + AppSetting.App.appStoreId)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }

}

extension Global : MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?){
        // Check the result or perform other tasks.
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
