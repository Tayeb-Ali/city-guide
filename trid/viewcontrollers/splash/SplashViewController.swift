//
//  SplashViewController.swift
//  trid
//
//  Created by Black on 12/5/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import FirebaseAuth

class SplashViewController: UIViewController {
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    // variables
    var listenerHandle: AuthStateDidChangeListenerHandle?
    var checkedLogin = false
    var moved = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // create animation "trid"
        labelName.text = Localized.AppFullName
        labelDescription.text = Localized.AppSlogan1
        
        // Check service
        self.autologin()
    }
    
    func autologin() {
        // auto login
        let info = AppState.getSignInInfo()
        var credential : AuthCredential?
        if info != nil {
            credential = info?.credential()
        }
        // có thể đã login hoặc login nhưng bị hết hạn session
        listenerHandle = Auth.auth().addStateDidChangeListener({auth, user in
            if self.checkedLogin {
                return
            }
            self.checkedLogin = true
            if user != nil {
                user!.reload(completion: {error in
                    if error != nil {
                        // something wrong, maybe user has been deleted
                        self.gotoLogin()
                    }
                    else{
                        if credential != nil {
                            // Reauth by credential. because maybe user was disabled
                            user?.reauthenticate(with: credential!) { error in
                                if error != nil {
                                    // remove current user
                                    AppState.currentUser = nil
                                    // An error happened.
                                    self.gotoLogin()
                                    // clear credential
                                    AppState.setSignInInfo(nil)
                                } else {
                                    self.continueWithUser(user!)
                                }
                            }
                        }
                        else{
                            self.continueWithUser(user!)
                        }
                    }
                })
            }
            else{
                self.gotoLogin()
            }
        })
    }
    
    func continueWithUser(_ user: User) {
        let fuser = FUser.userWith(firUser: user, loginProvider: user.providerID)
        fuser.fetchInBackground(finish: {e in
            if e != nil || fuser.snapshot == nil{
                self.gotoLogin()
            }
            else {
                if fuser.getInactive() {
                    self.gotoLogin()
                }
                else{
                    // #set-current-user
                    AppState.currentUser = fuser
                    // User re-authenticated
                    self.gotoMain()
                }
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if listenerHandle != nil {
            Auth.auth().removeStateDidChangeListener(listenerHandle!)
        }
        moved = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gotoLogin(){
        if moved {
            return
        }
        // remove current user
        AppState.currentUser = nil
        moved = true
        let controller = LoginViewController(nibName: "LoginViewController", bundle: nil)
        _ = self.navigationController?.pushViewController(controller, animated: false)
    }
    
    func gotoMain(){
        if moved {
            return
        }
        moved = true
        let controller = MainViewController()
        _ = self.navigationController?.pushViewController(controller, animated: false)
    }
    
}
