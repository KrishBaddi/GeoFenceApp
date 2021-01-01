//
//  MKMapView+Extension.swift
//  iOS-Geofence-Demo
//
//  Created by Kaodim MacMini on 31/12/2020.
//

import Foundation
import MapKit
import CoreLocation

extension MKMapView {
  func zoomToUserLocation() {
    guard let coordinate = userLocation.location?.coordinate else { return }
    let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
    setRegion(region, animated: true)
  }
}
