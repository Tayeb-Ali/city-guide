//
//  MailComposeViewController.swift
//  KidsPlay
//
//  Created by Black on 12/17/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import Toast_Swift

class MailComposeViewController: UIViewController {
    
    // outlet
    @IBOutlet weak var viewStatusBarBg: UIView!
    // header
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    // to
    @IBOutlet weak var labelTo: UILabel!
    @IBOutlet weak var labelToEmail: UILabel!
    
    // subject
    @IBOutlet weak var tfSubject: UITextField!
    
    // content
    @IBOutlet weak var tvContent: UITextView!
    
    // variables
    var callbackCancel : (() -> Void)?
    var callbackSend : ((String, String) -> Void)?
    var email : String?
    var name : String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // localized
        btnSend.setTitle(Localized.Send, for: UIControl.State.normal)
        btnCancel.setTitle(Localized.Dismiss, for: UIControl.State.normal)
        labelToEmail.text = name != nil ? (name ?? "") : ("<" + (email ?? "") + ">")
        labelTitle.text = "Compose"
        tfSubject.text = "Feedback"
        // view
        viewStatusBarBg.backgroundColor = UIColor(netHex: AppSetting.Color.blue)
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
    
    // MARK: - Actions
    @IBAction func actionSend(_ sender: Any) {
        if email == nil {
            return
        }
        let subject = tfSubject.text ?? "No title"
        let content = tvContent.text
        if content == nil {
            self.view.makeToast(Localized.PleaseWriteSomething)
            return
        }
        if callbackSend != nil {
            callbackSend?(subject, content!)
        }
    }
    
    @IBAction func actionCancel(_ sender: Any) {
        if callbackCancel != nil {
            callbackCancel?()
        }
    }
    
    
    
}

extension MailComposeViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        tvContent.becomeFirstResponder()
        return true
    }
}

extension MailComposeViewController : UITextViewDelegate {
    
}



