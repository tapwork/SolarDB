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
    lazy var batteryResetButton = UIButton()
    var batterySimulator: BatterySimulator { return BatterySimulator.shared }

    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addBatterySettingsViewController()
        addResetBatteryButton()
    }

    // MARK: Setup
    private func addBatterySettingsViewController() {
        addChild(chargeSettingsViewController)
        view.addSubview(chargeSettingsViewController.view)
        chargeSettingsViewController.didMove(toParent: self)
        chargeSettingsViewController.view.pinToEdges([.left, .right], of: view.safeAreaLayoutGuide)
        chargeSettingsViewController.view.centerY(of: view)
    }

    private func addResetBatteryButton() {
        view.addSubview(batteryResetButton)
        batteryResetButton.addTarget(self,
                                     action: #selector(SettingsViewController.resetBattery),
                                     for: .primaryActionTriggered)
        batteryResetButton.pinTop(to: chargeSettingsViewController.view.bottomAnchor, inset: 20)
        batteryResetButton.centerX(of: view)
        batteryResetButton.setConstant(height: 50)
        batteryResetButton.backgroundColor = .red
        batteryResetButton.setTitle("Reset battery", for: .normal)
    }

    // MARK: Actions
    @objc func resetBattery() {
        batterySimulator.reset()
    }
}