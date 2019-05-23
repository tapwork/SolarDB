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


    // MOCK:
    private var chargeLevel: Double = 0.0
    private var timer: Timer?

    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        addSunViewController()
        addBatteryViewController()
        addPowerPlugViewController()
        startHomeKit()

        // Mock
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {[weak self] timer in
            guard let self = self else { return }
            if self.chargeLevel > 100 {
                timer.invalidate()
                return
            }
            self.batteryViewController.update(viewModel: BatteryViewModel(batteryValue: self.chargeLevel,
                                                                          maxBatteryCapacity: 24, currentLoadingPower: 9))
            self.chargeLevel = self.chargeLevel + 5.0
        })
        timer?.fire()
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

    private func startHomeKit() {
        homeKitHandler.delegate = self
        homeKitHandler.start()
    }
}

extension RootViewController: PowerSliderViewControllerDelegate {
    func powerSliderViewController(_ powerSliderViewController: PowerSliderViewController,
                                   didUpdate viewModel: PowerSliderViewModel) {
        toggleOutletIfNeeded()
    }

    func toggleOutletIfNeeded() {
        guard sunViewController.viewModel.watt > 0 else {
            homeKitHandler.outlets.forEach {$0.state = .off}
            return
        }
        if sunViewController.viewModel.watt >= powerPlugViewController.viewModel.watt {
            homeKitHandler.outlets.forEach {$0.state = .on}
        } else {
            homeKitHandler.outlets.forEach {$0.state = .off}
        }
    }
}

extension RootViewController: HomeKitHandlerDelegate {
    func homeKitHandlerDidUpdate(_ homeKitHandler: HomeKitHandler, outlets: [PowerOutlet]) {
        toggleOutletIfNeeded()
    }
}
