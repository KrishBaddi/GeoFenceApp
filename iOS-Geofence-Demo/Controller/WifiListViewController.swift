//
//  WifiListViewController.swift
//  iOS-Geofence-Demo
//
//  Created by Kaodim MacMini on 01/01/2021.
//

import Foundation
import UIKit

protocol WifiListControllerFactory {
    func makeViewController() -> WifiListViewController?
    func makeWifiListViewModel() -> WifiListViewModel
    func makeWifiListDataSource() -> RegionDataSource
    func makeFenceDelegate() -> GeoFenceControllerDelegate
}

open class WifiListDependencyContainer: WifiListControllerFactory {

    private var delegate: GeoFenceControllerDelegate

    internal init(delegate: GeoFenceControllerDelegate) {
        self.delegate = delegate
    }

    func makeViewController() -> WifiListViewController? {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "WifiListViewController", creator: { WifiListViewController(coder: $0, factory: self) })
        viewController.delegate = makeFenceDelegate()
        return viewController
    }

    func makeWifiListViewModel() -> WifiListViewModel {
        WifiListViewModel(makeWifiListDataSource())
    }

    func makeWifiListDataSource() -> RegionDataSource {
        RegionDataSource()
    }

    func makeFenceDelegate() -> GeoFenceControllerDelegate {
        delegate
    }
}

class WifiListViewController: UIViewController {

    // MARK: - Dependency Injection

    // Here we use protocol composition to create a Factory type that includes
    // all the factory protocols that this view controller needs.
    typealias Factory = WifiListControllerFactory
    private let factory: Factory

    lazy var viewModel = factory.makeWifiListViewModel()

    weak var delegate: GeoFenceControllerDelegate?
    private var wifiList: [HotSpot] = []
    private var contentView = UIView()
    var addButton: UIBarButtonItem!


    @IBOutlet weak var tableView: UITableView!

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

        tableView?.tableFooterView = UIView()
        viewModel.delegate = self
        loadData()
    }

    func loadData() {
        viewModel.getAllHotSpots()
    }

    @IBAction func disconnectTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.delegate?.disconnectWifi()
        })
    }

    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    func didSelectWifi(_ hotspots: HotSpot) {
        self.dismiss(animated: true) {
            self.delegate?.wifiConnected(hotspots)
        }
    }
}


extension WifiListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wifiList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WifiTableCell", for: indexPath) as! WifiTableCell
        let wifi = self.wifiList[indexPath.row]
        cell.configureCell(wifi.name)
        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectWifi(self.wifiList[indexPath.row])
    }
}



extension WifiListViewController: WifiListViewModelDelegate {
    func getAllHotSpots(_ hotspots: [HotSpot]) {
        self.wifiList = hotspots
        self.tableView.reloadData()
    }
}



