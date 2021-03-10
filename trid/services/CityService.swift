//
//  CityService.swift
//  trid
//
//  Created by Black on 9/29/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import Firebase

protocol CityServiceProtocol {
    func cityServiceAdded(_ city : FCity)
    func cityServiceChangedAt(index: Int)
    func cityServiceRemovedAt(index : Int)
}

class CityService: NSObject {
    // Path to table
    let path = "city"
    
    // Singleton
    static let shared = CityService()
    
    // ref
    var ref : DatabaseReference!
    var subpath = ""
    var delegate : CityServiceProtocol?
    
    // data
    var cities : [FCity] = []
    
    var works: [DispatchWorkItem] = []
    var queue: OperationQueue = OperationQueue()
    var count = 0
    
    // init
    override init() {
        super.init()
    }
    
    public func configureDatabase(countrykey: String, finish: @escaping () -> Void) { // _ block: @escaping () -> Void
        subpath = path + "/" + countrykey
        cities.removeAll()
        // ref
        ref = Database.database().reference(withPath: subpath)
        ref.keepSynced(true)
        var syncing = true
        // remove all observe
        ref.removeAllObservers()
        // register listener
        ref.observe(.childAdded, with: {snapshot in
            let city = FCity(path: self.subpath, snapshot: snapshot)
            self.cities.append(city)
            if !syncing {
                self.delegate?.cityServiceAdded(city)
            }
        })
        ref.observe(.childChanged, with: {snapshot in
            for i in (0 ..< self.cities.count) {
                let city = self.cities[i]
                if city.objectId! == snapshot.key {
                    self.cities[i] = FCity(path: self.subpath, snapshot: snapshot)
                    if !syncing {
                        self.delegate?.cityServiceChangedAt(index: i)
                    }
                    break
                }
            }
        })
        ref.observe(.childRemoved, with: {snapshot in
            for i in (0 ..< self.cities.count) {
                let city = self.cities[i]
                if city.objectId! == snapshot.key {
                    self.cities.remove(at: i)
                    if !syncing {
                        self.delegate?.cityServiceRemovedAt(index: i)
                    }
                    break
                }
            }
        })
        ref.observeSingleEvent(of: .value, with: {snapshot in
            debugPrint("DONE GET City")
            self.cities =  self.cities.sorted(by: {$0.getPriority() > $1.getPriority()})
            finish()
            syncing = false
        })
    }
}


