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
    func didEnterRegion()
    func didExitRegion()
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
}


class LocationService: NSObject, CLLocationManagerDelegate {

    static let sharedInstance: LocationService = { LocationService() }()

    var locationManager: CLLocationManager?
    var lastLocation: CLLocation?
    weak var delegate: LocationServiceDelegate?

    override init() {
        super.init()

        self.locationManager = CLLocationManager()
        guard let locationManager = self.locationManager else {
            return
        }
//
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest // The accuracy of the location data
//        locationManager.distanceFilter = 100 // The minimum distance (measured in meters) a device must move horizontally before an update event is generated.
        locationManager.delegate = self
        locationManagerDidChangeAuthorization(locationManager)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            break
        case .notDetermined, .denied, .restricted:
            manager.requestAlwaysAuthorization()
        default:
            break
        }
    }

    func startUpdatingLocation() {
        print("Starting Location Updates")
        self.locationManager?.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        print("Stop Location Updates")
        self.locationManager?.stopUpdatingLocation()
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

    public func startMonitoringFor( region: CLRegion) {
        self.locationManager?.startMonitoring(for: region)
    }

    private func updateLocation(currentLocation: CLLocation) {
        delegate?.tracingLocation(currentLocation: currentLocation)
    }

    private func updateLocationDidFailWithError(error: NSError) {
        delegate?.tracingLocationDidFailWithError(error: error)
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        delegate?.didExitRegion()
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        delegate?.didEnterRegion()
    }
}
