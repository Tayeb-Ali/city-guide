//
//  FCity.swift
//  trid
//
//  Created by Black on 12/27/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import Firebase

enum FCityState : Int {
    case Free = 0
    case Paid = 1
    case Purchased = 2
    case Offline = 3
}

class FCity: FObject {
    // KEY -----------------------------------------------------
    static let name = "name"
    static let intro = "intro"
    static let photourl = "photourl"
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let zoom = "zoom"
    static let priority = "priority"
    static let weatherUrl = "weatherUrl"
    static let purchaseId = "applePurchaseId"
    static let videoIntroUrl = "videoIntroUrl"
    static let deactived = "deactived"
    // banner
    static let bannerUrl = "bannerUrl"
    static let bannerPhotoUrl = "bannerPhotoUrl"
    // KEY -----------------------------------------------------
    
    // Variables
    var weather : FWeather?
    
    // Banner
    func getBannerUrl() -> String? {
        return self[FCity.bannerUrl] as? String
    }
    
    func getBannerPhoto() -> String? {
        return self[FCity.bannerPhotoUrl] as? String
    }
    
    // MARK: - Get city info
    func getVideoIntroUrl() -> String? {
//        return "https://video.xx.fbcdn.net/v/t43.1792-2/18297340_460689054274572_5965548422676086784_n.mp4?efg=eyJybHIiOjE1MDAsInJsYSI6Mzc0MCwidmVuY29kZV90YWciOiJzdmVfaGQifQ%3D%3D&rl=1500&vabr=877&oh=42b063788c2bad55efef31ca55947647&oe=591BC782"
        return self[FCity.videoIntroUrl] as? String
    }
    
    func getName() -> String{
        return dictionary[FCity.name] as? String ?? ""
    }
    
    func getPurchaseId() -> String {
        return self[FCity.purchaseId] as? String ?? ""
    }
    
    func getState() -> FCityState {
        if getAvailableOffline() {
            return .Offline
        }
        if checkPurchased() {
            return.Purchased
        }
        let id = getPurchaseId()
        if id == "" {
            return .Free
        }
        return .Paid
    }
    
    func getPriority() -> Int {
        let p = self[FCity.priority]
        if p != nil {
            if p is NSNumber {
                return (p as! NSNumber).intValue
            }
            if p is Int {
                return p as! Int
            }
            if p is String {
                return Int(p as! String)!
            }
        }
        return  0
    }
    
    func getIntro() -> String{
        return dictionary[FCity.intro] as? String ?? ""
    }
    
    func getLongitute() -> Double {
        return self[FCity.longitude] != nil ? (self[FCity.longitude] as! NSString).doubleValue : 0
    }
    
    func getLatitude() -> Double {
        return self[FCity.latitude] != nil ? (self[FCity.latitude] as! NSString).doubleValue : 0
    }
    
    func getZoom() -> Float {
        return self[FCity.zoom] != nil ? (self[FCity.zoom] as! NSString).floatValue : 0.0
    }
    
    func getPhotoUrl() -> String {
        return self[FCity.photourl] as? String ?? ""
    }
    
    func getWeatherConditionsApi() -> String? {
        let long = self.getLongitute()
        let lat = self.getLatitude()
        if long == 0 || lat == 0 {
            return nil
        }
        return AppSetting.Weather.buildConditionApi(lat: lat, long: long)
    }
    
    func getWeatherForecastApi() -> String? {
        let long = self.getLongitute()
        let lat = self.getLatitude()
        if long == 0 || lat == 0 {
            return nil
        }
        return AppSetting.Weather.buildForecastApi(lat: lat, long: long)
    }
    
    func getDeactived() -> Bool {
        return self[FCity.deactived] as? Bool ?? false
    }
    
    // MARK: - Utility functions
    // MARK: - Check available offline by id
    func setAvailableOffline(){
        if objectId == nil {
            return
        }
        UserDefaults.standard.set(true, forKey: objectId!)
        UserDefaults.standard.synchronize()
    }
    
    func getAvailableOffline() -> Bool {
        if objectId == nil {
            return false
        }
        let offline = UserDefaults.standard.object(forKey: objectId!)
        return offline as? Bool ?? false
    }
    
    func setPurchased(){
        let id = getPurchaseId()
        if id != "" {
            PurchaseManager.savePurchasedItem(id: id)
        }
    }
    
    func checkPurchased() -> Bool {
        let id = getPurchaseId()
        return PurchaseManager.checkPurchasedItem(id: id)
    }
}
