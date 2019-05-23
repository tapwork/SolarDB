//
//  PowerSliderViewModel.swift
//  SolarDBeGO
//
//  Created by Christian Menschel on 23.05.19.
//  Copyright © 2019 SolarDB. All rights reserved.
//

import UIKit

struct PowerSliderViewModel {
    enum PowerType: String {
        case sun, outlet
    }
    let maxWatt: Double
    var watt: Double = 0.0 {
        didSet {
            store(watt: watt, type: type)
        }
    }
    let title: String
    let backgroundColor: UIColor
    let fontColor: UIColor
    private let type: PowerType

    init(type: PowerType) {
        self.type = type
        switch type {
        case .sun:
            self.backgroundColor = .yellow
            self.maxWatt = 10.0
            self.fontColor = .blue
            self.title = "Sun: Simulation of power produced by solar"
        case .outlet:
            self.backgroundColor = .blue
            self.maxWatt = 3.5
            self.fontColor = .white
            self.title = "Minimum solar power (kW) to enable charging the car"
        }
        self.watt = storedWatt(for: type)
    }
}

extension PowerSliderViewModel {

    var key: String {
        return "\(String(describing: PowerSliderViewModel.self)).Watt.\(type.rawValue)"
    }

    func storedWatt(for type: PowerType) -> Double {
        return UserDefaults.standard.double(forKey: key)
    }

    func store(watt: Double, type: PowerType) {
        UserDefaults.standard.set(watt, forKey: key)
    }
}

