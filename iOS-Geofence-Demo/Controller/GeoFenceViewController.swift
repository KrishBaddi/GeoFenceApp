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
        view.isZoomEnabled = true
        view.isRotateEnabled = true
        view.showsBuildings = true
        view.isScrollEnabled = true
        view.showsCompass = true
        view.showsUserLocation = true
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
        setupNavigationButtons()

        mapView.delegate = self
        saveData()
        LocationService.sharedInstance.startUpdatingLocation()

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

    func setupNavigationButtons() {
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(systemName: "location"), style: .plain, target: self, action: #selector(self.locationTapped))
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

    @objc func locationTapped() {
        mapView.zoomToUserLocation()
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.drawOverlays(regionObject: region)
        }
    }


    func addRadiusOverlay(forRegion region: RegionObject) {
        if let coordinates = region.getCoordinates() {
            mapView.addOverlay(MKCircle.init(center: coordinates, radius: CLLocationDistance(region.radius)))
        }
    }

    func drawOverlays(regionObject: RegionObject) {

        guard let location = regionObject.getCoordinates() else {
            return
        }

        let radius = CLLocationDistance(regionObject.radius)

        // startMonitoring

        LocationService.sharedInstance.startMonitoringFor(region: region(with: location, radius: radius))
        ///
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)

        // add annotation

        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = regionObject.title
        mapView.addAnnotation(annotation)

        // show overlay

        let circle = MKCircle(center: location,
            radius: radius)
        mapView.addOverlay(circle)
    }

    func region(with coordinate2D: CLLocationCoordinate2D, radius: Double) -> CLCircularRegion {
        let region = CLCircularRegion(center: coordinate2D, radius: radius, identifier: String().randomString(length: 10))
        region.notifyOnEntry = true
        region.notifyOnExit = true
        return region
    }

    func removeRadiusOverlay(forRegion region: RegionObject) {
        // Find exactly one overlay which has the same coordinates & radius to remove
        let overlays = mapView.overlays
        for overlay in overlays {
            guard let circleOverlay = overlay as? MKCircle else { continue }
            let coord = circleOverlay.coordinate
            if let regionCoordinates = region.getCoordinates() {
                if coord.latitude == regionCoordinates.latitude && coord.longitude == regionCoordinates.longitude && circleOverlay.radius == CLLocationDistance(region.radius) {
                    mapView.removeOverlay(circleOverlay)
                    break
                }
            }

        }
    }
}

extension GeoFenceViewController: LocationServiceDelegate {
    func tracingLocation(currentLocation: CLLocation) {
    }

    func tracingLocationDidFailWithError(error: NSError) {
    }

    func didEnterRegion() {
    }

    func didExitRegion() {
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapView.showsUserLocation = status == .authorizedAlways
    }


}
extension MKMapView {
    func zoomToUserLocation() {
        guard let coordinate = userLocation.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        setRegion(region, animated: true)
    }
}



extension GeoFenceViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView,
        rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        if let circleOverlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: circleOverlay)
            circleRenderer.fillColor = .red
            circleRenderer.alpha = 0.5

            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)

    }
}

