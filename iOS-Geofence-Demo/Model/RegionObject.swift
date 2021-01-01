//
//  RegionObject.swift
//  iOS-Geofence-Demo
//
//  Created by Kaodim MacMini on 30/12/2020.
//

import Foundation
import CoreLocation
import MapKit

class RegionObject: NSObject, Codable {
    var id: String
    var title: String?
    var radius: Float
    var coordinates: Coordinates
    var network: HotSpot
    var created: Date

    internal init(id: String, title: String, radius: Float, coordinates: Coordinates, network: HotSpot, created: Date = Date()) {
        self.id = id
        self.title = title
        self.radius = radius
        self.coordinates = coordinates
        self.network = network
        self.created = created
    }
}

class RegionAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var regionId: String

    internal init(coordinate: CLLocationCoordinate2D, title: String? = nil, regionId: String) {
        self.coordinate = coordinate
        self.title = title
        self.regionId = regionId
    }
}

extension RegionObject {
    func getCoordinates() -> CLLocationCoordinate2D? {
        CLLocationCoordinate2D(latitude: self.coordinates.latitude, longitude: self.coordinates.longitude)
    }

    func annotableRegion() -> RegionAnnotation? {
        guard let coordinate = self.getCoordinates() else { return nil }
        return RegionAnnotation(coordinate: coordinate, title: self.title, regionId: self.id)
    }
}

struct Coordinates: Codable {
    var id: String
    var latitude: Double
    var longitude: Double

    internal init(id: String, latitude: Double, longitude: Double) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
    }
}

struct HotSpot: Codable, Equatable {
    var id: String
    var name: String
    var radius: Float

    internal init(id: String, name: String, radius: Float) {
        self.id = id
        self.name = name
        self.radius = radius
    }
}
