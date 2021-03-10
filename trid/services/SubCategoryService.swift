//
//  SubCategoryService.swift
//  trid
//
//  Created by Black on 9/30/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import Firebase

class SubCategoryService: NSObject {
    // Path to table
    static let path = "subcategory"
    // Singleton
    static let shared = SubCategoryService()
    
    // ref
    var ref : DatabaseReference!
    // data
    var dictSubcategory : [String: [FSubcategory]] = [:]
    
    // init
    override init() {
        super.init()
    }
    
    public func configureDatabase(finish: @escaping () -> Void) {
        // clear old data
        dictSubcategory.removeAll()
        // ref
        ref = Database.database().reference(withPath: SubCategoryService.path)
        ref.keepSynced(true)
        // remove all observe
        ref.removeAllObservers()
        // added
        ref.observe(.childAdded, with: { snapshot in
            let subpath = SubCategoryService.path + "/" + snapshot.key
            let dict = snapshot.value as! [String: Any]
            var subs = [FSubcategory]()
            for key in dict.keys {
                let sub = FSubcategory(path: subpath, objectId: key)
                sub.dictionary = dict[key] as! [String: Any]
                subs.append(sub)
            }
            self.dictSubcategory[snapshot.key] = subs
        })
        ref.observeSingleEvent(of: .value, with: {snapshot in
            debugPrint("DONE GET Subcategory")
            finish()
        })
    }
}
