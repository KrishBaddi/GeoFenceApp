//
//  RegionsViewController.swift
//  iOS-Geofence-Demo
//
//  Created by Kaodim MacMini on 31/12/2020.
//

import UIKit
import CoreLocation
import MapKit

protocol RegionsControllerFactory {
    func makeViewController() -> RegionsViewController?
    func makeRegionsViewModel() -> RegionsViewModel
    func makeRegionsDataSource() -> RegionDataSource
    func makeFenceDelegate() -> GeoFenceControllerDelegate
}

open class RegionsDependencyContainer: RegionsControllerFactory {

    private var delegate: GeoFenceControllerDelegate

    internal init(delegate: GeoFenceControllerDelegate) {
        self.delegate = delegate
    }

    func makeViewController() -> RegionsViewController? {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "RegionsViewController", creator: { RegionsViewController(coder: $0, factory: self) })
        viewController.delegate = makeFenceDelegate()
        return viewController
    }

    func makeRegionsViewModel() -> RegionsViewModel {
        RegionsViewModel()
    }

    func makeRegionsDataSource() -> RegionDataSource {
        RegionDataSource()
    }

    func makeFenceDelegate() -> GeoFenceControllerDelegate {
        delegate
    }
}

class RegionsViewController: UITableViewController {

    // MARK: - Dependency Injection

    typealias Factory = RegionsControllerFactory
    private let factory: Factory

    lazy var viewModel = factory.makeRegionsViewModel()
    
    weak var delegate: GeoFenceControllerDelegate?
    private var contentView = UIView()
    var addButton: UIBarButtonItem!

    @IBOutlet weak var radius: UITextField!
    @IBOutlet weak var regionName: UITextField!
    @IBOutlet weak var networkName: UITextField!
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
        viewModel.delegate = self

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.mapView.zoomToUserLocation()
        }
        // Do any additional setup after loading the view.
    }

    // Setup navigation buttons items
    func setupNavigationButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(systemName: "xmark"), style: .plain, target: self, action: #selector(self.closeTapped))

        addButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(onAddRegion))
        addButton.isEnabled = false
        
        let location = UIBarButtonItem(image: UIImage.init(systemName: "location"), style: .plain, target: self, action: #selector(self.locationTapped))

        navigationItem.rightBarButtonItems = [addButton, location]
    }

    // Validate textfield on text change
    @IBAction func textFieldEditingChanged(sender: UITextField) {
        viewModel.validator(self.regionName.text, self.radius.text, self.networkName.text)
    }

    @objc func locationTapped() {
        mapView.zoomToUserLocation()
    }

    @objc func closeTapped() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc private func onAddRegion(sender: AnyObject) {
        let regionName = self.regionName.text ?? ""
        let networkName = self.networkName.text ?? ""
        guard let radiusText = self.radius.text, let radius = Float(radiusText) else { return }
        viewModel.getNewRegion(regionName, radius, mapView.centerCoordinate, networkName)
    }

    func newRegionAdded(_ region: RegionObject) {
        self.dismiss(animated: true) { [weak self] in
            self?.delegate?.addRegion(region)
        }
    }
}

extension RegionsViewController: RegionsViewModelDelegate {
    func isFieldsValidated(_ status: Bool) {
        addButton.isEnabled = status
    }

    func getNewRegion(_ region: RegionObject) {
        newRegionAdded(region)
    }
}
