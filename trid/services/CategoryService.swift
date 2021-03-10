//
//  CategoryService.swift
//  trid
//
//  Created by Black on 9/30/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class CategoryService: NSObject {
    // Path to table
    static let path = "category_info"
    // Singleton
    static let shared = CategoryService()
    
    // ref
    var ref : DatabaseReference!
    // data
    var categories : [FCategory] = []
    
    // init
    override init() {
        super.init()
    }
    
    public func configureDatabase(finish: @escaping () -> Void) {
        // remove old data
        categories.removeAll()
        // ref
        ref = Database.database().reference(withPath: CategoryService.path)
        ref.keepSynced(true)
        // remove all observe
        ref.removeAllObservers()
        // added
        ref.observe(.childAdded, with: {snapshot in
            let cat = FCategory(path: CategoryService.path, snapshot: snapshot)
            debugPrint("Category Priority = ", snapshot, cat.getPriority())
            self.categories.append(cat)
        })
        ref.observeSingleEvent(of: .value, with: {snapshot in
            debugPrint("DONE Category")
            finish()
        })
    }
    
    public func getCategoryType(fromKey key: String) -> FCategoryType? {
        guard let cat = categories.first(where: {$0.snapshot?.key == key}) else { return nil }
        return cat.getType()
    }
    
    func getCategoryKeyForType(_ type: FCategoryType) -> String? {
        guard let cat = categories.first(where: {$0.objectId != nil && $0.getType() == type}) else { return nil }
        return cat.objectId
    }
}
