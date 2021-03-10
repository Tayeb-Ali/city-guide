//
//  GMSMapView+Extension.swift
//  trid
//
//  Created by Black on 10/18/16.
//  Copyright © 2016 Black. All rights reserved.
//

import GoogleMaps

extension GMSMapView {
    // MARK: - City location
    func setCameraFor(city: FCity){
        let latitude = city.getLatitude()
        let longitude = city.getLongitute()
        let zoom = city.getZoom()
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.camera = GMSCameraPosition(target: coordinate, zoom: zoom, bearing: 0, viewingAngle: 0)
    }
    
    func setCameraFor(place: FPlace, city: FCity){
        let latitude = place.getLatitude()
        let longitude = place.getLongitute()
        let zoom = city.getZoom()
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.camera = GMSCameraPosition(target: coordinate, zoom: zoom, bearing: 0, viewingAngle: 0)
    }
    
    func hiddenLegal(){
    }
}
