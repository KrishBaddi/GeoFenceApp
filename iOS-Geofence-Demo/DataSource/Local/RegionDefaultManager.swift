//
//  RegionDefaultManager.swift
//  iOS-Geofence-Demo
//
//  Created by Kaodim MacMini on 30/12/2020.
//

import Foundation

public enum RegionDefaultManagerKey: String {
    case savedRegions
}


public struct RegionDefaultManager {
    fileprivate let regionDefaults = UserDefaults.standard
    fileprivate init() { }

    static var shared: RegionDefaultManager {
        return RegionDefaultManager()
    }

    func saveObject<T>(_ object: T?, key: RegionDefaultManagerKey) {
        guard object != nil else { return }

        regionDefaults.set(object, forKey: key.rawValue)
        regionDefaults.synchronize()
    }

    func loadObject(forKey key: RegionDefaultManagerKey) -> AnyObject? {
        if let value = regionDefaults.object(forKey: key.rawValue) {
            return value as AnyObject?
        } else {
            return nil
        }
    }
}
