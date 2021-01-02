//
//  GeoFenceViewModel.swift
//  iOS-Geofence-Demo
//
//  Created by Kaodim MacMini on 30/12/2020.
//

import Foundation
import CoreLocation

protocol GeoFenceViewModelDelegate: class {
    func reloadData(_ regions: [RegionObject])
}

class GeoFenceViewModel {

    private var dataSource: RegionDataSource
    private var fenceDetector: GeoFenceDetectorService
    private var regions: [RegionObject] = []
    weak var delegate: GeoFenceViewModelDelegate?

    internal init(_ dataSource: RegionDataSource, _ fenceDetector: GeoFenceDetectorService) {
        self.dataSource = dataSource
        self.fenceDetector = fenceDetector
    }

    public func setDetectorDelegate(delegate: GeoFenceDetectorServiceDelegate?) {
        self.fenceDetector.setDelegate(delegate: delegate)
    }

    public func saveRegionData(_ region: RegionObject) {
        self.regions.append(region)
        dataSource.saveAllRegions(regions) { (results) in
            switch results {
            case .success(let _):
                break
            case .failure(let error):
                print(error)
            }
        }
    }

    public func saveAllRegion() {
        dataSource.saveAllRegions(regions) { (results) in
            switch results {
            case .success(let _):
                break
            case .failure(let error):
                print(error)
            }
        }
    }

    public func loadRegions() {
        dataSource.loadAllRegions { (result) in
            switch result {
            case .success(let results):
                self.regions = results
                self.delegate?.reloadData(self.regions)
            case .failure(let error):
                print(error)
            }
        }
    }

    public func getAllRegions() -> [RegionObject] {
        self.regions
    }

    public func deleteRegion(_ id: String) {
        if let index = self.regions.firstIndex(where: { $0.id == id }) {
            self.regions.remove(at: index)
            self.saveAllRegion()
        }
    }

    func connectWifi(_ hotspot: HotSpot) {
        if let regionObject = self.regions.first(where: { $0.network == hotspot }) {
            fenceDetector.setCurrentWifi(regionObject, hotspot)
        }
    }

    func disconnectWifi() {
        fenceDetector.disconnectWifi()
    }

    func didEnterRegion(_ region: CLRegion) {
        if let regionObject = self.regions.first(where: { $0.id == region.identifier }) {
            fenceDetector.setCurrentRegion(regionObject)
        }
    }

    func didExitRegion(_ region: CLRegion) {
        fenceDetector.exitedRegion()
    }
}
