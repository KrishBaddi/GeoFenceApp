//
//  MockWifiListViewModelDelegate.swift
//  iOS-Geofence-DemoTests
//
//  Created by Kaodim MacMini on 03/01/2021.
//

import Foundation
@testable import iOS_Geofence_Demo

class MockWifiListViewModelDelegate: WifiListViewModelDelegate {
    var count = 0
    func networkListLoaded(_ hotspots: [HotSpot]) {
        count = hotspots.count
    }
}
