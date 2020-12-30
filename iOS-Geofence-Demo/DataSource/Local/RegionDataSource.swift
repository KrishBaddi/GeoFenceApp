//
//  RegionDataSource.swift
//  iOS-Geofence-Demo
//
//  Created by Kaodim MacMini on 30/12/2020.
//

import Foundation

enum DefaultsError: Error {
    case noDataFound
    case saveError
}

protocol RegionDataSourceProtocol {
    func loadAllRegions(_ completion: @escaping ((Result<[RegionObject], DefaultsError>) -> Void))
    func saveAllRegions(_ regions: [RegionObject],completion: @escaping ((Result<Bool, DefaultsError>) -> Void))
}

class RegionDataSource: RegionDataSourceProtocol {

    func loadAllRegions(_ completion: @escaping (((Result<[RegionObject], DefaultsError>)) -> Void)) {
            guard let savedData = RegionDefaultManager.shared.loadObject(forKey: .savedRegions), let data = savedData as? Data else {
            completion(Result.failure(.noDataFound))
            return
        }

        let decoder = JSONDecoder()
        if let result = try? decoder.decode(Array.self, from: data) as [RegionObject] {
            completion(Result.success(result))
        }
    }

    func saveAllRegions(_ regions: [RegionObject], completion: @escaping ((Result<Bool, DefaultsError>) -> Void)) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(regions)
            RegionDefaultManager.shared.saveObject(data, key: .savedRegions)
            completion(Result.success(true))
        } catch {
            completion(Result.failure(.saveError))
        }
    }
}
