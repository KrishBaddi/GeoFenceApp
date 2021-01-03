//
//  GeoFenceDetectorService.swift
//  iOS-Geofence-Demo
//
//  Created by Kaodim MacMini on 01/01/2021.
//

import Foundation

protocol GeoFenceDetectorServiceDelegate: class {
    func didEnteredRegion(_ name: String)
    func didExitRegion(_ name: String)
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

    private var tempRegion: RegionObject? {
        didSet {

        }
    }


    func setCurrentRegion(_ region: RegionObject) {
        if currentWifi == nil {
            let name = region.title
            self.currentRegion = region
            self.tempRegion = region
            detectRegionChanges(name)
        }
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
            self.tempRegion = region
            self.currentWifi = network
            didChangeWifi()
            let name = currentRegion?.title ?? ""
            detectRegionChanges(name)
        }
    }

    func exitedRegion() {
        // When exiting fence region just nullfiy current region
        let name = currentRegion?.title ?? ""
        self.currentRegion = nil
        detectRegionChanges(name)
    }

    func disconnectWifi() {
        // Check if exited both fence region and wifi region
        if checkIfExitedRegionAndWifi() {
            let name = tempRegion?.title ?? ""
            tempRegion = nil
            currentWifi = nil
            detectRegionChanges(name)
            didChangeWifi()
        } else {
            // Notify wifi changes only if there is wifi connected
            if currentWifi != nil {
                currentWifi = nil
                didChangeWifi()

                // Notify entry/exit changes only if wifi was connected
                // but not through fence region
                if tempRegion == nil {
                    let name = currentRegion?.title ?? ""
                    currentRegion = nil
                    detectRegionChanges(name)
                }
            }
        }
    }

    func detectRegionChanges(_ regionName: String) {

        if currentWifi == nil && currentRegion == nil {
            // Notify exit when wifi is disconnected and current location is exited region
            self.delegate?.didExitRegion(regionName)
        } else if currentRegion?.network == currentWifi {
            // Notify if current wifi is connected to its own region
            self.delegate?.didEnteredRegion(regionName)
        } else if currentRegion != nil {
            // Notify if current location entered into region and no wifi connected
            self.delegate?.didEnteredRegion("\(regionName)")
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
