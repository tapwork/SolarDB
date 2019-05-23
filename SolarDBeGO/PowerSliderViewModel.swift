//
//  PowerSliderViewModel.swift
//  SolarDBeGO
//
//  Created by Christian Menschel on 23.05.19.
//  Copyright © 2019 SolarDB. All rights reserved.
//

import UIKit

struct PowerSliderViewModel {
    let maxWatt: Double
    var watt: Double = 0.0
    let title: String
    let backgroundColor: UIColor
    let fontColor: UIColor
}

extension PowerSliderViewModel {
    static var sun: PowerSliderViewModel {
        return PowerSliderViewModel(maxWatt: 10,
                                    watt: 0,
                                    title: "Simulation of power produced by the sun",
                                    backgroundColor: .yellow,
                                    fontColor: .black)
    }

    static var outlet: PowerSliderViewModel {
        return PowerSliderViewModel(maxWatt: 3.5,
                                    watt: 0,
                                    title: "Minimum power (kW) to start charging the car",
                                    backgroundColor: .blue,
                                    fontColor: .white)
    }
}

