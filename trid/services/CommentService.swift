//
//  CommentService.swift
//  trid
//
//  Created by Black on 12/5/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

protocol CommentServiceProtocol {
    func commentServiceAdded(_ comment : FComment)
}

class CommentService: NSObject {
    // Path to table
    static let path = "comments"
    fileprivate(set) var subpath = ""
    
    // ref
    var ref : DatabaseReference!
    
    // data
    var comments : [FComment] = []
    
    // Singleton
    static let shared = CommentService()
    
    // variable
    var delegate : CommentServiceProtocol?
    var syncing = true
    
    // init
    override init() {
        super.init()
    }
    
    public func configureDatabase(placeKey: String, finish: @escaping () -> Void) {
        // remove all old obj
        comments.removeAll()
        // ---------------------------------------------
        // create path
        subpath = CommentService.path + "/" + placeKey
        // create ref
        ref = Database.database().reference(withPath: subpath)
        ref.keepSynced(true)
        // remove all observe
        ref.removeAllObservers()
        // add event
        syncing = true
        ref.observe(.childAdded, with: { (snapshot) -> Void in
            // comment mới nhất sẽ đưa lên đầu
            // comment mới nhất đưa xuống cuối 11/07/2017
            let cmt = FComment(path: self.subpath, snapshot: snapshot)
            self.comments.append(cmt)
            if !self.syncing {
                if self.delegate != nil {
                    self.delegate?.commentServiceAdded(cmt)
                }
                // Find Place & update comment count
                let place = PlaceService.shared.places.first(where: {$0.snapshot?.key == placeKey})
                if place != nil {
                    place?.retainCommentCount()
                    // Save if current user just comment
                    if AppState.currentUser != nil && AppState.currentUser?.getUserId() == cmt.getSenderId() {
                        place?.saveInBackground()
                    }
                }
            }
        })
        ref.observeSingleEvent(of: .value, with: {(snapshot) -> Void in
            debugPrint("FINISH GET COMMENTS", self.subpath)
            self.syncing = false
            finish()
        })
    }
    
    public func addComment(_ text: String){
        let fcmt = FComment.commentWith(content: text)
        fcmt.saveInBackground()
    }
    
}
