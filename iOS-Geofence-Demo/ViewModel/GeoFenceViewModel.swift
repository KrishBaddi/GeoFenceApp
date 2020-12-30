//
//  GeoFenceViewModel.swift
//  iOS-Geofence-Demo
//
//  Created by Kaodim MacMini on 30/12/2020.
//

import Foundation


class GeoFenceViewModel {
    internal init(_ dataSoruce: RegionDataSource) {
        self.dataSource = dataSoruce
    }

    private var dataSource: RegionDataSource

    private var regions: [RegionObject] = []

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

    public func loadRegions() {
        dataSource.loadAllRegions { (result) in
            switch result {
            case .success(let results):
                self.regions = results
            case .failure(let error):
                print(error)
            }
        }
    }
}
