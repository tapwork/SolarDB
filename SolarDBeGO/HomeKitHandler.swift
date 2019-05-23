//
//  HomeKitHandler.swift
//  SolarDBeGO
//
//  Created by Christian Menschel on 23.05.19.
//  Copyright © 2019 SolarDB. All rights reserved.
//

import Foundation
import HomeKit

protocol HomeKitHandlerDelegate: class {
    func homeKitHandlerDidUpdate(_ homeKitHandler: HomeKitHandler, outlets: [PowerOutlet])
}

class HomeKitHandler: NSObject {
    weak var delegate: HomeKitHandlerDelegate?
    private lazy var homeManager = HMHomeManager()
    private lazy var accessoryBrowser = HMAccessoryBrowser()
    var home: HMHome?
    var outlets = [PowerOutlet]()
    func start() {
        home = nil
        homeManager.delegate = self
    }

    func startBrowsingAccessory() {
        outlets.removeAll()
        accessoryBrowser.delegate = self
        accessoryBrowser.startSearchingForNewAccessories()
    }
}

extension HomeKitHandler: HMHomeManagerDelegate {
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        home = manager.homes.filter {$0.name == "e GO Headquarters"}.first
        if home != nil {
            startBrowsingAccessory()
        }
    }
}

extension HomeKitHandler: HMAccessoryBrowserDelegate {
    func accessoryBrowser(_ browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory) {
        if accessory.category.categoryType == HMServiceTypeOutlet {
            outlets.append(PowerOutlet(outlet: accessory))
        }
        delegate?.homeKitHandlerDidUpdate(self, outlets: outlets)
    }
}
