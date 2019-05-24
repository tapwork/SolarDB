//
//  ViewController.swift
//  SolarDBeGO
//
//  Created by Christian Menschel on 23.05.19.
//  Copyright © 2019 SolarDB. All rights reserved.
//

import UIKit
import HomeKit

class HomeViewController: UIViewController {

    // MARK: Properties
    lazy var sunViewController = SolarPowerSliderViewController()
    lazy var chargeSettingsViewController = ChargeSettingsViewController()
    lazy var loadingViewController = LoadingViewController()
    lazy var batteryViewController = BatteryViewController()
    lazy var homeKitHandler = HomeKitHandler()
    lazy var batterySimulator = BatterySimulator()

    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        addSunViewController()
        addBatteryViewController()
        addBatterySettingsViewController()
        addBatteryLoadingSimulator()
        addLoadingViewController()
        addObserver()
        startHomeKit()
    }

    // MARK: Setup
    private func addSunViewController() {
        addChild(sunViewController)
        view.addSubview(sunViewController.view)
        sunViewController.didMove(toParent: self)
        sunViewController.view.pinToEdges([.left, .top, .right], of: view.safeAreaLayoutGuide)
        sunViewController.view.setConstant(height: view.bounds.height/3)
    }

    private func addBatteryViewController() {
        addChild(batteryViewController)
        view.addSubview(batteryViewController.view)
        batteryViewController.didMove(toParent: self)
        batteryViewController.view.pinTop(to: sunViewController.view.bottomAnchor)
        batteryViewController.view.pinToEdges([.left, .right], of: view.safeAreaLayoutGuide)
        batteryViewController.view.setConstant(height: view.bounds.height/3)
    }

    private func addBatterySettingsViewController() {
        addChild(chargeSettingsViewController)
        view.addSubview(chargeSettingsViewController.view)
        chargeSettingsViewController.didMove(toParent: self)
        chargeSettingsViewController.view.pinTop(to: batteryViewController.view.bottomAnchor)
        chargeSettingsViewController.view.pinToEdges([.left, .right], of: view.safeAreaLayoutGuide)
        chargeSettingsViewController.view.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor)
    }

    private func addBatteryLoadingSimulator() {
        batterySimulator.canStartCharging = {[weak self] battery in
            guard let self = self else { return }
            self.loadingViewController.stop()
            self.batteryViewController.update(viewModel: BatteryViewModel(battery))
        }
        batterySimulator.updateHandler = {[weak self] battery in
            guard let self = self else { return }
            self.batteryViewController.update(viewModel: BatteryViewModel(battery))
        }
    }

    private func addLoadingViewController() {
        addChild(loadingViewController)
        view.addSubview(loadingViewController.view)
        loadingViewController.didMove(toParent: self)
        loadingViewController.start()
    }

    private func addObserver() {
        SolarSimulator.shared.observe {
            self.toggleOutletIfNeeded()
        }
        ChargeSettingsHandler.shared.observe {
            self.toggleOutletIfNeeded()
        }
    }

    private func startHomeKit() {
        homeKitHandler.delegate = self
        homeKitHandler.start()
    }

    func toggleOutletIfNeeded() {
        var state = homeKitHandler.outlet?.state
        guard let battery = batterySimulator.battery, SolarSimulator.shared.watt > 0, ChargeSettingsHandler.shared.watt > 0 else {
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
        state == .on ? batterySimulator.juice() : batterySimulator.pause()
    }
}

extension HomeViewController: HomeKitHandlerDelegate {
     func homeKitHandlerDidUpdate(_ homeKitHandler: HomeKitHandler, outlet: PowerOutlet) {
        toggleOutletIfNeeded()
    }
}
