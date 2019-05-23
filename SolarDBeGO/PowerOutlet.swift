//
//  PowerOutlet.swift
//  SolarDBeGO
//
//  Created by Christian Menschel on 23.05.19.
//  Copyright © 2019 SolarDB. All rights reserved.
//

import Foundation
import HomeKit

class PowerOutlet {

    enum State {
        case on
        case off
    }

    private let outlet: HMAccessory
    var state: State? {
        didSet {
            if oldValue != state {
                toggle()
            }
        }
    }

    // MARK: Init
    init(outlet: HMAccessory) {
        self.outlet = outlet
    }

    private func toggle() {
        if let service = outlet.services.filter({
            return $0.serviceType == HMServiceTypeOutlet
        }).first, let power = service.characteristics.filter({
            return $0.characteristicType == HMCharacteristicTypePowerState
        }).first {
            power.writeValue(state == .on ? 1 : 0) {
                print($0 ?? "Success")
            }
        }
    }
}
