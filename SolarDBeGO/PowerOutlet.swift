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
    var state: State = .off

    // MARK: Init
    init(outlet: HMAccessory) {
        self.outlet = outlet
//        let characteristic = outlet.find(serviceType: HMServiceTypeOutlet, characteristicType: HMCharacteristicMetadataFormatBool)
//        let characteristics = outlet.services.flatMap {$0.characteristics.compactMap{$0.characteristicType }}
//        let metaData = characteristics.compactMap {$0.metadata}
//        if let toggleMeta = metaData.filter ({$0.format == HMCharacteristicMetadataFormatBool}).first {
//            self.state = ch
//        }
    }
}
