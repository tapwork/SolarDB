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
    var outlets = [PowerOutlet]() {
        didSet {
            delegate?.homeKitHandlerDidUpdate(self, outlets: outlets)
        }
    }

    func start() {
        home = nil
        outlets.removeAll()
        homeManager.delegate = self
    }
}

extension HomeKitHandler: HMHomeManagerDelegate {
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        home = manager.homes.filter {$0.name == "e GO Headquarters"}.first
        if let acc = home?.accessories.first {
            let outlet = PowerOutlet(outlet: acc)
            outlets.append(outlet)
        }
    }
}
