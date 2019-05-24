//
//  SettingsViewController.swift
//  SolarDBeGO
//
//  Created by Christian Menschel on 24.05.19.
//  Copyright © 2019 SolarDB. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    // MARK: Properties
    lazy var chargeSettingsViewController: PowerSliderViewController = {
        let vm = PowerSliderViewModel(title: "Minimum solar power (kW) to enable charging the car",
                             backgroundColor: .green,
                             fontColor: .black,
                             powerHandler: ChargeSettingsHandler.shared)
        return PowerSliderViewController(viewModel: vm)
    }()

    lazy var batterySimulator = BatterySimulator()

    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addBatterySettingsViewController()
    }

    // MARK: Setup
    private func addBatterySettingsViewController() {
        addChild(chargeSettingsViewController)
        view.addSubview(chargeSettingsViewController.view)
        chargeSettingsViewController.didMove(toParent: self)
        chargeSettingsViewController.view.pinToEdges([.left, .right], of: view.safeAreaLayoutGuide)
        chargeSettingsViewController.view.centerY(of: view)
    }
}
