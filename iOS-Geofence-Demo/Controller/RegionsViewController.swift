//
//  RegionsViewController.swift
//  iOS-Geofence-Demo
//
//  Created by Kaodim MacMini on 31/12/2020.
//

import UIKit
import CoreLocation
import MapKit

class RegionsViewModel {
    internal init(_ dataSource: RegionDataSource) {
        self.dataSource = dataSource
    }

    private var dataSource: RegionDataSource
}

protocol RegionsControllerFactory {
    func makeViewController() -> RegionsViewController?
    func makeRegionsViewModel() -> RegionsViewModel
    func makeRegionsDataSource() -> RegionDataSource
    func makeDelegate() -> GeoFenceControllerDelegate
}

open class RegionsDependencyContainer: RegionsControllerFactory {

    private var delegate: GeoFenceControllerDelegate

    internal init(delegate: GeoFenceControllerDelegate) {
        self.delegate = delegate
    }

    func makeViewController() -> RegionsViewController? {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "RegionsViewController", creator: { RegionsViewController(coder: $0, factory: self) })
        viewController.delegate = makeDelegate()
        return viewController
    }

    func makeRegionsViewModel() -> RegionsViewModel {
        RegionsViewModel(makeRegionsDataSource())
    }

    func makeRegionsDataSource() -> RegionDataSource {
        RegionDataSource()
    }

    func makeDelegate() -> GeoFenceControllerDelegate {
        delegate
    }
}

class RegionsViewController: UITableViewController {

    // MARK: - Dependency Injection

    // Here we use protocol composition to create a Factory type that includes
    // all the factory protocols that this view controller needs.
    typealias Factory = RegionsControllerFactory
    private let factory: Factory
    lazy var viewModel = factory.makeRegionsViewModel()
    weak var delegate: GeoFenceControllerDelegate?
    private var contentView = UIView()

    @IBOutlet weak var radius: UITextField!
    @IBOutlet weak var regionName: UITextField!
    @IBOutlet weak var mapView: MKMapView!


    init?(coder: NSCoder, factory: Factory) {
        self.factory = factory
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("Deallocated...")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationButtons()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            LocationService.sharedInstance.startUpdatingLocation()
            self.mapView.zoomToUserLocation()
        }
        // Do any additional setup after loading the view.
    }

    func setupNavigationButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(systemName: "xmark"), style: .plain, target: self, action: #selector(self.closeTapped))

        let add = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(onAddRegion))
        let location = UIBarButtonItem(image: UIImage.init(systemName: "location"), style: .plain, target: self, action: #selector(self.locationTapped))

        navigationItem.rightBarButtonItems = [add, location]
    }

    @IBAction func textFieldEditingChanged(sender: UITextField) {
        //addRegionBtn.isEnabled = !radius.text!.isEmpty && !regionName.text!.isEmpty
    }

    @objc func locationTapped() {
        mapView.zoomToUserLocation()
    }

    @objc func closeTapped() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc private func onAddRegion(sender: AnyObject) {

        let coordinatesId = String().randomString(length: 5)
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude

        let coordinate = Coordinates(id: coordinatesId, latitude: latitude, longitude: longitude)

        let identifier = String().randomString(length: 5)
        let regionName = self.regionName.text ?? ""
        guard let radiusText = self.radius.text, let radius = Float(radiusText) else { return }

        let hotspotId = String().randomString(length: 10)

        let regionObject = RegionObject(id: identifier, title: regionName, radius: radius, coordinates: coordinate, network: HotSpot(id: hotspotId, name: "Network", radius: 100))

        self.dismiss(animated: true) { [weak self] in
            self?.delegate?.addRegion(regionObject)
        }
    }

}
