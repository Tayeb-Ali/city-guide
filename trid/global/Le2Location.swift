//
//  LocationManager.swift
//  trid
//
//  Created by Black on 4/14/17.
//  Copyright © 2017 Black. All rights reserved.
//

import UIKit
import CoreLocation
// import SwiftLocation

public extension CLLocation {
    
    public var shortDesc: String {
        return "lat,lng=\(self.coordinate.latitude),\(self.coordinate.longitude), h-acc=\(self.horizontalAccuracy) mts\n"
    }
    
}

class Le2Location: NSObject {
    // Static
    static let shared = Le2Location()
    
    // Var
    var locationManager: CLLocationManager = CLLocationManager()
    var location : CLLocation?
    var permission: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - Static func
    static func getDistanceFrom(long: Double, lat: Double) -> String {
        let km = "km"
        let loc = Le2Location.shared.location
        if long == 0 || lat == 0 || loc == nil {
            return ""
        }
        let coor = CLLocation(latitude: lat, longitude: long)
        let dis = floor(loc!.distance(from: coor))/1000.0
        let str = UtilNumber.formatDistance(dis)
        if str == nil {
            return "-"
        }
        return str! + km
    }
}

extension Le2Location : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        permission = status
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
            location = locations[0]
            debugPrint("Location Updated", location?.shortDesc ?? "")
            locationManager.stopUpdatingLocation()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 90, execute: {
                self.locationManager.startUpdatingLocation()
            })
        }
    }
    
}
