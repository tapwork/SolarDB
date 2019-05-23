//
//  SunViewController.swift
//  SolarDBeGO
//
//  Created by Christian Menschel on 23.05.19.
//  Copyright © 2019 SolarDB. All rights reserved.
//

import UIKit

class SunViewController: UIViewController {

    struct Constants {
        static let maxPeak: Double = 10.0
    }

    // MARK: Properties
    private lazy var slider = UISlider()
    private lazy var maxPeakLabel = UILabel()
    private lazy var currentPeakLabel = UILabel()

    // MARK: View Life
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .yellow
        setupSlider()
        setupLabels()
    }

    // MARK: Setup
    private func setupSlider() {
        view.addSubview(slider)
        slider.centerY(of: view)
        slider.pinToEdges(.left, of: view, inset: 5)
        slider.isContinuous = true
        slider.addTarget(self, action: #selector(updatePeak), for: .primaryActionTriggered)
    }

    private func setupLabels() {
        maxPeakLabel.text = "\(Constants.maxPeak) kW (Peak)"
        view.addSubview(maxPeakLabel)
        maxPeakLabel.centerY(of: slider)
        maxPeakLabel.pinLeading(to: slider.trailingAnchor, inset: 5)
        maxPeakLabel.pinTrailing(to: view.trailingAnchor, inset: 5)

        view.addSubview(currentPeakLabel)
        currentPeakLabel.pinTop(to: slider.bottomAnchor, inset: 5)
        currentPeakLabel.centerX(of: slider)
        updatePeak()
    }

    // MARK: Actions
    @objc func updatePeak() {
        let value = Constants.maxPeak * Double(slider.value)
        currentPeakLabel.text = value.decimalFormatted + " kW"
    }
}
