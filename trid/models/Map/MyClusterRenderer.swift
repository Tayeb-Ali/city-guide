//
//  MyClusterRenderer.swift
//  trid
//
//  Created by Black on 5/4/17.
//  Copyright © 2017 Black. All rights reserved.
//

import UIKit

class MyClusterRenderer: GMUDefaultClusterRenderer {
    
    override func shouldRender(as cluster: GMUCluster, atZoom zoom: Float) -> Bool {
        //debugPrint("zoom", zoom, "count", cluster.count)
        return (zoom < 9 || cluster.count > 60)
    }
}
