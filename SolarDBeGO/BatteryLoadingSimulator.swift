//
//  BatteryLoadingSimulator.swift
//  SolarDBeGO
//
//  Created by Christian Menschel on 23.05.19.
//  Copyright © 2019 SolarDB. All rights reserved.
//

import Foundation

class BatteryLoadingSimulator {
    private var chargeLevel: Double = 0.0
    private var timer: Timer?
    var updateHandler: ((Double) -> Void)?

    var isLoading: Bool {
        if let timer = timer, timer.isValid {
            return true
        }
        return false
    }

    func pause() {
        timer?.invalidate()
    }

    func start() {
        if isLoading {
            return
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {[weak self] timer in
            guard let self = self else { return }
            if self.chargeLevel > 100 {
                timer.invalidate()
                return
            }
            self.updateHandler?(self.chargeLevel)
            self.chargeLevel = self.chargeLevel + 5.0
        })
        timer?.fire()
    }

    func stop() {
        timer?.invalidate()
        chargeLevel = 0.0
    }
}
