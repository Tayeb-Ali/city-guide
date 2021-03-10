//
//  GooglePlace.swift
//  trid
//
//  Created by Black on 10/14/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import FirebaseDatabase
//import SwiftyJSON

/// Point of Interest Item which implements the GMUClusterItem protocol.
class PlaceItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var place : GooglePlace!
    
    init(position: CLLocationCoordinate2D, place gp: GooglePlace) {
        self.position = position
        self.place = gp
    }
}

class GooglePlace : NSObject {
    
    var key: String?
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let type: FCategoryType
    var photoReference: String?
    var photo: UIImage?
    var currentPlace: FPlace?
    
    internal init(place: FPlace, categoryType: FCategoryType){
        // place
        currentPlace = place
        // title
        self.name = place[FPlace.name] as! String
        // address
        self.address = place[FPlace.address] as! String
        // type
        self.type = categoryType
        // photo
        if place[FPlace.photos] != nil {
            let arr = place[FPlace.photos] as! Array<String>
            if arr.count > 0 {
                self.photoReference = arr[0]
            }
        }
        // coordinate
        if place[FPlace.latitude] != nil && place[FPlace.longitude] != nil {
            let longitude = (place[FPlace.latitude] as! NSString).doubleValue
            let latitude = (place[FPlace.longitude] as! NSString).doubleValue
            self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        else{
            self.coordinate = CLLocationCoordinate2D()
        }
    }
    
    internal class func fromPlace(_ place: FPlace, categoryType: FCategoryType) -> GooglePlace? {
        if place[FPlace.latitude] != nil && place[FPlace.longitude] != nil {
            return GooglePlace(place: place, categoryType: categoryType)
        }
        return nil
    }
    
    class func fromPlace(_ place: FPlace, categoryType: FCategoryType?) -> GooglePlace? {
        let currentCategoryType = categoryType == nil ? AppState.getCurrentCategoryType() : categoryType
        if currentCategoryType != nil {
            let googleplace = GooglePlace.fromPlace(place, categoryType: currentCategoryType!)
            if googleplace != nil {
                googleplace?.key = place.snapshot?.key
                return googleplace
            }
        }
        return nil
    }
}
