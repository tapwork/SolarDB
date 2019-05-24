//
//  ChargeSettingsHandler.swift
//  SolarDBeGO
//
//  Created by Christian Menschel on 24.05.19.
//  Copyright © 2019 SolarDB. All rights reserved.
//

import Foundation

class ChargeSettingsHandler: PowerHandler {

    static let EGOMaxLoadingPower: Double = 11.0
    static let shared = ChargeSettingsHandler(maxWatt: EGOMaxLoadingPower)
}
