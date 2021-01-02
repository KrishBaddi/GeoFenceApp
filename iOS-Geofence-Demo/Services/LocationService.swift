//
//  LocationService.swift
//  iOS-Geofence-Demo
//
//  Created by Kaodim MacMini on 30/12/2020.
//

import Foundation
import CoreLocation

protocol LocationServiceDelegate: class {

    /// Triggered when current location is entered into region
    func didEnterIntoRegion(region: CLRegion)

    /// Triggered when current location is exit the region
    func didExitIntoRegion(region: CLRegion)

    /// Triggered during location authorisation changes occur
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
}


class LocationService: NSObject, CLLocationManagerDelegate {

    var locationManager: CLLocationManager
    var lastLocation: CLLocation?
    weak var delegate: LocationServiceDelegate?

    override init() {
        self.locationManager = CLLocationManager()
        super.init()
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

    public func startMonitoringFor(region: CLRegion) {
        self.locationManager.startMonitoring(for: region)
    }

    public func stopMonitoringFor(region: CLRegion) {
        self.locationManager.stopMonitoring(for: region)
    }

    private func updateLocation(currentLocation: CLLocation) {
        // Implement to listen live location
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        delegate?.didExitIntoRegion(region: region)
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        delegate?.didEnterIntoRegion(region: region)
    }
}

extension CLLocationManager {
    // Check if location access granted
    func hasLocationPermission() -> Bool {
        if self.authorizationStatus != .authorizedWhenInUse && self.authorizationStatus != .authorizedAlways {
            return false
        }
        return true
    }
}
