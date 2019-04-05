//
//  LocationSelectorConstants.swift
//  Location Selector
//
//  Created by Insight Workshop on 2/16/19.
//  Copyright © 2019 InsightWorkshop. All rights reserved.
//

import UIKit

typealias LSConstants = LocationSelectorConstants
struct LocationSelectorConstants {
    
    struct images {
        static let markerImage: UIImage = #imageLiteral(resourceName: "marker.png")
        static let backBtnImage: UIImage = #imageLiteral(resourceName: "backBtn.png")
        static let gpsBtnImage: UIImage = #imageLiteral(resourceName: "gpsBtn.png")
        static let clearBtnImage: UIImage = #imageLiteral(resourceName: "locationClearBtn.png")
    }
    
    struct strings {
        static let moduleTitle = "Location Selector"
        static let titleLocationString = "Set Location"
        static let locationSelectionErrorString = "Could not select location at this time"
        static let locationFetchError = "Error fetching location"
        static let locationServiceAccessString = "Location access is required for access currrent location"
        static let locationAccessTitleString = "Need Location Access"
        static let allowLocationAccessBtnTitle = "Allow Location Access"
        static let cancel = "Cancel"
    }
    
    struct size {
        static let markerSize = CGSize(width: 20.0, height: 32.0)
    }
    
    struct color {
        static let themeColor = UIColor(red: 240.0/255.0, green: 92.0/255.0, blue: 32.0/255.0, alpha: 1.0)
        static let textFieldTxtColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    }
    
    struct mapView {
        static let zoomLevel: Float = 16
    }
    
}
