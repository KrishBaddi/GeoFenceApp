//
//  GeoFenceViewModelTests.swift
//  iOS-Geofence-DemoTests
//
//  Created by Kaodim MacMini on 02/01/2021.
//

import XCTest
@testable import iOS_Geofence_Demo

class GeoFenceViewModelTests: XCTestCase {

    func testLoadRegions() {

        // Setup our objects
        let datasource = MockRegionDataSource()
        let mockDelegate = MockGeoFenceViewModelDelegates()
        let viewModel = GeoFenceViewModel(datasource, GeoFenceDetectorService())
        viewModel.delegate = mockDelegate

        // Act
        viewModel.loadRegions()

        // Assert
        //waitForExpectations(timeout: 1)

        let result = try? XCTUnwrap(mockDelegate.regions) // 3
        XCTAssertEqual(result?.count, 3)
    }


    func testSaveAllRegions() {
        // Setup our objects
        let datasource = MockRegionDataSource()
        let mockDelegate = MockGeoFenceViewModelDelegates()
        let viewModel = GeoFenceViewModel(datasource, GeoFenceDetectorService())
        viewModel.delegate = mockDelegate

        // Act
        viewModel.saveAllRegion()

        // Assert
        //waitForExpectations(timeout: 1)

        let result = try? XCTUnwrap(mockDelegate.saveStatus) // 3
        XCTAssertEqual(result, true)
    }

    func testSaveRegion() {
        // Setup our objects
        let datasource = MockRegionDataSource()
        let mockDelegate = MockGeoFenceViewModelDelegates()
        let viewModel = GeoFenceViewModel(datasource, GeoFenceDetectorService())
        viewModel.delegate = mockDelegate

        // Act
        viewModel.saveRegionData(mockRegion)

        let result = try? XCTUnwrap(mockDelegate.saveStatus) // 3
        XCTAssertEqual(result, true)
    }

    func testDeleteRegion() {
        // Setup our objects
        let datasource = MockRegionDataSource()
        let mockDelegate = MockGeoFenceViewModelDelegates()
        let viewModel = GeoFenceViewModel(datasource, GeoFenceDetectorService())
        viewModel.delegate = mockDelegate

        // Act

        viewModel.saveRegionData(mockRegion)
        viewModel.deleteRegion(mockRegion.annotableRegion()!)

        let result = try? XCTUnwrap(mockDelegate.saveStatus) // 3
        XCTAssertEqual(result, true)
    }

    func testloadHotspots() {
        // Setup our objects
        let datasource = MockRegionDataSource()
        let mockDelegate = MockGeoFenceViewModelDelegates()
        let viewModel = GeoFenceViewModel(datasource, GeoFenceDetectorService())
        viewModel.delegate = mockDelegate

        // Act
        viewModel.loadRegions()
        viewModel.loadNetworkList()

        // Assert
        let result = try? XCTUnwrap(mockDelegate.hotspots) // 3
        XCTAssertEqual(result?.count, 3)
    }

    func testConnectWifiAndRegion() {
        // Setup our objects
        let datasource = MockRegionDataSource()
        let mockDelegate = MockGeoFenceViewModelDelegates()
        let fenceDetector = GeoFenceDetectorService()
        let viewModel = GeoFenceViewModel(datasource, fenceDetector)

        let mockDetectorDelegate = MockGeoFenceDetectorDelegates()
        viewModel.setDetectorDelegate(delegate: mockDetectorDelegate)
        viewModel.delegate = mockDelegate

        // Act
        viewModel.loadRegions()
        viewModel.connectWifi(mockNetwork)

        // Assert
        let wifiConnected = try? XCTUnwrap(mockDetectorDelegate.isConnectedToWifi) // 3
        let regionEntered = try? XCTUnwrap(mockDetectorDelegate.isEnteredInRegion)
        XCTAssert(wifiConnected!)
        XCTAssert(regionEntered!)
    }

    func testDisconnectWifi() {
        // Setup our objects
        let datasource = MockRegionDataSource()
        let mockDelegate = MockGeoFenceViewModelDelegates()
        let fenceDetector = GeoFenceDetectorService()
        let viewModel = GeoFenceViewModel(datasource, fenceDetector)

        let mockDetectorDelegate = MockGeoFenceDetectorDelegates()
        viewModel.setDetectorDelegate(delegate: mockDetectorDelegate)
        viewModel.delegate = mockDelegate

        // Act
        viewModel.loadRegions()
        viewModel.connectWifi(mockNetwork)
        viewModel.disconnectWifi()

        // Assert
        let isDisconnectedToWifi = try? XCTUnwrap(mockDetectorDelegate.isDisconnectedToWifi) // 3
        XCTAssert(isDisconnectedToWifi!)
    }

    func testEnterAndExitIntoFence() {
        // Setup our objects
        let datasource = MockRegionDataSource()
        let mockDelegate = MockGeoFenceViewModelDelegates()
        let fenceDetector = GeoFenceDetectorService()
        let viewModel = GeoFenceViewModel(datasource, fenceDetector)

        let mockDetectorDelegate = MockGeoFenceDetectorDelegates()
        viewModel.setDetectorDelegate(delegate: mockDetectorDelegate)
        viewModel.delegate = mockDelegate

        // Act
        viewModel.loadRegions()
        viewModel.didEnterRegion(mockRegion.id)
        viewModel.didExitRegion(mockRegion.id)

        // Assert
        let isEnteredRegion = try? XCTUnwrap(mockDetectorDelegate.isEnteredInRegion)
        let isExitedRegion = try? XCTUnwrap(mockDetectorDelegate.isExitedRegion)
        XCTAssert(isEnteredRegion!)
        XCTAssert(isExitedRegion!)
    }

    func testConnectWifiAndEnterExitFence() {
        // Setup our objects
        let datasource = MockRegionDataSource()
        let mockDelegate = MockGeoFenceViewModelDelegates()
        let fenceDetector = GeoFenceDetectorService()
        let viewModel = GeoFenceViewModel(datasource, fenceDetector)

        let mockDetectorDelegate = MockGeoFenceDetectorDelegates()
        viewModel.setDetectorDelegate(delegate: mockDetectorDelegate)
        viewModel.delegate = mockDelegate

        // Act
        viewModel.loadRegions()
        viewModel.connectWifi(mockNetwork)
        viewModel.didEnterRegion(mockRegion.id)
        viewModel.didExitRegion(mockRegion.id)

        // Assert
        let isEnteredRegion = try? XCTUnwrap(mockDetectorDelegate.isEnteredInRegion)
        let isExitedRegion = try? XCTUnwrap(mockDetectorDelegate.isExitedRegion)
        XCTAssert(isEnteredRegion!)
        XCTAssert(!isExitedRegion!)
    }
}
