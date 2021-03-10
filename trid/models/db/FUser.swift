//
//  FUser.swift
//  trid
//
//  Created by Black on 12/21/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import Foundation
import Firebase

class FUser: FObject {
    
    // KEY -----------------------------------------------------
    // user info
    static let name = "name"
    static let email = "email"
    static let avatar = "avatar"
    static let loginProvider = "loginProvider" // ex: "facebook.com|google.com|email"
    static let userId = "userId"
    // role info
    static let inactive = "inactive" // bool
    static let isAdmin = "isAdmin" // bool
    static let uncommentable = "uncommentable" // bool
    
    static let pushDeviceToken = "pushDeviceToken"
    static let FCMToken = "FCMToken"
    // -----------------------------------------------------
    
    
    // init
    convenience init(snapshot snap: DataSnapshot){
        self.init(path: UserService.path, snapshot: snap)
    }
    
    class func userWith(firUser u: User, loginProvider lp: String) -> FUser {
        let user = FUser(path: UserService.path, objectId: u.uid)
        user.snapshot = nil
        user.dictionary = [FUser.name : (u.displayName) ?? "",
                           FUser.email: (u.email) ?? "",
                           FUser.avatar: u.photoURL?.absoluteString ?? "",
                           FUser.loginProvider: lp,
                           FUser.userId: u.uid,
                           FUser.inactive: false,
                           FUser.isAdmin: false,
                           FUser.uncommentable: false,
                           FUser.pushDeviceToken: AppDelegate.deviceToken ?? "",
                           FUser.FCMToken: InstanceID.instanceID().token() ?? ""] as [String : Any]
        return user
    }
    
    // MARK: - Check
    func checkLoggedProvider(_ provider: String) -> Bool{
        let providers = self[FUser.loginProvider] as! String
        return providers.contains(provider)
    }
    
    // MARK: - GET
    func getInactive() -> Bool {
        return self[FUser.inactive] as? Bool ?? false
    }
    
    func getUserId() -> String? {
        return self[FUser.userId] as? String
    }
    
    func getName() -> String {
        return self[FUser.name] as? String ?? getEmail()
    }
    
    func getEmail() -> String {
        return self[FUser.email] as? String ?? ""
    }
    
    func getAvatar() -> String {
        return self[FUser.avatar] as? String ?? ""
    }
    
    func getCommentable() -> Bool {
        return !(self[FUser.uncommentable] as? Bool ?? false)
    }
    
    func checkUserActive() -> Bool {
        let inactive = self.getInactive()
        return !inactive
    }
    
    func checkAdmin() -> Bool {
        return self[FUser.isAdmin] as? Bool ?? false
    }
}



