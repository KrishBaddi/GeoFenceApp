//
//  GeoFenceViewController.swift
//  iOS-Geofence-Demo
//
//  Created by Kaodim MacMini on 30/12/2020.
//

import UIKit
import CoreLocation
import MapKit

protocol GeoFenceControllerDelegate: class {
    func addRegion(_ region: RegionObject)
}

protocol GeoFenceControllerFactory {
    func makeViewController() -> GeoFenceViewController
    func makeGeoFenceViewModel() -> GeoFenceViewModel
    func makeGeoFenceDataSource() -> RegionDataSource
}

open class GeoFenceDependencyContainer: GeoFenceControllerFactory {
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
    typealias Factory = GeoFenceControllerFactory

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
        loadAllRegions()

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
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(systemName: "location"), style: .plain, target: self, action: #selector(self.locationTapped))

        navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(systemName: "plus"), style: .plain, target: self, action: #selector(self.addRegionTapped))
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
    func loadAllRegions() {
        regionObjects.removeAll()

        self.viewModel.loadRegions({ [weak self] (objects) in
            guard let self = self else { return }
            self.regionObjects = objects
            self.regionObjects.forEach { self.add($0) }

            if let firstRegion = self.regionObjects.first {
                self.setVisibleRegion(firstRegion)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.mapView.zoomToUserLocation()
                }
            }
        })
    }

    @objc func locationTapped() {
        mapView.zoomToUserLocation()
    }

    @objc func addRegionTapped() {
        let container = RegionsDependencyContainer(delegate: self)
        if let viewController = container.makeViewController() {
            let navController = UINavigationController(rootViewController: viewController)
            self.present(navController, animated: true, completion: {
            })
        }
    }

    func addNewRegion(_ region: RegionObject) {
        self.regionObjects.append(region)
        self.add(region)
        self.viewModel.saveRegionData(self.regionObjects)
        self.setVisibleRegion(region)
    }

    // MARK: Functions that update the model/associated views with geotification changes
    func add(_ region: RegionObject) {
        if let annotation = region.annotableRegion() {
            mapView.addAnnotation(annotation)
        }
        addRadiusOverlay(forRegion: region)
    }

    func setVisibleRegion(_ region: RegionObject) {
        // center the mapView on the selected pin
        let region = MKCoordinateRegion(center: region.getCoordinates()!, latitudinalMeters: 5000, longitudinalMeters: 5000)
        mapView.setRegion(region, animated: true)
    }

    func remove(_ annotation: RegionAnnotation) {
        mapView.removeAnnotation(annotation)
        if let region = self.regionObjects.first(where: { $0.id == annotation.regionId }) {
            removeRadiusOverlay(forRegion: region)
            regionObjects.removeAll(where: { $0 == region })
        }
        self.viewModel.saveRegionData(self.regionObjects)
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

extension GeoFenceViewController: GeoFenceControllerDelegate {
    func addRegion(_ region: RegionObject) {
        addNewRegion(region)
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
            circleRenderer.alpha = 0.3
            circleRenderer.lineWidth = 2.0
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

