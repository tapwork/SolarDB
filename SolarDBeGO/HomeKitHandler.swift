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
    func homeKitHandler(_ homeKitHandler: HomeKitHandler, didUpdate: [HMHome])
}

class HomeKitHandler: NSObject {
    weak var delegate: HomeKitHandlerDelegate?
    private lazy var homeManager: HMHomeManager = {
        let home = HMHomeManager()
        home.delegate = self
        return home
    }()

    var home: HMHome? {
        return homeManager.homes.first
    }

    var outlets: [HMAccessory]? {
        return home?.accessories
    }
}

extension HomeKitHandler: HMHomeManagerDelegate {
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        delegate?.homeKitHandler(self, didUpdate: manager.homes)
    }
}
