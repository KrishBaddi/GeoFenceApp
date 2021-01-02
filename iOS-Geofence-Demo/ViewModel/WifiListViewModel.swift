//
//  WifiListViewModel.swift
//  iOS-Geofence-Demo
//
//  Created by Kaodim MacMini on 01/01/2021.
//

import Foundation

protocol WifiListViewModelDelegate: class {
    func getAllHotSpots(_ hotspots: [HotSpot])
}

class WifiListViewModel {
    private var regions: [RegionObject] = []
    weak var delegate: WifiListViewModelDelegate?

    private var hotspots: [HotSpot] = []

    internal init(_ regions: [RegionObject]) {
        self.regions = regions
    }

    func getAllHotSpots() {
        self.hotspots = regions.map(\.network)
        self.delegate?.getAllHotSpots(self.hotspots)
    }
}
