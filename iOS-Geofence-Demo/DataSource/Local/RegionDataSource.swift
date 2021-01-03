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

    var message: String {
        switch self {
        case .noDataFound:
            return "No data found"
        case .saveError:
            return "Error while saving data"
        }
    }
}

protocol RegionDataSourceProtocol {
    func loadAllRegions(_ completion: @escaping ((Result<[RegionObject], DefaultsError>) -> Void))
    func saveAllRegions(_ regions: [RegionObject], completion: @escaping ((Result<Bool, DefaultsError>) -> Void))
}

class RegionDataSource: RegionDataSourceProtocol {

    func loadAllRegions(_ completion: @escaping (((Result<[RegionObject], DefaultsError>)) -> Void)) {
        // First load data object for the key from defaults manager
        if let savedData = RegionDefaultManager.shared.loadObject(forKey: .savedRegions), let data = savedData as? Data {
            // Parse the Region object using decoder
            let decoder = JSONDecoder()
            if let result = try? decoder.decode(Array.self, from: data) as [RegionObject] {
                completion(Result.success(result))
            }
        } else {
            completion(Result.failure(.noDataFound))
            return
        }
    }

    func saveAllRegions(_ regions: [RegionObject], completion: @escaping ((Result<Bool, DefaultsError>) -> Void)) {
        let encoder = JSONEncoder()
        do {
            // Convert Region object to data
            let data = try encoder.encode(regions)
            // Save into defaults
            RegionDefaultManager.shared.saveObject(data, key: .savedRegions)
            completion(Result.success(true))
        } catch {
            completion(Result.failure(.saveError))
        }
    }
}
