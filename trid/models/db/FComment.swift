//
//  FComment.swift
//  trid
//
//  Created by Black on 12/21/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import Firebase

class FComment: FObject {
    
    // KEY -----------------------------------------------------
    // sender
    static let senderId = "senderId"
    // content
    static let text = "text"
    // attribute
    static let isRemoved = "isRemoved"
    // KEY -----------------------------------------------------
    
    class func commentWith(content: String) -> FComment {
        let cmt = FComment(path: CommentService.shared.subpath)
        cmt.snapshot = nil
        cmt.dictionary = [FComment.senderId: AppState.currentUser![FUser.userId]!,
                          FComment.text: content,
                          FComment.isRemoved: false]
        return cmt
    }
    
    func getSenderId() -> String {
        return self[FComment.senderId] as? String ?? "" 
    }
}
