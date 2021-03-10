//
//  FFacility.swift
//  trid
//
//  Created by Black on 12/27/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit

class FFacility: FObject {
    // KEY -----------------------------------------------------
    static let name = "name"
    static let type = "type"
    // KEY -----------------------------------------------------
    
    func getType() -> Int {
        return self[FFacility.type] as? Int ?? 0
    }
    
    func getName() -> String {
        return self[FFacility.name] as? String ?? ""
    }
    
    func getIcon() -> String {
        let t = getType()
        switch (t){
        case 1:
            return "breakfast"
        case 2:
            return "parking"
        case 3:
            return "citymaps"
        case 4:
            return "Towels"
        case 5:
            return "wifi"
        case 6:
            return "internet"
        case 7:
            return "city_tour"
        case 8:
            return "linen"
        default:
            return ""
        }
    }
    
    static let iconForType = {(type: Int) -> String in
        switch (type){
        case 1:
            return "breakfast"
        case 2:
            return "parking"
        case 3:
            return "citymaps"
        case 4:
            return "Towels"
        case 5:
            return "wifi"
        case 6:
            return "internet"
        case 7:
            return "city_tour"
        case 8:
            return "linen"
        default:
            return ""
        }
    }
}
