//
//  Marker.swift
//  Location Selector
//
//  Created by Insight Workshop on 2/16/19.
//  Copyright © 2019 InsightWorkshop. All rights reserved.
//

import Foundation
import GoogleMaps
import GooglePlaces

class Marker: GMSMarker {
    
    var place: GMSPlace?
    
    override init() {
        super.init()
    }
    
    init(place: GMSPlace, with markerImage: UIImage, with size: CGSize) {
        
        super.init()
        position = place.coordinate
        icon = markerImage
        setIconSize(scaledToSize: size)
    }
    
    func setIconSize(scaledToSize newSize: CGSize) {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        icon?.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        icon = newImage
    }
    
}
