//
//  BatteryLoadingSimulator.swift
//  SolarDBeGO
//
//  Created by Christian Menschel on 23.05.19.
//  Copyright © 2019 SolarDB. All rights reserved.
//

import Foundation

struct Battery {
    let isCharging: Bool
    let chargeLevel: Double
    let capacity: Double
    let loadingPower: Double

    func copy(chargeLevel: Double, isCharging: Bool) -> Battery {
        return Battery(isCharging: isCharging,
                       chargeLevel: chargeLevel,
                       capacity: self.capacity,
                       loadingPower: self.loadingPower)
    }
}

class BatterySimulator {
    static let shared = BatterySimulator()
    private (set) var battery: Battery?
    private var timer: Timer?
    lazy var homeKitHandler = HomeKitHandler()
    var updateHandler: ((Battery) -> Void)?
    var canStartCharging: ((Battery) -> Void)?
    let api = API()
    var isCharging: Bool {
        if let timer = timer, timer.isValid {
            return true
        }
        return false
    }

    var canLoad: Bool {
        return battery != nil
    }

    // MARK: Init
    init() {
        API.shared.updateSignals {[weak self] signals in
            guard let self = self else { return }
            DispatchQueue.main.async {
                let level = signals.batteryStateOfCharge
                let battery = Battery(isCharging: false,
                                      chargeLevel: Double(level),
                                      capacity: signals.batteryTotalKwhCapacity,
                                      loadingPower: signals.batteryLoadingCapacity)
                self.battery = battery
                self.canStartCharging?(battery)
            }
        }
    }

    private func startHomeKit() {
        homeKitHandler.delegate = self
        homeKitHandler.start()
    }

    func pause() {
        timer?.invalidate()
    }

    func reset() {
        timer?.invalidate()
        guard let battery = battery else { return }
        self.battery = battery.copy(chargeLevel: 0, isCharging: false)
        self.updateHandler?(battery)
    }

    func juice() {
        guard canLoad, !isCharging else {
            return
        }
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: {[weak self] timer in
            guard let self = self else { return }
            guard let battery = self.battery else { return }
            self.updateHandler?(battery)

            let newLevel = battery.chargeLevel + 5.0
            if newLevel >= 100 {
                self.handleFullyJuiced()
                return
            }
            self.battery = battery.copy(chargeLevel: newLevel, isCharging: true)
        })
        timer?.fire()
    }

    private func handleFullyJuiced() {
        timer?.invalidate()
        guard let battery = battery?.copy(chargeLevel: 100, isCharging: false) else {
            return
        }
        self.battery = battery
        self.updateHandler?(battery)
    }

    func toggleChargingIfNeeded() {
        var state = homeKitHandler.outlet?.state
        guard let battery = battery,
            SolarSimulator.shared.watt > 0, ChargeSettingsHandler.shared.watt > 0 else {
            state = .off
            return
        }
        if SolarSimulator.shared.watt >= battery.loadingPower &&
            SolarSimulator.shared.watt >= ChargeSettingsHandler.shared.watt {
            state = .on
        } else {
            state = .off
        }
        homeKitHandler.outlet?.state = state
        state == .on ? juice() : pause()
    }
}

extension BatterySimulator: HomeKitHandlerDelegate {
    func homeKitHandlerDidUpdate(_ homeKitHandler: HomeKitHandler, outlet: PowerOutlet) {
        toggleChargingIfNeeded()
    }
}
