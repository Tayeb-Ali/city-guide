//
//  PlaceService.swift
//  trid
//
//  Created by Black on 9/30/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import Firebase

struct PlaceServiceKey {
    static let added : String = "placeServiceAdded"
    static let changed : String = "placeServiceChanged"
    static let removed : String = "placeServiceRemoved"
}

class PlaceService: NSObject {
    
    // path
    static let path = "place"
    fileprivate(set) var subpath = ""
    
    // Singleton
    static let shared = PlaceService()
    
    // ref
    var ref : DatabaseReference!

    // data
    var places : [FPlace] = []
    
    // variable
    var isQuering : Bool = false
    
    // init
    override init() {
        super.init()
    }
    
    public func configureDatabase(citykey: String, finish: @escaping () -> Void) { // _ block: @escaping () -> Void
        // remove all old obj
        places.removeAll()
        
        // subpath
        subpath = PlaceService.path + "/" + citykey
        // ref
        ref = Database.database().reference().child(subpath)
        ref.keepSynced(true)
        // remove all observe
        ref.removeAllObservers()
        // quering
        isQuering = true
        // add listener
        ref.observe(.childAdded, with: { (snapshot) -> Void in
            let fplace = FPlace(path: self.subpath, snapshot: snapshot)
            self.places.insert(fplace, at: 0)
            if !self.isQuering{
                NotificationCenter.default.post(name: Notification.Name(PlaceServiceKey.added), object: fplace)
            }
        })
        ref.observe(.childChanged, with: { (snapshot) -> Void in
            for i in (0 ..< self.places.count) {
                let place = self.places[i]
                if place.snapshot != nil && place.snapshot?.key == snapshot.key {
                    // đã tồn tại và trùng key -> update
                    let fplace = FPlace(path: self.subpath, snapshot: snapshot)
                    self.places[i] = fplace
                    if !self.isQuering {
                        NotificationCenter.default.post(name: Notification.Name(PlaceServiceKey.changed), object: fplace)
                        NotificationCenter.default.post(name: NotificationKey.placeUpdated(fplace.objectId!), object: fplace)
                    }
                    break
                }
            }
        })
        ref.observe(.childRemoved, with: { (snapshot) -> Void in
            for i in (0 ..< self.places.count) {
                let place = self.places[i]
                if place.snapshot != nil && place.snapshot?.key == snapshot.key {
                    self.places.remove(at: i)
                    if !self.isQuering {
                        NotificationCenter.default.post(name: Notification.Name(PlaceServiceKey.removed), object: place)
                    }
                    break
                }
            }
        })
        ref.observeSingleEvent(of: .value, with: {(snapshot) -> Void in
            debugPrint("DONE2 Place")
            self.isQuering = false
            self.places = self.places.sorted(by: {$0.getPriority() > $1.getPriority()})
            finish()
        })
    }
    
    // MARK: - Get places for category
    static func placesForCategoryKey(_ catkey : String) -> [FPlace] {
        let arr = shared.places.filter({place in
            // check active & check contain cat
            let deactived = place[FPlace.deactived] != nil && place[FPlace.deactived] as! Bool
            return place.getCategories().contains(catkey) && !deactived
        })
        return arr.sorted(by: {p1, p2 in
            return p1.getPriority() > p2.getPriority()
        })
    }
    
    static func places(fromAll all: [FPlace],  forCategoryKey catkey : String) -> [FPlace] {
        let arr = all.filter({place in
            // check active & check contain cat
            let deactived = place[FPlace.deactived] != nil && place[FPlace.deactived] as! Bool
            return place.getCategories().contains(catkey) && !deactived
        })
        return arr.sorted(by: {p1, p2 in
            return p1.getPriority() > p2.getPriority()
        })
    }
    
    static func placesFromKeys(keys: [String]?) -> [FPlace]?{
        if keys == nil || keys?.count == 0 {
            return nil
        }
        return shared.places.filter({keys!.contains($0.objectId!)})
    }
    
}
