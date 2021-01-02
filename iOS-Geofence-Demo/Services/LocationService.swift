//
//  LocationService.swift
//  iOS-Geofence-Demo
//
//  Created by Kaodim MacMini on 30/12/2020.
//

import Foundation
import CoreLocation

protocol LocationServiceDelegate: class {
    func tracingLocation(currentLocation: CLLocation)
    func tracingLocationDidFailWithError(error: NSError)
    func didEnterIntoRegion(region: CLRegion)
    func didExitIntoRegion(region: CLRegion)
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
}


class LocationService: NSObject, CLLocationManagerDelegate {

    var locationManager: CLLocationManager
    var lastLocation: CLLocation?
    weak var delegate: LocationServiceDelegate?

    override init() {
        self.locationManager = CLLocationManager()
        super.init()
//
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest // The accuracy of the location data
//        locationManager.distanceFilter = 100 // The minimum distance (measured in meters) a device must move horizontally before an update event is generated.
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

    func setDelegate(_ delegate: LocationServiceDelegate) {
        self.delegate = delegate
    }

    func startUpdatingLocation() {
        print("Starting Location Updates")
        self.locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        print("Stop Location Updates")
        self.locationManager.stopUpdatingLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            break
        case .notDetermined, .denied, .restricted:
            break
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        delegate?.locationManager(manager, didChangeAuthorization: status)
    }

    // CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        // singleton for get last location
        self.lastLocation = location

        // use for real time update location
        updateLocation(currentLocation: location)
    }

    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        // do on error
        updateLocationDidFailWithError(error: error)
    }

    public func startMonitoringFor(region: CLRegion) {
        self.locationManager.startMonitoring(for: region)
    }

    public func stopMonitoringFor(region: CLRegion) {
        self.locationManager.stopMonitoring(for: region)
    }

    private func updateLocation(currentLocation: CLLocation) {
        delegate?.tracingLocation(currentLocation: currentLocation)
    }

    private func updateLocationDidFailWithError(error: NSError) {
        delegate?.tracingLocationDidFailWithError(error: error)
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        delegate?.didExitIntoRegion(region: region)
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        delegate?.didEnterIntoRegion(region: region)
    }
}

extension CLLocationManager {
    func hasLocationPermission() -> Bool {
        if self.authorizationStatus != .authorizedWhenInUse && self.authorizationStatus != .authorizedAlways {
            return false
        }
        return true
    }
}
