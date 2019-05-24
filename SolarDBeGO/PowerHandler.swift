//
//  PowerHandler.swift
//  SolarDBeGO
//
//  Created by Christian Menschel on 24.05.19.
//  Copyright © 2019 SolarDB. All rights reserved.
//

import Foundation

class PowerHandler {
    let maxWatt: Double
    var watt: Double = 0.0 {
        didSet {
            if oldValue != watt {
                didUpdate()
            }
        }
    }
    typealias ObserverType = () -> Void
    private var observers = [ObserverType]()

    init(maxWatt: Double) {
        self.maxWatt = maxWatt
        self.watt = storedWatt
    }

    private func didUpdate() {
        observers.forEach {$0()}
        store()
    }

    func observe(observer: @escaping ObserverType) {
        observers.append(observer)
    }
}

extension PowerHandler {

    var wattKey: String {
        let name = String(describing: type(of: self))
        return "\(name).watt)"
    }

    var storedWatt: Double {
        return UserDefaults.standard.double(forKey: wattKey)
    }

    func store() {
        UserDefaults.standard.set(watt, forKey: wattKey)
    }
}
