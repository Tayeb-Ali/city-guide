//
//  FCityCategory.swift
//  trid
//
//  Created by Black on 12/27/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit

class FCityCategory: FObject {
    // KEY -----------------------------------------------------
    static let categorykey = "category_key"
    static let order = "order"
    // KEY -----------------------------------------------------
    
    func getCategoryKey() -> String? {
        return self[FCityCategory.categorykey] as? String
    }
    
    func getOrder() -> Int {
        return Int(self[FCityCategory.order] as? String ?? "0") ?? 0
    }
    
    
}
