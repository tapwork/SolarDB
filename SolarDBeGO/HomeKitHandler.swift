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
    func homeKitHandlerDidUpdate(_ homeKitHandler: HomeKitHandler, homes: [HMHome])
    func homeKitHandlerDidUpdate(_ homeKitHandler: HomeKitHandler, accessories: [HMAccessory])
}

class HomeKitHandler: NSObject {
    weak var delegate: HomeKitHandlerDelegate?
    private lazy var homeManager: HMHomeManager = {
        let home = HMHomeManager()
        home.delegate = self
        return home
    }()
    private lazy var accessoryBrowser: HMAccessoryBrowser = {
        let browser = HMAccessoryBrowser()
        browser.delegate = self
        return browser
    }()
    var home: HMHome? {
        return homeManager.homes.first
    }
    var accessories = [HMAccessory]()
    var outlets: [HMAccessory]? {
        return accessories.filter {$0.category.categoryType == "Outlet"}
    }

    func start() {
        accessoryBrowser.startSearchingForNewAccessories()
    }
}

extension HomeKitHandler: HMHomeManagerDelegate {
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        delegate?.homeKitHandlerDidUpdate(self, homes: manager.homes)
    }
}

extension HomeKitHandler: HMAccessoryBrowserDelegate {
    func accessoryBrowser(_ browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory) {
        accessories.append(accessory)
        delegate?.homeKitHandlerDidUpdate(self, accessories: accessories)
    }
}
