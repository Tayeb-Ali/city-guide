//
//  FCategory.swift
//  trid
//
//  Created by Black on 12/27/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit

enum FCategoryType : Int{
    case Sleep = 1
    case Eat = 2
    case NightLight = 3
    case SeeAndDo = 4
    case Activity = 5
    case Shopping = 6
    case Tours = 7
    case Transport = 8
    case Stories = 9
    case CityInfo = 10
    case Tips = 11
    case Emergency = 12
    case Events = 13
    case Drink = 14
}

class FCategory: FObject {
    
    // - Static variables
    static let DisplayTypes = [FCategoryType.Sleep,
                               FCategoryType.Eat,
                               FCategoryType.NightLight,
                               FCategoryType.SeeAndDo,
                               FCategoryType.Activity,
                               FCategoryType.Shopping,
                               FCategoryType.Tours,
                               FCategoryType.Stories,
                               FCategoryType.Tips,
                               FCategoryType.Drink]
    
    // KEY -----------------------------------------------------
    static let name = "name"
    static let type = "type"
    static let count = "count"
    static let priority = "priority"
    static let priceUnit = "priceUnit"
    // KEY -----------------------------------------------------
    
    
    // MARK: - GET
    func getName() -> String {
        return (self[FCategory.name] as? String) ?? ""
    }
    
    func getPriority() -> Int {
        let p = self[FCategory.priority]
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
    
    func getType() -> FCategoryType? {
        return FCategoryType(rawValue: self[FCategory.type] as! Int)
    }
    
    func getColor() -> UIColor {
        let type = self.getType()
        return UIColor(netHex: FCategory.colorForType(type))
    }
    
    func getSubcategories() -> [FSubcategory]? {
        return SubCategoryService.shared.dictSubcategory[self.objectId!]
    }
    
    func getPriceUnit() -> String {
        let p = self[FCategory.priceUnit] as? String
        if p != nil {
            return "/" + p!
        }
        return ""
    }
    
    // MARK: - CHECK
    func isSleepCategory() -> Bool {
        return self.getType() == FCategoryType.Sleep
    }
    
    func isCityInfoCategory() -> Bool {
        return self.getType() == FCategoryType.CityInfo
    }
    
    // Static method
    static let iconForType = {(type: FCategoryType?) -> String in
        if type == nil {
            return ""
        }
        var icon : String
        switch (type!){
        case .Sleep:
            icon = "cat-sleep"
            break
        case .Eat:
            icon = "cat-eat"
            break
        case .NightLight:
            icon = "cat-nightlife"
            break
        case .SeeAndDo:
            icon = "cat-see"
            break
        case .Activity:
            icon = "cat-activities"
            break
        case .Shopping:
            icon = "cat-shopping"
            break
        case .Transport:
            icon = "cat-transpot"
            break
        case .Stories:
            icon = "cat-stories"
            break
        case .CityInfo:
            icon = "cat-cityinfo"
            break
        case .Emergency:
            icon = "cat-emergency"
            break
        case .Events:
            icon = "cat-events"
            break
        case .Drink:
            icon = "cat-drink"
            break
        default:
            icon = ""
            break
        }
        return icon
    }
    
    static func colorForType(_ t: FCategoryType?) -> Int {
        if t == nil {
            return AppSetting.Color.blue
        }
        switch (t!){
        case .Sleep:
            return AppSetting.Color.blue
        case .Eat:
            return AppSetting.Color.orange
        case .NightLight:
            return AppSetting.Color.pink
        case .SeeAndDo:
            return AppSetting.Color.deepOrange
        case .Activity:
            return AppSetting.Color.cyan
        case .Shopping:
            return AppSetting.Color.violet
        case .Transport:
            return AppSetting.Color.deepYellow
        case .Stories:
            return AppSetting.Color.darkPeach
        case .CityInfo:
            return AppSetting.Color.brown
        case .Emergency:
            return AppSetting.Color.lightGreen
        case .Events:
            return AppSetting.Color.yellow
        case .Drink:
            return AppSetting.Color.green
        default:
            return AppSetting.Color.blue
        }
    }
    
    
}
