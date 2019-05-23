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
    var outlets = [PowerOutlet]()
    func start() {
        outlets.removeAll()
        accessoryBrowser.startSearchingForNewAccessories()
    }
}

extension HomeKitHandler: HMHomeManagerDelegate {
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
       //
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
