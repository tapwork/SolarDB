//
//  SunViewController.swift
//  SolarDBeGO
//
//  Created by Christian Menschel on 23.05.19.
//  Copyright © 2019 SolarDB. All rights reserved.
//

import UIKit

struct PowerSliderViewModel {
    let title: String
    let backgroundColor: UIColor
    let fontColor: UIColor
    let powerHandler: PowerHandler
}

class PowerSliderViewController: UIViewController {

    // MARK: Properties
    private (set) lazy var slider = UISlider()
    private (set) lazy var wattLabel = UILabel()
    var viewModel: PowerSliderViewModel

    // MARK: Init
    init(viewModel: PowerSliderViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: View Life
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = viewModel.backgroundColor
        setupSlider()
        setupLabels()
        viewModel.powerHandler.observe {
            self.update()
        }
    }

    // MARK: Setup
    private func setupSlider() {
        view.addSubview(slider)
        slider.pinToEdges([.left, .right], of: view, inset: 5)
        slider.centerY(of: view)
        slider.isContinuous = true
        slider.value = Float(viewModel.powerHandler.watt / viewModel.powerHandler.maxWatt)
        slider.addTarget(self, action: #selector(update), for: .primaryActionTriggered)
    }

    private func setupLabels() {
        let titleLabel = UILabel()
        view.addSubview(titleLabel)
        titleLabel.text = viewModel.title
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.pinTop(to: view.topAnchor, inset: 5)
        titleLabel.pinToEdges([.left, .right], of: view, inset: 5)
        titleLabel.textColor = viewModel.fontColor

        view.addSubview(wattLabel)
        wattLabel.pinTop(to: slider.bottomAnchor, inset: 15)
        wattLabel.centerX(of: slider)
        wattLabel.textColor = viewModel.fontColor
        update()
    }

    // MARK: Actions
    @objc func update() {
        let value = viewModel.powerHandler.maxWatt * Double(slider.value)
        wattLabel.text = value.decimalFormatted
        viewModel.powerHandler.watt = value
    }
}

class ChargeSettingsViewController: PowerSliderViewController {
    required init() {
        let vm = PowerSliderViewModel(title: "Minimum solar power (kW) to enable charging the car",
                                      backgroundColor: .blue,
                                      fontColor: .white,
                                      powerHandler: ChargeSettingsHandler.shared)
        super.init(viewModel: vm)
    }

    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
}

class SolarPowerSliderViewController: PowerSliderViewController {

    required init() {
        let vm = PowerSliderViewModel(title: "Sun: Simulation of power produced by solar",
                                      backgroundColor: .yellow,
                                      fontColor: .black,
                                      powerHandler: SolarSimulator.shared)
        super.init(viewModel: vm)
    }

    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
}

