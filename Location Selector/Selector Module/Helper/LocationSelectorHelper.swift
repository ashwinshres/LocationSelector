//
//  LocationSelectorHelper.swift
//  Location Selector
//
//  Created by Insight Workshop on 2/16/19.
//  Copyright © 2019 InsightWorkshop. All rights reserved.
//

import Foundation
import GooglePlaces

extension Optional where Wrapped == GMSPlace {
    
    var isNil: Bool { return self == nil }
    
    var hasValue: Bool { return self != nil }
    
}
