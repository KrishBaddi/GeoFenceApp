//
//  GeoFenceDetectorService.swift
//  iOS-Geofence-Demo
//
//  Created by Kaodim MacMini on 01/01/2021.
//

import Foundation

protocol GeoFenceDetectorServiceDelegate: class {
    func didEnteredRegion(_ name: String)
    func didExitRegion()
    func connectedToWifi(_ networkName: String)
    func wifiDisconnected()
}

class GeoFenceDetectorService {

    weak var delegate: GeoFenceDetectorServiceDelegate?

    internal init(delegate: GeoFenceDetectorServiceDelegate? = nil, currentWifi: HotSpot? = nil, currentRegion: RegionObject? = nil) {
        self.delegate = delegate
        self.currentWifi = currentWifi
        self.currentRegion = currentRegion
    }

    public func setDelegate(delegate: GeoFenceDetectorServiceDelegate?) {
        self.delegate = delegate
    }

    private var currentWifi: HotSpot?

    private var currentRegion: RegionObject?

    private var tempRegion: RegionObject?


    func setCurrentRegion(_ region: RegionObject) {
        self.currentRegion = region
        self.tempRegion = region
        detectRegionChanges()
    }

    func setCurrentWifi(_ region: RegionObject, _ network: HotSpot?) {
        // If current fence region is connected to same wifi of region
        // Just update the wifi connection
        if let currentRegion = currentRegion, let network = network, currentRegion.network.id == network.id {
            self.currentWifi = network
            didChangeWifi()
        } else {

            // Else notify entered into the region and wifi area
            self.currentRegion = region
            self.currentWifi = network
            didChangeWifi()
            detectRegionChanges()
        }
    }

    func exitedRegion() {
        // When exiting fence region just nullfiy current region
        self.currentRegion = nil
        detectRegionChanges()
    }

    func disconnectWifi() {
        // Check if exited both fence region and wifi region
        if checkIfExitedRegionAndWifi() {
            tempRegion = nil
            currentWifi = nil
            detectRegionChanges()
            didChangeWifi()
        } else {
            // Notify wifi changes only if there is wifi connected
            if currentWifi != nil {
                currentWifi = nil
                didChangeWifi()

                // Notify entry/exit changes only if wifi was connected
                // but not through fence region
                if tempRegion == nil {
                    currentRegion = nil
                    detectRegionChanges()
                }
            }
        }
    }

    func detectRegionChanges() {
        
        if currentWifi == nil && currentRegion == nil {
            // Notify exit when wifi is disconnected and current location is exited region
            self.delegate?.didExitRegion()
        } else if currentRegion?.network == currentWifi {
            // Notify if current wifi is connected to its own region
            self.delegate?.didEnteredRegion(currentRegion?.title ?? "")
        } else if currentRegion != nil {
            // Notify if current location entered into region and no wifi connected
            self.delegate?.didEnteredRegion(currentRegion?.title ?? "")
        }
    }

    func didChangeWifi() {
        if currentWifi != nil {
            self.delegate?.connectedToWifi(currentWifi?.name ?? "")
        } else {
            self.delegate?.wifiDisconnected()
        }
    }

    // If the current location is outside the fence region
    // but still connected to same wifi of that old fence region
    // Then it still inside the main region
    func checkIfExitedRegionAndWifi() -> Bool {
        guard let currentWifi = currentWifi, let tempRegion = tempRegion else {
            return false
        }
        if currentWifi.id == tempRegion.network.id && currentRegion == nil {
            return true
        } else {
            return false
        }
    }
}
