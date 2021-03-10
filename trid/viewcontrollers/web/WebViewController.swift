//
//  WebViewController.swift
//  trid
//
//  Created by Black on 3/10/17.
//  Copyright © 2017 Black. All rights reserved.
//

import UIKit

class WebViewController: MainBaseViewController {

    @IBOutlet weak var webview: UIWebView!
    
    // Var
    var webTitle : String?
    var webUrl : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        header.makeHeaderWebview(title: webTitle)
        // load
        if webUrl != nil {
            webview.loadRequest(URLRequest(url: URL(string: webUrl!)!))
        }
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
    
    override func headerBarGoBackImpl() {
        if self.presentingViewController != nil {
            self.dismiss(animated: true, completion: nil)
        }
        else if let nav = self.navigationController, nav.viewControllers.count > 1 {
            super.headerBarGoBackImpl()
        }
    }

}
