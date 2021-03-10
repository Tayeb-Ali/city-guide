//
//  Artwork.swift
//  trid
//
//  Created by Black on 10/14/16.
//  Copyright © 2016 Black. All rights reserved.
//

import Foundation
import MapKit
import Contacts
import FirebaseDatabase

class Artwork: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        super.init()
    }
    
    class func fromPlace(_ place: FPlace) -> Artwork? {
        if place[FPlace.latitude] != nil && place[FPlace.longitude] != nil {
            // title
            let title = place[FPlace.name] as! String
            // address
            let locationName = place[FPlace.address] as! String
            // discipline
            let discipline = ""
            // coordinate
            let longitude = (place[FPlace.latitude] as! NSString).doubleValue
            let latitude = (place[FPlace.longitude] as! NSString).doubleValue
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            return Artwork(title: title, locationName: locationName, discipline: discipline, coordinate: coordinate)
        }
        return nil
    }
    
    var subtitle: String? {
        return locationName
    }
    
    // MARK: - MapKit related methods
    
    // pinTintColor for disciplines: Sculpture, Plaque, Mural, Monument, other
    @available(iOS 9.0, *)
    func pinTintColor() -> UIColor  {
        switch discipline {
        case "Sculpture", "Plaque":
            return MKPinAnnotationView.redPinColor()
        case "Mural", "Monument":
            return MKPinAnnotationView.purplePinColor()
        default:
            return MKPinAnnotationView.greenPinColor()
        }
    }
    
    // annotation callout opens this mapItem in Maps app
    func mapItem() -> MKMapItem {
        var addressDict : [String : Any]?
        if #available(iOS 9.0, *) {
            addressDict = [CNPostalAddressStreetKey: subtitle!]
        } else {
            // Fallback on earlier versions
        }
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }
    
}

