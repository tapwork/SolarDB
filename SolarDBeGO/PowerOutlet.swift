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

        mutating func toggle() {
            self = self == .on ? .off : .on
        }
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
            let value = state == .on ? 1 : 0
            power.writeValue(value) {[weak self] in
                if let error = $0 {
                    self?.state?.toggle()
                    print(error)
                    return
                }
                print("Successfully switched HomeKit device to: \(value)")
            }
        }
    }
}
