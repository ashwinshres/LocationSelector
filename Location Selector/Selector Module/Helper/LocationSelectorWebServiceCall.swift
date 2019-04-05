//
//  LocationSelectorWebServiceCall.swift
//  Location Selector
//
//  Created by Insight Workshop on 2/16/19.
//  Copyright © 2019 InsightWorkshop. All rights reserved.
//

import Foundation
import CoreLocation
import GooglePlaces
import GoogleMaps

class LocationSelectorWebServiceCall {
    
    static func getCleanAddress(from addresses: [GMSAddress]?) -> String? {
        guard let addresses = addresses else {
            return "Unnamed address"
        }
        for eachAddress in addresses{
            if !(eachAddress.thoroughfare?.contains("Unnamed") ?? false) {
                return eachAddress.lines?.joined(separator: ", ")
            }
        }
        return addresses.first?.lines?.joined(separator: ", ")
    }
    
    static func getAddress(for cordinates: CLLocationCoordinate2D,
                           completionHandler: @escaping (GMSPlace?,String?) -> Void) {
        
        let geoCoder = GMSGeocoder()
        geoCoder.reverseGeocodeCoordinate(cordinates) {(response, error) in
            if let error = error {
                completionHandler(nil,error.localizedDescription)
                return
            }
            if let address = LocationSelectorWebServiceCall.getCleanAddress(from: response?.results()) {
                LocationSelectorWebServiceCall.getLocationSuggestions(from: address, completionHandler: { (predictions, error) in
                    if let _ = error  {
                       completionHandler(nil,
                                LSConstants.strings.locationFetchError)
                        return
                    }
                    if let placeID = predictions?.first?.placeID {
                        LocationSelectorWebServiceCall.getLocation(from: placeID, completionHandler: { (address, error) in
                            completionHandler(address,error)
                        })
                    } else {
                        completionHandler(nil,
                                LSConstants.strings.locationFetchError)
                    }
                })
            } else {
                completionHandler(nil,
                               LSConstants.strings.locationFetchError)
            }
        }
    }
    
    
    static func getLocationSuggestions(from subString: String, with countryComponent: String? = nil, completionHandler: @escaping ([GMSAutocompletePrediction]?,String?) -> Void) {
        
        let geoCoder = GMSPlacesClient()
        let filter = GMSAutocompleteFilter()
        if let countryComponent = countryComponent {
            filter.country = countryComponent
        }
        geoCoder.autocompleteQuery(subString, bounds: nil, filter: filter) { (predictions, error) in
            if let error = error {
                completionHandler(nil, error.localizedDescription)
                return
            }
            completionHandler(predictions,nil)
        }
    }
    
    static func getLocation(from placeId: String, completionHandler: @escaping (GMSPlace?,String?) -> Void) {
        let geoCoder = GMSPlacesClient()
        geoCoder.lookUpPlaceID(placeId) { (place, error) in
            if let error = error {
                completionHandler(nil, error.localizedDescription)
                return
            }
            if let place = place {
                completionHandler(place, nil)
            } else {
                completionHandler(nil, LSConstants.strings.locationFetchError)
            }
        }
    }
    
}
