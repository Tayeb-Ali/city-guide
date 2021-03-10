//
//  AppStore.swift
//  trid
//
//  Created by Black on 9/30/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import Foundation

struct AppStoreKey {
    static let CityKey = "CityKey"
}

class AppStore: NSObject {
    static let shared = AppStore()
    
    // user default
    var userdefault : UserDefaults!
    
    override init(){
        super.init()
        self.userdefault = UserDefaults.standard
    }
    
    // save
    public func saveCityKey(_ key: String){
        var arr = self.userdefault.array(forKey: AppStoreKey.CityKey);
        if (arr == nil) {
            arr = [key]
        }
        else{
            var check = false
            for citykey in arr! {
                if key == (citykey as! String) {
                    check = true
                    break
                }
            }
            if !check {
                arr?.append(key)
            }
        }
        self.userdefault.set(arr, forKey: AppStoreKey.CityKey)
        self.userdefault.synchronize()
    }
    
    // load
    public func getCityKeys() -> Array<String> {
        let arr = self.userdefault.array(forKey: AppStoreKey.CityKey)
        return arr as! Array<String>
    }
    
    

}
