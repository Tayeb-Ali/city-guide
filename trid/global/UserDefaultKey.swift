//
//  UserDefaultKey.swift
//  trid
//
//  Created by Black on 3/13/17.
//  Copyright © 2017 Black. All rights reserved.
//

import UIKit

struct UserDefaultKey {
    // Favorite
    static let favoritedList : ((String) -> String) = {key in
        return "FavoritedList" + key
    }
    
    // Time use app
    static let timesOpenApp = "timesOpenApp"
    
    
}
