//
//  GeoFenceViewModel.swift
//  iOS-Geofence-Demo
//
//  Created by Kaodim MacMini on 30/12/2020.
//

import Foundation
import CoreLocation

class GeoFenceViewModel {

    private var dataSource: RegionDataSource
    private var fenceDetector: GeoFenceDetectorService
    private var regions: [RegionObject] = []

    internal init(_ dataSource: RegionDataSource, _ fenceDetector: GeoFenceDetectorService) {
        self.dataSource = dataSource
        self.fenceDetector = fenceDetector
    }

    public func setDetectorDelegate(delegate: GeoFenceDetectorServiceDelegate?) {
        self.fenceDetector.setDelegate(delegate: delegate)
    }

    public func saveRegionData(_ regions: [RegionObject]) {
        dataSource.saveAllRegions(regions) { (results) in
            switch results {
            case .success(let results):
                print(results)
            case .failure(let error):
                print(error)
            }
        }
    }

    public func loadRegions(_ completion: (([RegionObject]) -> Void)?) {
        dataSource.loadAllRegions { (result) in
            switch result {
            case .success(let results):
                self.regions = results
                completion?(results)
            case .failure(let error):
                print(error)
            }
        }
    }


    public func getAllRegions() {
        // Return using the delegate
    }

    public func deleteRegion(_ id: String) {
        // referesh the data using delegate
    }

    func connectWifi(_ hotspot: HotSpot) {
        fenceDetector.currentWifi = hotspot
    }

    func disconnectWifi() {
        fenceDetector.currentWifi = nil
    }

    func didEnterRegion(_ region: CLRegion) {
        if let regionObject = self.regions.first(where: { $0.id == region.identifier }) {
            fenceDetector.currentRegion = regionObject
        }
    }

    func didExitRegion(_ region: CLRegion) {
        fenceDetector.currentRegion = nil
    }
}
