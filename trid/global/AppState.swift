//
//  AppState.swift
//  trid
//
//  Created by Black on 9/28/16.
//  Copyright © 2016 Black. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseRemoteConfig

class AppState : NSObject{
    static let shared = AppState()
    
    // MARK: - Login session
    static var currentUser : FUser?
    
    // MARK: - TAB
    var selectedTab : Int = 0
    
    // MARK: - CITY
    var favoritedList : [String]?
    
    static func getCities() -> [FCity] {
        let isAdmin = AppState.currentUser != nil && AppState.currentUser!.checkAdmin()
        return CityService.shared.cities.filter({$0.getDeactived() == false || isAdmin})
    }
    
    fileprivate var _currentCity : FCity?
    var currentCity : FCity? {
        set {
            _currentCity = newValue
            if newValue == nil {
                favoritedList = nil
            }
            else{
                favoritedList = AppState.getCurrentCityFavoritedList()
            }
        }
        get{
            return _currentCity
        }
    }
    
    static func clearCurrentCity() {
        AppState.shared.currentCity = nil
    }
    
    // MARK: - PLACE
    var placesForCurrentCategory : [FPlace]?
    
    // MARK: - CATEGORY
    var currentCategory: FCategory?
    
    // INIT
    override init() {
        
    }
    
    // MARK: - Static Category
    static func clearCurrentCategory(){
        shared.currentCategory = nil
        shared.placesForCurrentCategory = nil
    }
    
    static func getCurrentColor() -> UIColor {
        return shared.currentCategory != nil ? (shared.currentCategory?.getColor())! : UIColor(netHex: AppSetting.Color.blue)
    }
    
    static func getCurrentCategoryType() -> FCategoryType? {
        return shared.currentCategory != nil ? (shared.currentCategory?.getType())! : nil
    }
    
    static func currentCategoryIsSleep() -> Bool {
        return shared.currentCategory != nil && (shared.currentCategory?.isSleepCategory())!
    }
    
    static func currentSubCategoryList() -> [FSubcategory]  {
        return shared.currentCategory != nil ? (shared.currentCategory?.getSubcategories())! : [FSubcategory]()
    }
    
    static func getCategory(forType type: FCategoryType) -> FCategory? {
        return CityCategoryService.shared.categoriesOfCurrentCity.first(where: {c in
            return c.getType() == type
        })
    }
    
    // MARK: - Userdefault - save something
    // signin info
    static func setSignInInfo(_ info : SignInInfo?){
        if info != nil {
            let data = NSKeyedArchiver.archivedData(withRootObject: info!)
            UserDefaults.standard.set(data, forKey: "testtesttests123123123")
        }
        else{
            UserDefaults.standard.set(nil, forKey: "testtesttests123123123")
        }
        UserDefaults.standard.synchronize()
    }
    
    static func getSignInInfo() -> SignInInfo? {
        let data = UserDefaults.standard.object(forKey: "testtesttests123123123")
        if data != nil {
            let info = NSKeyedUnarchiver.unarchiveObject(with: data as! Data)
            return info as? SignInInfo
        }
        return nil
    }
    
    // MARK: - FAVORITE
    // Add
    static func addFavorite(place: FPlace, finish: (() -> Void)?){
        if place.objectId == nil {
            return
        }
        if shared.favoritedList == nil {
            shared.favoritedList = [String]()
        }
        MeasurementHelper.actionSavedPlace(city: shared.currentCity?.getName() ?? "NULL")
        // current list
        if !(shared.favoritedList?.contains(where: {$0 == place.objectId!}))! {
            shared.favoritedList?.insert(place.objectId!, at: 0)
            // notify
            NotificationCenter.default.post(name: NotificationKey.favoriteAdded(""), object: place)
            NotificationCenter.default.post(name: NotificationKey.favoriteAdded(place.objectId!), object: place)
            // save
            UserDefaults.standard.set(shared.favoritedList, forKey: UserDefaultKey.favoritedList(shared.currentCity!.objectId!))
            if finish != nil {
                finish!()
            }
        }
    }
    
    // Get
    static func getCurrentCityFavoritedList() -> [String]? {
        if shared.currentCity != nil {
            let data = UserDefaults.standard.object(forKey: UserDefaultKey.favoritedList(shared.currentCity!.objectId!))
            if data != nil {
                return data as? [String]
            }
        }
        return nil
    }
    
    // Remove
    static func removeFavorited(place: FPlace, finish: (() -> Void)?){
        if place.objectId == nil || shared.favoritedList == nil || shared.favoritedList!.count == 0
            || shared.currentCity == nil {
            return
        }
        let index = shared.favoritedList?.firstIndex(where: {$0 == place.objectId!})
        if index != nil && index! >= 0 && index! < shared.favoritedList!.count{
            shared.favoritedList?.remove(at: index!)
            // notify
            NotificationCenter.default.post(name: NotificationKey.favoriteDeleted(""), object: place)
            NotificationCenter.default.post(name: NotificationKey.favoriteDeleted(place.objectId!), object: place)
            // save
            UserDefaults.standard.set(shared.favoritedList, forKey: UserDefaultKey.favoritedList((shared.currentCity?.objectId)!))
            
            if finish != nil {
                finish!()
            }
        }
    }
    
    static func checkFavorited(ofPlace p: FPlace) -> Bool {
        if shared.favoritedList == nil || (shared.favoritedList?.count)! == 0 {
            return false
        }
        return shared.favoritedList!.firstIndex(where: {p.objectId != nil && $0 == p.objectId}) != nil
    }
    
    
    // MARK: - GET SET NUMBER OF TIMES OPEN APP
    static func getTimesOpenApp() -> Int {
        return UserDefaults.standard.integer(forKey: UserDefaultKey.timesOpenApp) 
    }
    
    static func setNewTimesOpenApp() -> Int {
        let t = AppState.getTimesOpenApp() + 1
        UserDefaults.standard.set(t, forKey: UserDefaultKey.timesOpenApp)
        UserDefaults.standard.synchronize()
        return t
    }
    
    
    // MARK: - Firebase remote config
    static var remoteConfig : RemoteConfig?
//    static func checkVisaHomeShow() -> Bool {
//        let show = remoteConfig![FBConfigKey.visaHomeShow].stringValue
//        return show == "yes"
//    }
    
    static func checkVisaTabShow() -> Bool {
        let show = remoteConfig![FBConfigKey.visaTabShow].stringValue
        return show == "yes"
    }
    
    
}
