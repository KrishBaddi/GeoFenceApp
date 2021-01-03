//
//  MockGeoFenceDetectorDelegates.swift
//  iOS-Geofence-DemoTests
//
//  Created by Kaodim MacMini on 03/01/2021.
//

import Foundation
@testable import iOS_Geofence_Demo

class MockGeoFenceDetectorDelegates: GeoFenceDetectorServiceDelegate {

    var isConnectedToWifi: Bool = false
    var isDisconnectedToWifi: Bool = false
    var isEnteredInRegion: Bool = false
    var isExitedRegion: Bool = false

    func didEnteredRegion(_ name: String) {
        isEnteredInRegion = true
    }

    func didExitRegion(_ name: String) {
        isExitedRegion = true
    }

    func connectedToWifi(_ networkName: String) {
        isConnectedToWifi = true
    }

    func wifiDisconnected() {
        isDisconnectedToWifi = true
    }
}
