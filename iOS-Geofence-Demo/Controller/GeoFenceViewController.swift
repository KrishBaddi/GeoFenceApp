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
    var regionObjects: [RegionObject] = []

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
        loadAllGeotifications()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            LocationService.sharedInstance.startUpdatingLocation()
        }
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


    // MARK: Loading and saving functions
    func loadAllGeotifications() {
        regionObjects.removeAll()

        self.viewModel.loadRegions({ (objects) in
            self.regionObjects = objects
            self.regionObjects.forEach { self.add($0) }
        })
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

    }

    // MARK: Functions that update the model/associated views with geotification changes
    func add(_ region: RegionObject) {
        if let annotation = region.annotableRegion() {
            mapView.addAnnotation(annotation)
        }

        addRadiusOverlay(forRegion: region)
        //updateGeotificationsCount()
    }

    func remove(_ annotation: RegionAnnotation) {

        mapView.removeAnnotation(annotation)
        if let region = self.regionObjects.first(where: { $0.id == annotation.regionId }) {
            removeRadiusOverlay(forRegion: region)
            regionObjects.removeAll(where: { $0 == region })
        }
        //updateGeotificationsCount()
    }


    func addRadiusOverlay(forRegion region: RegionObject) {
        if let coordinates = region.getCoordinates() {
            mapView.addOverlay(MKCircle.init(center: coordinates, radius: CLLocationDistance(region.radius)))
        }
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
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = .red
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)

    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "myGeoFence"
        if annotation is RegionAnnotation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                let removeButton = UIButton(type: .custom)
                removeButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
                removeButton.setImage(UIImage(named: "DeleteGeotification")!, for: .normal)
                annotationView?.leftCalloutAccessoryView = removeButton
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }
        return nil
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Delete Region
        if let annotation = view.annotation as? RegionAnnotation {
            remove(annotation)
        }
        //saveAllGeotifications(
    }
}

