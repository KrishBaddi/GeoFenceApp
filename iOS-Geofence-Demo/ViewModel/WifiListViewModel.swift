//
//  WifiListViewModel.swift
//  iOS-Geofence-Demo
//
//  Created by Kaodim MacMini on 01/01/2021.
//

import Foundation

protocol WifiListViewModelDelegate: class {
    func networkListLoaded(_ hotspots: [HotSpot])
}

class WifiListViewModel {
    weak var delegate: WifiListViewModelDelegate?

    private var hotspots: [HotSpot] = []

    internal init(_ hotspots: [HotSpot]) {
        self.hotspots = hotspots
    }

    func getAllNetwork() {
        self.delegate?.networkListLoaded(self.hotspots)
    }
}
