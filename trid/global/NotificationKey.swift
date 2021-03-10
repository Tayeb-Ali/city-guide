//
//  NotificationKey.swift
//  trid
//
//  Created by Black on 11/28/16.
//  Copyright © 2016 Black. All rights reserved.
//

import Foundation

struct NotificationKey {
    // Sign-In
    static let signedIn = NSNotification.Name("Sign In")
    static let signedOut = NSNotification.Name("Sign Out")
    static let signInError = NSNotification.Name("signInError")
    
    // All City
    static let reloadCities = NSNotification.Name("reloadCities")
    
    // setting menu
    static let openSettingMenu = NSNotification.Name("openSettingMenu")
    
    // Tip
    static let placeUpdated : ((String) -> NSNotification.Name) = {k in
        return NSNotification.Name("placeUpdated" + k)
    }
    
    // Favorite
    static let favoriteAdded : ((String) -> NSNotification.Name) = {k in
        return NSNotification.Name("FavoriteAdded" + k)
    }
    static let favoriteDeleted : ((String) -> NSNotification.Name) = {k in
        return NSNotification.Name("FavoriteDeleted" + k)
    }
}
