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
    private (set) lazy var titleLabel = UILabel()
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
        view.layoutMargins = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        setupTitleLabel()
        setupSlider()
        setupWattLabel()
        viewModel.powerHandler.observe {
            self.update()
        }
    }

    // MARK: Setup
    private func setupTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.text = viewModel.title
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.pinTop(to: view.layoutMarginsGuide.topAnchor)
        titleLabel.pinToEdges([.left, .right], of: view, inset: 20)
        titleLabel.textColor = viewModel.fontColor
    }

    private func setupSlider() {
        view.addSubview(slider)
        slider.pinToEdges([.left, .right], of: view.layoutMarginsGuide, inset: 15)
        slider.pinTop(to: titleLabel.bottomAnchor, inset: 10)
        slider.isContinuous = true
        slider.value = Float(viewModel.powerHandler.watt / viewModel.powerHandler.maxWatt)
        slider.addTarget(self, action: #selector(update), for: .primaryActionTriggered)
    }

    private func setupWattLabel() {
        view.addSubview(wattLabel)
        wattLabel.pinTop(to: slider.bottomAnchor, inset: 15)
        wattLabel.centerX(of: slider)
        wattLabel.pinBottom(to: view.layoutMarginsGuide.bottomAnchor)
        wattLabel.textColor = viewModel.fontColor
        update()
    }

    // MARK: Actions
    @objc func update() {
        let value = viewModel.powerHandler.maxWatt * Double(slider.value)
        wattLabel.text = value.decimalFormatted + " kW"
        viewModel.powerHandler.watt = value
    }
}
