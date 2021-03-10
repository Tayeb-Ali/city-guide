//
//  LanguageService.swift
//  trid
//
//  Created by Black on 9/29/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class LanguageService: NSObject {
    // ref
    var ref : DatabaseReference!
    // data
    var languages : [DataSnapshot] = []
    
    // Singleton
    static let shared = LanguageService()
    
    // init
    override init() {
        super.init()
        ref = Database.database().reference(withPath: "language_code")
        ref.keepSynced(true)
    }
    
    public func configureDatabase(finish: @escaping () -> Void) {
        languages.removeAll()
        
        // remove all observe
        ref.removeAllObservers()
        // added
        ref.observe(.childAdded, with: {snapshot in
            self.languages.append(snapshot)
        })
        // finished
        ref.observeSingleEvent(of: .value, with: {snapshot in
            debugPrint("DONE2 Language")
            CountryService.shared.configureDatabase(languagekey: self.languages[0].key, finish: { () -> Void in
                finish()
            })
        })
    }
}
