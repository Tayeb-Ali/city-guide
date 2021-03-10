//
//  FCountry.swift
//  trid
//
//  Created by Black on 1/4/17.
//  Copyright © 2017 Black. All rights reserved.
//

import UIKit

class FCountry: FObject {
    // KEY -----------------------------------------------------
    static let name = "name"
    static let currencyUnit = "currencyUnit"
    static let displayCurrencyUnit = "displayCurrencyUnit"
    static let displayCurrencySymbol = "displayCurrencySymbol"
    // KEY -----------------------------------------------------
    
    func getName() -> String {
        return self[FCountry.name] as? String ?? ""
    }
    
    func getCurrencyUnit() -> String{
        return self[FCountry.currencyUnit] as? String ?? ""
    }
    
    func getDisplayCurrencyUnit() -> String {
        return self[FCountry.displayCurrencyUnit] as? String ?? ""
    }
    
    func getDisplayCurrencySymbol() -> String {
        return self[FCountry.displayCurrencySymbol] as? String ?? ""
    }
    
}
