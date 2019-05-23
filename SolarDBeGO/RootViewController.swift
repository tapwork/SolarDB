//
//  ViewController.swift
//  SolarDBeGO
//
//  Created by Christian Menschel on 23.05.19.
//  Copyright © 2019 SolarDB. All rights reserved.
//

import UIKit
import HomeKit

class RootViewController: UIViewController {

    // MARK: Properties
    lazy var sunViewController: PowerSliderViewController = {
        return PowerSliderViewController(viewModel: PowerSliderViewModel.sun)
    }()

    lazy var powerPlugViewController: PowerSliderViewController = {
        return PowerSliderViewController(viewModel: PowerSliderViewModel.outlet)
    }()
    lazy var batteryViewController = BatteryViewController()
    lazy var homeKitHandler = HomeKitHandler()
    lazy var batteryLoadingSimulator = BatteryLoadingSimulator()

    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        addSunViewController()
        addBatteryViewController()
        addPowerPlugViewController()
        setupBatteryLoadingSimulator()
        startHomeKit()
    }

    // MARK: Setup
    private func addSunViewController() {
        addChild(sunViewController)
        view.addSubview(sunViewController.view)
        sunViewController.delegate = self
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

    private func addPowerPlugViewController() {
        addChild(powerPlugViewController)
        view.addSubview(powerPlugViewController.view)
        powerPlugViewController.delegate = self
        powerPlugViewController.didMove(toParent: self)
        powerPlugViewController.view.pinTop(to: batteryViewController.view.bottomAnchor)
        powerPlugViewController.view.pinToEdges([.left, .right], of: view.safeAreaLayoutGuide)
        powerPlugViewController.view.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor)
    }

    private func setupBatteryLoadingSimulator() {
        batteryLoadingSimulator.updateHandler = {[weak self] chargeLevel in
            guard let self = self else { return }
            let loadingPower = self.powerPlugViewController.viewModel.watt
            let maxBatteryCapacity = 24.0
            guard chargeLevel > 0, maxBatteryCapacity > 0, loadingPower > 0 else {
                return
            }
            let vm = BatteryViewModel(batteryValue: chargeLevel,
                                      maxBatteryCapacity: maxBatteryCapacity,
                                      currentLoadingPower: loadingPower)
            self.batteryViewController.update(viewModel: vm)
        }
    }

    private func startHomeKit() {
        homeKitHandler.delegate = self
        homeKitHandler.start()
    }

    func toggleOutletIfNeeded() {
        var state = homeKitHandler.outlet?.state
        guard sunViewController.viewModel.watt > 0, powerPlugViewController.viewModel.watt > 0 else {
            state = .off
            return
        }
        if sunViewController.viewModel.watt >= powerPlugViewController.viewModel.watt {
            state = .on
        } else {
            state = .off
        }
        homeKitHandler.outlet?.state = state
        state == .on ? batteryLoadingSimulator.start() : batteryLoadingSimulator.pause()
    }
}

extension RootViewController: PowerSliderViewControllerDelegate {
    func powerSliderViewController(_ powerSliderViewController: PowerSliderViewController,
                                   didUpdate viewModel: PowerSliderViewModel) {
        toggleOutletIfNeeded()
    }
}

extension RootViewController: HomeKitHandlerDelegate {
     func homeKitHandlerDidUpdate(_ homeKitHandler: HomeKitHandler, outlet: PowerOutlet) {
        toggleOutletIfNeeded()
    }
}
