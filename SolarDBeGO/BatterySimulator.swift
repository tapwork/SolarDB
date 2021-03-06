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

    static var empty: Battery {
        return Battery(isCharging: false,
                       chargeLevel: 0.0,
                       capacity: 0.0,
                       loadingPower: 0.0)
    }
}

class BatterySimulator {
    static let shared = BatterySimulator()
    private (set) var battery: Battery = .empty {
        didSet {
            API.shared.updateStateOfCharge(battery.chargeLevel, charging: battery.isCharging)
            self.updateHandler?(battery)
        }
    }
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

    var shouldLoad: Bool {
        return battery.capacity > 0 &&
            battery.chargeLevel < 100 &&
            ChargeSettingsHandler.shared.watt > 0 &&
            SolarSimulator.shared.watt > battery.loadingPower &&
            SolarSimulator.shared.watt > ChargeSettingsHandler.shared.watt
    }

    // MARK: Init
    init() {
        startHomeKit()
        API.shared.updateSignals { signals in
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

    // MARK: Public
    func toggleChargingIfNeeded() {
        shouldLoad ? juice() : pause()
        updateChargeOutlet()
    }

    func reset() {
        timer?.invalidate()
        self.battery = battery.copy(chargeLevel: 0, isCharging: false)
        toggleChargingIfNeeded()
    }

    // MARK: Private

    private func startHomeKit() {
        homeKitHandler.delegate = self
        homeKitHandler.start()
    }

    private func pause() {
        timer?.invalidate()
        self.battery = battery.copy(chargeLevel: battery.chargeLevel, isCharging: false)
        updateChargeOutlet()
    }

    private func juice() {
        guard shouldLoad, !isCharging else {
            return
        }
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: {[weak self] timer in
            guard let self = self else { return }
            let newLevel = self.battery.chargeLevel + 5.0
            if newLevel >= 100 {
                self.handleFullyJuiced()
                return
            }
            self.battery = self.battery.copy(chargeLevel: newLevel, isCharging: true)
        })
        timer?.fire()
    }

    private func handleFullyJuiced() {
        timer?.invalidate()
        updateChargeOutlet()
        self.battery = battery.copy(chargeLevel: 100, isCharging: false)
    }

    private func updateChargeOutlet() {
        homeKitHandler.outlet?.state = isCharging ? .on : .off
    }
}

extension BatterySimulator: HomeKitHandlerDelegate {
    func homeKitHandlerDidUpdate(_ homeKitHandler: HomeKitHandler, outlet: PowerOutlet) {
        toggleChargingIfNeeded()
    }
}
