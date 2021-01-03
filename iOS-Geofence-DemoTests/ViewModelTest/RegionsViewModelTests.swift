//
//  RegionsViewModelTests.swift
//  iOS-Geofence-DemoTests
//
//  Created by Kaodim MacMini on 03/01/2021.
//

import XCTest
@testable import iOS_Geofence_Demo

class RegionsViewModelTests: XCTestCase {

    func testFailAllFieldValidation() {

        // Setup our objects
        let mockDelegate = MockRegionsViewModelDelegate()
        let viewModel = RegionsViewModel(delegate: mockDelegate)
        viewModel.delegate = mockDelegate

        // Act
        viewModel.validator(nil, nil, nil)

        // Assert
        let result = try? XCTUnwrap(mockDelegate.validation) // 3
        XCTAssertFalse(result!)
    }

    func testFailNetworkNameFieldValidation() {

        // Setup our objects
        let mockDelegate = MockRegionsViewModelDelegate()
        let viewModel = RegionsViewModel(delegate: mockDelegate)
        viewModel.delegate = mockDelegate

        // Act
        viewModel.validator("Region", "500", nil)

        // Assert
        let result = try? XCTUnwrap(mockDelegate.validation) // 3
        XCTAssertFalse(result!)
    }

    func testFailRadiusFieldValidation() {

        // Setup our objects
        let mockDelegate = MockRegionsViewModelDelegate()
        let viewModel = RegionsViewModel(delegate: mockDelegate)
        viewModel.delegate = mockDelegate

        // Act
        viewModel.validator("Region", nil, "")

        // Assert
        let result = try? XCTUnwrap(mockDelegate.validation) // 3
        XCTAssertFalse(result!)
    }

    func testSuccessValidation() {

        // Setup our objects
        let mockDelegate = MockRegionsViewModelDelegate()
        let viewModel = RegionsViewModel(delegate: mockDelegate)
        viewModel.delegate = mockDelegate

        // Act
        viewModel.validator("Region", "500", "Network")

        // Assert
        let result = try? XCTUnwrap(mockDelegate.validation) // 3
        XCTAssertTrue(result!)
    }

    func testNewRegion() {
        // Setup our objects
        let mockDelegate = MockRegionsViewModelDelegate()
        let viewModel = RegionsViewModel(delegate: mockDelegate)
        viewModel.delegate = mockDelegate

        // Act
        let title = mockRegion.title
        let radius = mockRegion.radius
        let coordinates = mockRegion.getCoordinates()!
        let network = mockRegion.network.name
        viewModel.createRegion(title, radius, coordinates, network)

        // Assert
        let result = try? XCTUnwrap(mockDelegate.regionObject) // 3
        XCTAssertNotNil(result)
    }

}

class MockRegionsViewModelDelegate: RegionsViewModelDelegate {
    var validation: Bool!
    var regionObject: RegionObject!

    func getNewRegion(_ region: RegionObject) {
        self.regionObject = region
    }

    func isFieldsValidated(_ status: Bool) {
        validation = status
    }
}
