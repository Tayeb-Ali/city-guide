//
//  PlaceMarker.swift
//  trid
//
//  Created by Black on 10/14/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import GoogleMaps
import FirebaseDatabase

class PlaceMarker: GMSMarker {
    // 1
    let googlePlace: GooglePlace
    let index: Int
    let categoryType: FCategoryType
    var place: FPlace?
    
    // 2
    init(googlePlace gp: GooglePlace, index i: Int, categoryType t: FCategoryType) {
        self.googlePlace = gp
        self.index = i
        self.categoryType = t
        self.place = gp.currentPlace
        super.init()
        position = gp.coordinate
        groundAnchor = CGPoint(x: 0.5, y: 1)
        // title = place.name
        appearAnimation = GMSMarkerAnimation.pop
        makeMarker(categoryType: t, index: i)
    }
    
    class func fromPlace(_ place_: FPlace, index i: Int, categoryType t: FCategoryType) -> PlaceMarker? {
        let googleplace = GooglePlace.fromPlace(place_, categoryType: t)
        if googleplace != nil {
            let marker = PlaceMarker(googlePlace: googleplace!, index: i, categoryType: t)
            marker.place = place_
            return marker
        }
        return nil
    }
    
    public func makeMarker(categoryType: FCategoryType, index: Int) {
        if iconView == nil {
            let marker = MarkerIconView.create(target: self)
            marker.make(type: categoryType, text: String(index))
            iconView = marker
            self.iconView?.clipsToBounds = false
        }
        else {
            let marker = iconView as! MarkerIconView
            marker.make(type: categoryType, text: String(index))
        }
    }
}
