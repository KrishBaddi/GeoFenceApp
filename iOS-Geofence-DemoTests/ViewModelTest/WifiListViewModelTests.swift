//
//  WifiListViewModelTests.swift
//  iOS-Geofence-DemoTests
//
//  Created by Kaodim MacMini on 03/01/2021.
//

import XCTest
@testable import iOS_Geofence_Demo

class WifiListViewModelTests: XCTestCase {

    func testLoadNetwork() {

        // Setup our objects
        let mockDelegate = MockWifiListViewModelDelegate()
        let mockList = [mockNetwork,mockNetwork,mockNetwork]
        let viewModel = WifiListViewModel(mockList)
        viewModel.delegate = mockDelegate

        // Act
        viewModel.getAllNetwork()

        // Assert
        let result = try? XCTUnwrap(mockDelegate.count) // 3
        XCTAssertEqual(result!, mockList.count)
    }
}
