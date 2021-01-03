//
//  MockRegionObject.swift
//  iOS-Geofence-DemoTests
//
//  Created by Kaodim MacMini on 02/01/2021.
//

import Foundation
@testable import iOS_Geofence_Demo


let mockCoordinates = Coordinates(id: String().randomString(length: 3), latitude: 3.1303358056425137, longitude: 101.62857783322326)
let mockNetwork = HotSpot(id: String().randomString(length: 3), name: "TestNetwork", radius: 100)
let mockRegion = RegionObject.init(id: String().randomString(length: 3), title: "Petronus TTDI", radius: 500, coordinates: mockCoordinates, network: mockNetwork)

let mockRegionObjects = [mockRegion, mockRegion, mockRegion]
