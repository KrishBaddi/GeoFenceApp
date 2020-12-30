//
//  GeoFenceViewModel.swift
//  iOS-Geofence-Demo
//
//  Created by Kaodim MacMini on 30/12/2020.
//

import Foundation

class GeoFenceDataSource {

}

class GeoFenceViewModel {
    internal init(_ dataSoruce: GeoFenceDataSource) {
        self.dataSoruce = dataSoruce
    }
    
    private var dataSoruce:GeoFenceDataSource
}
