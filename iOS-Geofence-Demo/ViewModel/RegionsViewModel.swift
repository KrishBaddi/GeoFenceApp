//
//  RegionsViewModel.swift
//  iOS-Geofence-Demo
//
//  Created by Kaodim MacMini on 01/01/2021.
//

import Foundation
import CoreLocation

protocol RegionsViewModelDelegate: class {
    func getNewRegion(_ region: RegionObject)
    func isFieldsValidated(_ status: Bool)
}

class RegionsViewModel {

    weak var delegate: RegionsViewModelDelegate?

    internal init(delegate: RegionsViewModelDelegate? = nil) {
        self.delegate = delegate
    }

    func createRegion(_ regionName: String, _ radius: Float, _ coordinates: CLLocationCoordinate2D, _ network: String) {

        let coordinatesId = String().randomString(length: 5)
        let identifier = String().randomString(length: 5)
        let hotspotId = String().randomString(length: 10)

        let latitude = coordinates.latitude
        let longitude = coordinates.longitude
        let coordinate = Coordinates(id: coordinatesId, latitude: latitude, longitude: longitude)

        // HotSpot radius is assumed
        let regionObject = RegionObject(id: identifier, title: regionName, radius: radius, coordinates: coordinate, network: HotSpot(id: hotspotId, name: network, radius: 100))
        delegate?.getNewRegion(regionObject)
    }

    // TextField Validator
    func validator(_ regionName: String?, _ radiusText: String?,_ network: String?)  {
        guard let regionName = regionName, regionName.count > 0 else {
                delegate?.isFieldsValidated(false)
                return
        }
        guard let radiusText = radiusText,let radius = Float(radiusText), radius > 0 else {
            delegate?.isFieldsValidated(false)
            return
        }
        guard let network = network, network.count > 0 else {
            delegate?.isFieldsValidated(false)
            return
        }
        delegate?.isFieldsValidated(true)
    }
}
