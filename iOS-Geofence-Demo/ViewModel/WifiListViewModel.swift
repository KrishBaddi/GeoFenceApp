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
    private var dataSource: RegionDataSource
    weak var delegate:WifiListViewModelDelegate?

    private var hotspots: [HotSpot] = []
    
    internal init(_ dataSource: RegionDataSource) {
        self.dataSource = dataSource
    }

    func getAllHotSpots()  {
        dataSource.loadAllRegions { [weak self] (results) in
            switch results {
            case .success(let regions):
                self?.hotspots = regions.map(\.network)
                self?.delegate?.getAllHotSpots(self?.hotspots ?? [])
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
