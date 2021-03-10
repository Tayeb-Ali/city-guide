//
//  CountryService.swift
//  trid
//
//  Created by Black on 9/28/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class CountryService: NSObject {
    // ref
    var ref : DatabaseReference!
    let path = "country"
    var subpath = ""
    // data
    var countries : [FCountry] = []
    var currentCountry : FCountry!
    
    // Singleton
    static let shared = CountryService()
    
    // init
    override init() {
        super.init()
    }
    
    public func configureDatabase(languagekey: String, finish: @escaping () -> Void) {
        countries.removeAll()
        subpath = path + "/" + languagekey
        // ref
        ref = Database.database().reference(withPath: subpath)
        ref.keepSynced(true)
        // remove all observe
        ref.removeAllObservers()
        // add observes
        ref.observe(.childAdded, with: {snapshot in
            let country = FCountry(path: self.subpath, snapshot: snapshot)
            self.countries.append(country)
        })
        ref.observeSingleEvent(of: .value, with: {snapshot in
            debugPrint("DONE2 Country")
            self.currentCountry = self.countries[0]
            CityService.shared.configureDatabase(countrykey: self.currentCountry.objectId!, finish: { () -> Void in
                finish()
            })
        })
    }
}
