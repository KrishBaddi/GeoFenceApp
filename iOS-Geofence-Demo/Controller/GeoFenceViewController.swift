//
//  GeoFenceViewController.swift
//  iOS-Geofence-Demo
//
//  Created by Kaodim MacMini on 30/12/2020.
//

import UIKit
import CoreLocation
import MapKit

protocol GeoFenceListControllerFactory {
    func makeViewController() -> GeoFenceViewController
    func makeGeoFenceViewModel() -> GeoFenceViewModel
    func makeGeoFenceDataSource() -> RegionDataSource
}

open class GeoFenceDependencyContainer: GeoFenceListControllerFactory {
    func makeViewController() -> GeoFenceViewController {
        GeoFenceViewController(factory: self)
    }

    func makeGeoFenceViewModel() -> GeoFenceViewModel {
        GeoFenceViewModel(makeGeoFenceDataSource())
    }

    func makeGeoFenceDataSource() -> RegionDataSource {
        RegionDataSource()
    }
}


class GeoFenceViewController: UIViewController {

    // MARK: - Dependency Injection

    // Here we use protocol composition to create a Factory type that includes
    // all the factory protocols that this view controller needs.
    typealias Factory = GeoFenceListControllerFactory

    lazy var viewModel = factory.makeGeoFenceViewModel()
    private let factory: Factory
    private var contentView = UIView()

    lazy var mapView: MKMapView = {
        let view = MKMapView()
        return view
    }()

    init(factory: Factory) {
        self.factory = factory
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("Deallocated...")
    }

    override func loadView() {
        super.loadView()

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        setUpContentView()

        saveData()
    }

    func setUpContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        let constraints: [NSLayoutConstraint] = [
            contentView.topAnchor.constraint(equalTo: safeTopAnchor),
            contentView.leadingAnchor.constraint(equalTo: safeLeadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: safeTrailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: safeBottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        setUpMapView()
    }

    func setUpMapView() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mapView)

        let constraints: [NSLayoutConstraint] = [
            mapView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    func saveData() {
        let id = String().randomString(length: 3)
        let coordinates = Coordinates(id: id, latitude: "3.1303358056425137", longitude: "101.62857783322326")

        let networkId = String().randomString(length: 3)
        let hotspot = HotSpot(id: networkId, name: "Network(\(networkId))", radius: 5)

        let regionId = String().randomString(length: 3)
        let region = RegionObject(id: regionId, title: "Region \(regionId)", radius: 100, coordinates: coordinates, network: hotspot)

        self.viewModel.saveRegionData([region])

        self.viewModel.loadRegions()
    }
}
