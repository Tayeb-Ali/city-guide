//
//  FObject.swift
//  trid
//
//  Created by Black on 12/21/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import Firebase

class FObject: NSObject {
    
    // KEY -----------------------------------------------------
    static let createdAt = "createdAt"
    static let updatedAt = "updatedAt"
    // KEY -----------------------------------------------------}
    
    // Object Path
    var path: String!
    var objectId: String?
    // Data
    var snapshot: DataSnapshot?
    var dictionary : [String:Any] = [:]

    // MARK: - Init
    override init() {
        super.init()
    }
    
    convenience init(path p: String, objectId k: String? = nil) {
        self.init()
        path = p
        objectId = k
    }
    
    convenience init(path p: String, snapshot snap: DataSnapshot) {
        self.init(path: p, objectId: snap.key)
        snapshot = snap
        dictionary = snap.value as! [String : Any]
    }
    
    // MARK: - generate database reference
    func databaseReference() -> DatabaseReference {
        var reference = Database.database().reference(withPath: path)
        if objectId == nil{
            reference = reference.childByAutoId()
            objectId = reference.key
            return reference
        }
        return reference.child(objectId!)
    }
    
    // MARK: - override Dictionary
    subscript(key: String) -> Any? {
        get{
            return dictionary[key]
        }
        set{
            dictionary[key] = newValue
        }
    }
    
    // MARK: - Get methods
    func getDateTime() -> Date {
        let created = self[FObject.createdAt] as? TimeInterval
        let updated = self[FObject.updatedAt] as? TimeInterval
        let date = created != nil ? Date(timeIntervalSince1970: created!) : (updated != nil ? Date(timeIntervalSince1970: updated!): Date())
        return date
    }
    
    func getUpdatedTime() -> Date? {
        let created = self[FObject.createdAt] as? TimeInterval
        let updated = self[FObject.updatedAt] as? TimeInterval
        if created == nil && updated == nil {
            return nil
        }
        return updated != nil ? Date(timeIntervalSince1970: updated!) : Date(timeIntervalSince1970: created!)
    }
    
    // MARK: - Save method
    func saveInBackground(_ block: ((Error?) -> Void)? = nil){
        // Chỗ này nếu check currentUser != nil thì phải để ý trường hợp save sign up info
        let ref = self.databaseReference()
        // time
        let interval = Date().timeIntervalSince1970
        if dictionary[FObject.createdAt] == nil {
            dictionary[FObject.createdAt] = interval
        }
        dictionary[FObject.updatedAt] = interval
        // Save/Update
        ref.updateChildValues(dictionary, withCompletionBlock: {error, dataRef in
            if block != nil {
                block?(error)
            }
        })
    }
    
    // MARK: - Delete method - Be careful when use this method
    func deleteInBackground(_ block: ((Error?) -> Void)? = nil){
        let ref = self.databaseReference()
        ref.removeValue(completionBlock: {error, dataRef in
            if block != nil {
                block?(error)
            }
            if error != nil {
                debugPrint(error?.localizedDescription ?? "")
            }
            else {
                debugPrint("DELETED", dataRef.key ?? "")
            }
        })
    }
    
    // MARK: - Fetch method
    func fetchInBackground(finish: ((Error?) -> Void)? = nil){
        let ref = self.databaseReference()
        ref.observeSingleEvent(of: .value, with: {snap in
            var error : Error?
            if snap.exists() {
                self.snapshot = snap
                self.dictionary = snap.value as! [String: Any]
                error = nil
            }
            else{
                self.snapshot = nil
                error = NSError(domain: Bundle.main.bundleIdentifier!, code: 100, userInfo: nil) as Error
            }
            if finish != nil {
                finish?(error)
            }
        }, withCancel: {error in
            self.snapshot = nil
            if finish != nil {
                finish?(error)
            }
        })
    }
    
    
    
    
}
