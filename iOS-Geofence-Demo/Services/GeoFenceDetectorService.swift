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

    var currentWifi: HotSpot? {
        didSet {
            didChangeWifi()
        }
    }

    var currentRegion: RegionObject? {
        didSet {
            detectRegion()
        }
    }

    func detectRegion() {
        if currentWifi == nil && currentRegion == nil {
            self.delegate?.didExitRegion()
        } else if currentRegion?.network == currentWifi {
            self.delegate?.didEnteredRegion(currentRegion?.title ?? "")
        } else if currentRegion != nil {
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
}
