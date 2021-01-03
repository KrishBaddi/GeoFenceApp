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
    func wifiConnected(_ hotspot: HotSpot)
    func disconnectWifi()
}

protocol GeoFenceControllerFactory {
    func makeViewController() -> GeoFenceViewController
    func makeGeoFenceViewModel() -> GeoFenceViewModel
    func makeGeoFenceDataSource() -> RegionDataSource
    func makeLocationService() -> LocationService
}

open class GeoFenceDependencyContainer: GeoFenceControllerFactory {
    func makeViewController() -> GeoFenceViewController {
        GeoFenceViewController(factory: self)
    }

    func makeGeoFenceViewModel() -> GeoFenceViewModel {
        GeoFenceViewModel(makeGeoFenceDataSource(), makeFenceDetectorService())
    }

    func makeGeoFenceDataSource() -> RegionDataSource {
        RegionDataSource()
    }

    func makeFenceDetectorService() -> GeoFenceDetectorService {
        GeoFenceDetectorService()
    }

    func makeLocationService() -> LocationService {
        LocationService()
    }
}


class GeoFenceViewController: UIViewController {

    // MARK: - Dependency Injection

    // Here we use protocol composition to create a Factory type that includes
    // all the factory protocols that this view controller needs.
    typealias Factory = GeoFenceControllerFactory

    lazy var viewModel = factory.makeGeoFenceViewModel()
    lazy var locationService = factory.makeLocationService()
    private let factory: Factory
    private var contentView = UIView()

    private var wifiButton: UIBarButtonItem!
    private var statusButton: ToolBarTitleItem!

    // MARK: Lazy load UI properties
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

    lazy var regionStatusView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.red.withAlphaComponent(0.7)
        return view
    }()

    lazy var regionStatusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = "Geo fence detection..."
        return label
    }()

    lazy var toolBar: UIToolbar = {
        let view = UIToolbar()
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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setUpContentView()
        setupNavigationButtons()

        mapView.delegate = self
        locationService.delegate = self
        viewModel.delegate = self
        viewModel.setDetectorDelegate(delegate: self)
        viewModel.loadRegions()
    }

    // MARK: Setup layout for content view and other subviews
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
        setUpToolBarView()
        addToolBarButton()
        addRegionStatusView()
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

    func setUpToolBarView() {
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(toolBar)

        let constraints: [NSLayoutConstraint] = [
            toolBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            toolBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            toolBar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    func addRegionStatusView() {
        contentView.addSubview(regionStatusView)
        let constraints: [NSLayoutConstraint] = [
            regionStatusView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            regionStatusView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            regionStatusView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            regionStatusView.heightAnchor.constraint(equalToConstant: 50)
        ]
        NSLayoutConstraint.activate(constraints)
        regionStatusView.layer.cornerRadius = 25

        regionStatusView.addSubview(regionStatusLabel)
        let labelConstraint: [NSLayoutConstraint] = [
            regionStatusLabel.centerYAnchor.constraint(equalTo: regionStatusView.centerYAnchor),
            regionStatusLabel.centerXAnchor.constraint(equalTo: regionStatusView.centerXAnchor),
        ]
        NSLayoutConstraint.activate(labelConstraint)

        regionStatusView.isHidden = false
    }

    // Setup navigation items
    func setupNavigationButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(systemName: "location"), style: .plain, target: self, action: #selector(self.locationTapped))

        navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(systemName: "plus"), style: .plain, target: self, action: #selector(self.addRegionTapped))
    }

    // Function to update title with connect wifi network
    func updateNavigationTitle(isConnected: Bool, name: String? = nil) {
        let titleText = "Wifi: \(String(describing: name ?? ""))"
        self.title = isConnected ? titleText : ""
    }

    // Setup toolbar items
    func addToolBarButton() {
        wifiButton = UIBarButtonItem(image: UIImage(systemName: "wifi"), style: .plain, target: self, action: #selector(connectWifiTapped))
        toolBar.items = [wifiButton]

        statusButton = ToolBarTitleItem(text: "", font: .systemFont(ofSize: 15), color: UIColor.darkGray)

        toolBar.items = []
        toolBar.items?.append(wifiButton)
        toolBar.items?.append(statusButton)
    }

    func updateWifiButton(_ isEnabled: Bool) {
        self.wifiButton.isEnabled = isEnabled
    }

    // MARK: BarButton functions

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

    @objc func connectWifiTapped() {
        viewModel.loadNetworkList()
    }

    func navigateToWifiListVC(_ hotspots: [HotSpot]) {
        let container = WifiListDependencyContainer(delegate: self, hotspots: hotspots)
        if let viewController = container.makeViewController() {
            viewController.modalPresentationStyle = .overFullScreen
            self.present(viewController, animated: true, completion: {
            })
        }
    }

    // MARK: Load all regions from defaults and draw on maps
    func reloadRegions(_ regions: [RegionObject]) {
        regions.forEach { self.add($0) }

        if let firstRegion = regions.first {
            self.setVisibleRegion(firstRegion)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.mapView.zoomToUserLocation()
            }
        }
        self.addToolBarButton()
        self.updateWifiButton(regions.count > 0)
    }

    // Function to add new region
    func addNewRegion(_ region: RegionObject) {
        self.add(region)
        self.viewModel.saveRegionData(region)
        self.setVisibleRegion(region)
        self.wifiButton.isEnabled = true
    }

    // Functions that draw radius overlay and add annotation
    func add(_ region: RegionObject) {
        if let annotation = region.annotableRegion() {
            mapView.addAnnotation(annotation)
        }
        addRadiusOverlay(forRegion: region)
        self.startMonitoring(region)
    }

    // Functions to delete region and annotation
    func remove(_ annotation: RegionAnnotation) {
        mapView.removeAnnotation(annotation)
        viewModel.deleteRegion(annotation)
    }

    // Center the mapView on the selected pin
    func setVisibleRegion(_ region: RegionObject) {
        let region = MKCoordinateRegion(center: region.getCoordinates()!, latitudinalMeters: 5000, longitudinalMeters: 5000)
        mapView.setRegion(region, animated: true)
    }


    // Function to add radius overlay on map
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

    // Find exactly one overlay which has the same coordinates & radius to remove
    func removeRadiusOverlay(forRegion region: RegionObject) {
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

    // Function to monitor location
    func startMonitoring(_ region: RegionObject) {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            showAlert(withTitle: "Error", message: "Geofencing is not supported on this device!")
            return
        }

        if !locationService.locationManager.hasLocationPermission() {
            let message = """
        Your geo fence location is saved but will only be activated once you grant
        permission to access the device location.
        """
            showAlert(withTitle: "Warning", message: message)
        }

        if let fenceRegion = circularRegion(with: region) {
            locationService.startMonitoringFor(region: fenceRegion)
        }
    }

    // Function to stop monitoring region object
    func stopMonitoring(_ region: RegionObject) {
        let regions = locationService.locationManager.monitoredRegions
        regions.forEach({ (fenceRegion) in
            if fenceRegion.identifier == region.id {
                locationService.stopMonitoringFor(region: fenceRegion)
            }
        })
    }

    // Function to create circular region to monitor the exit and entry
    func circularRegion(with region: RegionObject) -> CLCircularRegion? {
        guard let coordinates = region.getCoordinates() else { return nil }
        let region = CLCircularRegion(center: coordinates, radius: CLLocationDistance(region.radius), identifier: region.id)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        return region
    }

    // Function to show/hide notification based on entry/exit
    func isShowRegionNotification(status: Bool, _ regionName: String?) {
        let text = status ? "Entered into '\(regionName ?? "")' region" : "Exited from the region '\(regionName ?? "")'"
        regionStatusLabel.text = text
        regionStatusLabel.font = UIFont.systemFont(ofSize: 14)
    }
}


// MARK: GeoFenceViewModel Delegate
extension GeoFenceViewController: GeoFenceViewModelDelegate {
    func stopMonitoringRegion(_ region: RegionObject) {
        removeRadiusOverlay(forRegion: region)
        stopMonitoring(region)
    }

    func showError(_ error: String) {
        showAlert(withTitle: "Error", message: error)
    }

    func networkListLoaded(_ hotspots: [HotSpot]) {
        navigateToWifiListVC(hotspots)
    }

    func reloadData(_ regions: [RegionObject]) {
        self.reloadRegions(regions)
    }

    func savedResult(_ status: Bool) {
        print(status)
    }
}

// MARK: GeoFenceViewController Delegate
extension GeoFenceViewController: GeoFenceControllerDelegate {
    func disconnectWifi() {
        viewModel.disconnectWifi()
    }

    func wifiConnected(_ hotspot: HotSpot) {
        viewModel.connectWifi(hotspot)
    }

    func addRegion(_ region: RegionObject) {
        addNewRegion(region)
    }
}

// MARK: Location Service Delegate
extension GeoFenceViewController: LocationServiceDelegate {
    func didEnterIntoRegion(region: CLRegion) {
        viewModel.didEnterRegion(region.identifier)
    }

    func didExitIntoRegion(region: CLRegion) {
        viewModel.didExitRegion(region.identifier)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapView.showsUserLocation = status == .authorizedAlways
    }
}

// MARK: GeoFence Detector Delegate
extension GeoFenceViewController: GeoFenceDetectorServiceDelegate {
    func connectedToWifi(_ networkName: String) {
        updateNavigationTitle(isConnected: true, name: networkName)
    }

    func wifiDisconnected() {
        updateNavigationTitle(isConnected: false)
    }

    func didEnteredRegion(_ name: String) {
        isShowRegionNotification(status: true, name)
    }

    func didExitRegion(_ name: String) {
        isShowRegionNotification(status: false, name)
    }
}

// MARK: MKMapView  Delegate
extension GeoFenceViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView,
        rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        // Customize circle fencing
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
        // Customize annotation
        if annotation is RegionAnnotation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                let removeButton = UIButton(type: .custom)
                removeButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
                removeButton.setImage(UIImage.init(systemName: "xmark.circle"), for: .normal)
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
    }
}

