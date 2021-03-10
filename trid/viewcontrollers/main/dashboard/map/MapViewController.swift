//
//  MapViewController.swift
//  trid
//
//  Created by Black on 9/27/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import GoogleMaps
import FirebaseDatabase
import PureLayout

class MapViewController: DashboardBaseViewController {

    // outlet
    @IBOutlet weak var mapview: GMSMapView!
    // view selected
    var viewSelected: PlaceMarkerSelectedView!
    var selectedPlace: FPlace?
    
    // variable
    var allMarkers : [FCategoryType: [PlaceMarker]] = [:]
    var isCenteringMap = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // create ui
        setupUI()
        // create data
        createMapData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI(){
        // ADD place marker selected view
        viewSelected = Bundle.main.loadNibNamed(PlaceMarkerSelectedView.className, owner: self, options: nil)?[0] as? PlaceMarkerSelectedView
        self.view.addSubview(viewSelected!)
        viewSelected?.autoPinEdge(toSuperviewEdge: ALEdge.leading)
        viewSelected?.autoPinEdge(toSuperviewEdge: ALEdge.trailing)
        viewSelected?.autoPinEdge(toSuperviewEdge: ALEdge.top, withInset: 64)
        viewSelected?.autoSetDimension(ALDimension.height, toSize: 70)
        viewSelected?.isHidden = true
        viewSelected?.clipsToBounds = true
        viewSelected?.delegate = self
    }
    
    func makeMapCenter(marker: PlaceMarker){
        isCenteringMap = true
        // City location
        if AppState.shared.currentCity != nil {
            mapview.setCameraFor(city: AppState.shared.currentCity!)
        }
        // Apply map style
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "MapStyle", withExtension: "json") {
                mapview.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("The style definition could not be loaded: \(error)")
        }
        mapview.delegate = self
    }
    
    func createMapData() {
        mapview.clear()
        // store data by dictionary<category-key, place>
        for i in 0..<(PlaceService.shared.places.count) {
            let place = PlaceService.shared.places[i]
            // check snap category
            let cats = place[FPlace.categories] as! [String]
            let deactived = place[FPlace.deactived] != nil && place[FPlace.deactived] as! Bool
            if cats.count > 0 && !deactived {
                var type : FCategoryType?
                for cat in cats {
                    type = CategoryService.shared.getCategoryType(fromKey: cat)
                    if type != nil {
                        break
                    }
                }
                if type != nil {
                    if allMarkers[type!] == nil {
                        allMarkers[type!] = Array<PlaceMarker>()
                    }
                    // add marker
                    let marker = PlaceMarker.fromPlace(place, index: (allMarkers[type!]?.count)! + 1, categoryType: type!)
                    if marker != nil{
                        marker!.map = self.mapview
                        allMarkers[type!]?.append(marker!)
                        if !isCenteringMap {
                            makeMapCenter(marker: marker!)
                        }
                    }
                }
            }
        }
    }
    
}

extension MapViewController : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if (gesture) {
            mapView.selectedMarker = nil
            // hide selected view
            hideSelectedPlaceView()
        }
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        return nil
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return nil
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let placeMarker = marker as! PlaceMarker
        let iconview = placeMarker.iconView
        if iconview != nil{
            let tr1 = (iconview?.transform)!
            let tr2 = (iconview?.transform)!.scaledBy(x: 1.2, y: 1.2)
            UIView.animate(withDuration: 0.1, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {()-> Void in
                iconview?.transform = tr2
                }, completion: {(finish: Bool) -> Void in
                    UIView.animate(withDuration: 0.1, animations: {() -> Void in
                        iconview?.transform = tr1
                    })
            })
        }
        // show selected view
        showSelectedPlaceView(marker: placeMarker)
        return false
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapView.selectedMarker = nil
        // hide selected view
        hideSelectedPlaceView()
        return false
    }
}

extension MapViewController {
    // MARK: - selected marker
    func showSelectedPlaceView (marker: PlaceMarker) {
        viewSelected?.isHidden = false
        selectedPlace = marker.place
        viewSelected?.makePlace(place: selectedPlace!, categoryType: nil)
        // animate
        viewSelected?.alpha = 0
        UIView.animate(withDuration: 0.15, animations: {() -> Void in
            self.viewSelected?.alpha = 1
            }, completion: {(finish: Bool) -> Void in
                
        })
    }
    
    func hideSelectedPlaceView(){
        selectedPlace = nil
        viewSelected?.alpha = 1
        UIView.animate(withDuration: 0.15, animations: {() -> Void in
            self.viewSelected?.alpha = 0
            }, completion: {(finish: Bool) -> Void in
                self.viewSelected?.isHidden = true
                self.viewSelected?.makeEmpty()
        })
    }
}

extension MapViewController : PlaceMarkerSelectedViewProtocol {
    func markerSelectedViewTouched(view: PlaceMarkerSelectedView) {
        let detail = DetailViewController(nibName: "DetailViewController", bundle: nil)
        detail.place = selectedPlace
        self.navigationController?.pushViewController(detail, animated: true)
    }
}
