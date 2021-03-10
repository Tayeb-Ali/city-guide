//
//  Le2Network.swift
//  trid
//
//  Created by Black on 4/18/17.
//  Copyright © 2017 Black. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class Le2Network: NSObject {
    static func get(_ url: String, finish: @escaping ((JSON) -> Void)) {
        Alamofire.request(url).responseJSON(completionHandler: {response in
            if let data = response.data {
                do {
                    let dataObj = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let json = JSON(dataObj)
                    finish(json)
                }
                catch {
                    finish(JSON.null)
                }
            }
            else{
                finish(JSON.null)
            }
        })
    }
}
