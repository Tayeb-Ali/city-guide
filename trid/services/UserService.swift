//
//  UserService.swift
//  trid
//
//  Created by Black on 11/30/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class UserService: NSObject {
    // Path to table
    static let path = "users"
    
    // ref
    var ref : DatabaseReference!
    fileprivate var _refHandle: DatabaseHandle!
    
    // data
    var users : [FUser] = []
    
    // Singleton
    static let shared = UserService()
    
    // init
    override init() {
        super.init()
        debugPrint("Init UserService")
        ref = Database.database().reference(withPath: UserService.path)
        ref.keepSynced(true)
    }
    
    // MARK: - init database
    public func configureDatabase(finish: @escaping () -> Void) {
        debugPrint("Get Users")
        // remove old data
        users.removeAll()
        // -------------------------------
        // remove all observe
        ref.removeAllObservers()
        ref.observe(.childAdded, with: { (snapshot) -> Void in
            // parse user
            let u = FUser(snapshot: snapshot)
            self.users.append(u)
        })
        ref.observeSingleEvent(of: .value, with: {(snapshot) -> Void in
            debugPrint("DONE GET USER", self.users.count, "users")
            finish()
        })
    }
    
    // MARK: - Add User
    public func addUser(_ user: User?, loginProvider s: String){
        if user == nil || user?.uid == nil || user?.displayName == nil || user?.email == nil{
            debugPrint("Can not add user")
            return
        }
        let fu = FUser.userWith(firUser: user!, loginProvider: s)
        fu.saveInBackground()
    }
    
    // MARK: - Query
    static func getUser(withId uId: String) -> FUser? {
        return shared.users.first(where: {$0[FUser.userId] != nil && ($0[FUser.userId] as! String) == uId})
    }
    
    static func getUserWithEmail(_ email: String?) -> FUser? {
        if email ?? "" == "" {
            return nil
        }
        return shared.users.first(where: {$0.getEmail() == email})
    }
    
}
