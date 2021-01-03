//
//  MockRegionDataSource.swift
//  iOS-Geofence-DemoTests
//
//  Created by Kaodim MacMini on 02/01/2021.
//

import Foundation
@testable import iOS_Geofence_Demo

class MockRegionDataSource: RegionDataSourceProtocol {
    func loadAllRegions(_ completion: @escaping ((Result<[RegionObject], DefaultsError>) -> Void)) {
        completion(Result.success(mockRegionObjects))
    }

    func saveAllRegions(_ regions: [RegionObject], completion: @escaping ((Result<Bool, DefaultsError>) -> Void)) {
        completion(Result.success(true))
    }
}

class MockFailureRegionDataSource: RegionDataSourceProtocol {
    func loadAllRegions(_ completion: @escaping ((Result<[RegionObject], DefaultsError>) -> Void)) {
        completion(Result.failure(DefaultsError.noDataFound))
    }

    func saveAllRegions(_ regions: [RegionObject], completion: @escaping ((Result<Bool, DefaultsError>) -> Void)) {
        completion(Result.failure(.saveError))
    }
}
