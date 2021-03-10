//
//  UtilNumber.swift
//  trid
//
//  Created by Black on 4/20/17.
//  Copyright © 2017 Black. All rights reserved.
//

import UIKit

class UtilNumber: NSObject {
    static let formatter = NumberFormatter()
    
    static func formatTemperature(_ temp: Float) -> String? {
        UtilNumber.formatter.positiveFormat = "0.##"
        return UtilNumber.formatter.string(from: NSNumber(value: temp))
    }
    
    static func formatDistance(_ dis: Double) -> String? {
        UtilNumber.formatter.positiveFormat = "0.#"
        return UtilNumber.formatter.string(from: NSNumber(value: dis))
    }
}
