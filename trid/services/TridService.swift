//
//  TridService.swift
//  trid
//
//  Created by Black on 9/28/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class TridService: NSObject {
    // ref
    var storageRef: StorageReference!
    
    // Singleton
    static let shared = TridService()
    
    // Variable
    var isOnline = false
    var listenConnectionCheck : ((Bool) -> Void)?
    
    // init
    override init() {
        super.init()
        checkConnection()
    }
    
    func checkConnection() {
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            let connected = snapshot.value as? Bool ?? false
            self.isOnline = connected
            if self.listenConnectionCheck != nil {
                self.listenConnectionCheck!(connected)
            }
            debugPrint(connected ? "Connected" : "Not connected")
        })
    }
    
    public func makeFirebase(finish: @escaping () -> Void, updateProgress: @escaping (_ progress: CGFloat, _ total: CGFloat) -> Void){
        //let queuename = "getdata"
        var k1 = false
        var k2 = false
        var k3 = false
        var k4 = true
        var k5 = false
        let done : ((Int) -> Void) = {index in
            debugPrint("PROGRESS \(index)", k1, k2, k3, k4, k5)
            
            let percent = (CGFloat([k1, k2, k3, k4, k5].filter({$0 == true}).count))
            updateProgress(percent, 5)
            
            if k1 && k2 && k3 && k4 && k5 {
                debugPrint("Make firebase DONE")
                finish()
            }
        }
        // load language -> country -> city
        LanguageService.shared.configureDatabase(finish: {() -> Void in
            k5 = true
            done(5)
        })
        // load category
        CategoryService.shared.configureDatabase(finish: {() -> Void in
            k1 = true
            done(1)
        })
        // load sub-category
        SubCategoryService.shared.configureDatabase(finish: {() -> Void in
            k2 = true
            done(2)
        })
        // load facility
        FacilityService.shared.configureDatabase(finish: {() -> Void in
            k3 = true
            done(3)
        })
        // load all user
        UserService.shared.configureDatabase(finish: {
            k4 = true
            //done(4)
        })
        // config storage
        configureStorage()
    }
    
    private func configureStorage() {
        storageRef = Storage.storage().reference(forURL: "gs://" + (FirebaseApp.app()?.options.storageBucket)!) // trid-admin.appspot.com
    }
    
    
}
