//
//  LocationSelectorProtocol.swift
//  Location Selector
//
//  Created by Insight Workshop on 2/16/19.
//  Copyright © 2019 InsightWorkshop. All rights reserved.
//

import Foundation
import GooglePlaces

protocol MapViewControllerDelegate: class {
    /// delegate method when a location is selected
    ///
    /// - Parameter location: instance of GMSPlace object selected
    func didSelect(location: GMSPlace)
    
    /// delegate method when location selector view controller is closed
    ///
    /// - Parameter viewController: insance of LocationSelectorViewController
    func didClickClose(viewController: LocationSelectorViewController)
}

protocol MapViewControllerDataSource: class {
    /// Optional: Image for marker in map view. If not provided, default marker in the Module is used
    ///
    /// - Returns: uiimage to be used as marker
    func imageForMarker() -> UIImage
    
    /// Optional: Image for back button in location selector view controller. If not provided, default back button image in the Module is used
    ///
    /// - Returns: uiimage to be used as back button
    func imageForBackBtn() -> UIImage
    
    /// Optional: Image for clear button in location selector view controller. If not provided, default clear button image in the Module is used
    ///
    /// - Returns: uiimage to be used as clear button
    func imageForClearBtn() -> UIImage
    
    /// Optional: Image for gps button in location selector view controller. If not provided, default gps button image in the Module is used
    ///
    /// - Returns: uiimage to be used as gps button
    func imageForGpsBtn() -> UIImage
    
    /// Optional: title for select location button in location selector view controller. If not provided, default title string in the Module is used
    ///
    /// - Returns: string to be used as selection button title
    func titleForSelectLocationBtn() -> String
    
    /// Optional: size for markere image in location selector view controller's map view. If not provided, default size in the Module is used
    ///
    /// - Returns: size to be used for marker in map view
    func sizeForMarker() -> CGSize
    
    /// Optional: Country component String in location selector view controller to fetch auto complete addresses. If not provided, address filtering by country is not done
    ///
    /// - Returns: string to be used as filter parameter for country componenet
    func countryComponent() -> String?
    
    /// Optional: Float value default map zoom levelIf not provided, default back button image in the Module is used = 16.0
    ///
    /// - Returns: Float zoom level to be used in map
    func defaultZoomLevel() -> Float
    
    /// Optional: UIColor to be used as theme of the view controller
    /// - Returns: UIColor
    func themeColor() -> UIColor
    
    /// Optional: UIColor to be used as textfield color in the view controller
    /// - Returns: UIColor
    func textFieldTextColor() -> UIColor
    
    func appName() -> String
    
}

extension MapViewControllerDataSource {
    
    func imageForMarker() -> UIImage {
        return LSConstants.images.markerImage
    }
    
    func imageForBackBtn() -> UIImage {
        return LSConstants.images.backBtnImage
    }
    
    func imageForClearBtn() -> UIImage {
        return LSConstants.images.clearBtnImage
    }
    
    func imageForGpsBtn() -> UIImage {
        return LSConstants.images.gpsBtnImage
    }
    
    func titleForSelectLocationBtn() -> String {
        return LSConstants.strings.titleLocationString
    }
    
    func sizeForMarker() -> CGSize {
        return LSConstants.size.markerSize
    }
    
    func countryComponent() -> String? {
        return nil
    }
    
    func defaultZoomLevel() -> Float {
        return LSConstants.mapView.zoomLevel
    }
    
    func themeColor() -> UIColor {
        return LSConstants.color.themeColor
    }
    
    func textFieldTextColor() -> UIColor {
        return LSConstants.color.textFieldTxtColor
    }
    
}
