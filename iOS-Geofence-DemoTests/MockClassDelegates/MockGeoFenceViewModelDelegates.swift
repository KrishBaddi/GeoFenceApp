//
//  MockGeoFenceViewModelDelegates.swift
//  iOS-Geofence-DemoTests
//
//  Created by Kaodim MacMini on 03/01/2021.
//

import Foundation
@testable import iOS_Geofence_Demo

class MockGeoFenceViewModelDelegates: GeoFenceViewModelDelegate {

    var regions: [RegionObject]? = [] // 1
    var hotspots: [HotSpot] = []
    var saveStatus: Bool = false

    func reloadData(_ regions: [RegionObject]) {
        self.regions = regions
    }

    func networkListLoaded(_ hotspots: [HotSpot]) {
        self.hotspots = hotspots
    }

    func stopMonitoringRegion(_ region: RegionObject) {

    }

    func showError(_ error: String) {

    }

    func savedResult(_ status: Bool) {
        self.saveStatus = status
    }
}

