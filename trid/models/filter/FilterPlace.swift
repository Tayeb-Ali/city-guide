//
//  FilterPlace.swift
//  trid
//
//  Created by Black on 1/5/17.
//  Copyright © 2017 Black. All rights reserved.
//

import UIKit

class FilterPlace: NSObject {
    
    var minPrice : Float = 0
    var maxPrice : Float = MAXFLOAT
    
    convenience init(min: Float, max: Float) {
        self.init()
        self.minPrice = min
        self.maxPrice = max
    }

}
