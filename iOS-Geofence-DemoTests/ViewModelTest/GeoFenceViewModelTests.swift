//
//  GeoFenceViewModelTests.swift
//  iOS-Geofence-DemoTests
//
//  Created by Kaodim MacMini on 02/01/2021.
//

import XCTest
@testable import iOS_Geofence_Demo

class GeoFenceViewModelTests: XCTestCase {

    var expectation: XCTestExpectation?
    var regions: [RegionObject]?

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }



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

    func testConnectWifi() {
        // Setup our objects
        let datasource = MockRegionDataSource()
        let mockDelegate = MockGeoFenceViewModelDelegates()
        let fenceDetector = GeoFenceDetectorService()
        let viewModel = GeoFenceViewModel(datasource, fenceDetector)
        viewModel.delegate = mockDelegate

        // Act
        viewModel.loadRegions()
        viewModel.connectWifi(mockNetwork)

        // Assert
        //XCTAssertNotNil()
    }
}


class MockGeoFenceViewModelDelegates: GeoFenceViewModelDelegate {

    var regions: [RegionObject]? = [] // 1
    var hotspots: [HotSpot] = []
    var saveStatus: Bool = false

    private var expectation: XCTestExpectation? // 2

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

