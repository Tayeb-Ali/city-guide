//
//  FSubcategory.swift
//  trid
//
//  Created by Black on 12/27/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import Firebase

class FSubcategory: FObject {
    
    // HARD CODE
    static let TipUser = "-Kdjnh1gwHPXYRRTQuIg" // Dev: "-KdjpEvGoGrCg0_ejxHc"
    static let TipAdmin = "-KdjniTnpvjaBGV3h9KR" // 
    
    // KEY -----------------------------------------------------
    static let name = "name"
    // KEY -----------------------------------------------------
    
    // variables
    // for filter
    var resultCount = 0
    var selected = false
    
    func getName() -> String? {
        return dictionary[FSubcategory.name] as? String
    }
}
