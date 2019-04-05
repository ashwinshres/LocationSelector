//
//  MapView.swift
//  Location Selector
//
//  Created by Insight Workshop on 2/16/19.
//  Copyright © 2019 InsightWorkshop. All rights reserved.
//

import Foundation
import CoreLocation
import GoogleMaps
import GooglePlaces

class MapView: GMSMapView {
    
    var markers: [Marker]                   = []
    var defaultZoom: Float                  = 16
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUpView()
    }
    
    private func setUpView() {
        settings.rotateGestures = true
        isMyLocationEnabled = true
        settings.setAllGesturesEnabled(true)
    }
    
    func stopDraggable() {
        for marker in markers {
            marker.isDraggable = false
        }
    }
    
    func removeAllMarkers() {
        for eachMarker in markers {
            eachMarker.map = nil
        }
    }
    
    func createMarkers(markers: [Marker]) {
        for singleMarker in markers {
            create(marker: singleMarker)
        }
    }
   
    func showAllMarkers(for markers: [Marker]) {
        var bounds = GMSCoordinateBounds()
        for marker in markers {
            bounds = bounds.includingCoordinate(marker.position)
        }
        let update = GMSCameraUpdate.fit(bounds, withPadding: 100.0)
        animate(with: update)
    }
    
    func moveMakerToCenter(marker: Marker) {
        defaultZoom = camera.zoom
        centerMapView(in: CLLocation(latitude: marker.position.latitude, longitude: marker.position.longitude))
    }
    
    func centerMapView(in location: CLLocation) {
        let coords = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        animate(to: GMSCameraPosition(target: coords, zoom: defaultZoom, bearing: 0, viewingAngle: 0))
    }
    
    func centerMapView(in place: GMSPlace) {
        animate(to: GMSCameraPosition(target: place.coordinate, zoom: defaultZoom, bearing: 0, viewingAngle: 0))
    }
    
    // MARK: - Private
    private func create(marker: Marker) {
        markers.append(marker)
        marker.map = self
    }
    
}

extension GMSCircle {
    
    func bounds () -> GMSCoordinateBounds {
        func locationMinMax(positive: Bool) -> CLLocationCoordinate2D {
            let sign:Double = positive ? 1 : -1
            let dx = sign * self.radius  / 6378000 * (180.0/Double.pi)
            let lat = position.latitude + dx
            let lon = position.longitude + dx / cos(position.latitude * Double.pi/180.0)
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        return GMSCoordinateBounds(coordinate: locationMinMax(positive: true), coordinate: locationMinMax(positive: false))
    }
    
}


