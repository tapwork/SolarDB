//
//  SunViewController.swift
//  SolarDBeGO
//
//  Created by Christian Menschel on 23.05.19.
//  Copyright © 2019 SolarDB. All rights reserved.
//

import UIKit

protocol PowerSliderViewControllerDelegate: class {
    func powerSliderViewController(_ powerSliderViewController: PowerSliderViewController,
                                   didUpdate viewModel: PowerSliderViewModel)
}

class PowerSliderViewController: UIViewController {


    // MARK: Properties
    private lazy var slider = UISlider()
    private lazy var maxPeakLabel = UILabel()
    private lazy var currentPeakLabel = UILabel()
    weak var delegate: PowerSliderViewControllerDelegate?
    private var viewModel: PowerSliderViewModel

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
    }

    // MARK: Setup
    private func setupSlider() {
        view.addSubview(slider)
        slider.pinToEdges([.left, .right], of: view, inset: 5)
        slider.centerY(of: view)
        slider.isContinuous = true
        slider.addTarget(self, action: #selector(updatePeak), for: .primaryActionTriggered)
    }

    private func setupLabels() {
        let titleLabel = UILabel()
        view.addSubview(titleLabel)
        titleLabel.text = viewModel.title
        titleLabel.pinTop(to: view.topAnchor, inset: 5)
        titleLabel.centerX(of: view)
        titleLabel.textColor = viewModel.fontColor

//        maxPeakLabel.text = "\(viewModel.maxPeak) kW (Peak)"
//        view.addSubview(maxPeakLabel)
//        maxPeakLabel.centerY(of: slider)
//        maxPeakLabel.pinLeading(to: slider.trailingAnchor, inset: 5)
//        maxPeakLabel.pinTrailing(to: view.trailingAnchor, inset: 5)
//        maxPeakLabel.textColor = viewModel.fontColor

        view.addSubview(currentPeakLabel)
        currentPeakLabel.pinTop(to: slider.bottomAnchor, inset: 15)
        currentPeakLabel.centerX(of: slider)
        currentPeakLabel.textColor = viewModel.fontColor
        updatePeak()
    }

    // MARK: Actions
    @objc func updatePeak() {
        let value = viewModel.maxPeak * Double(slider.value)
        currentPeakLabel.text = value.decimalFormatted
        viewModel.currentPeak = value
        delegate?.powerSliderViewController(self, didUpdate: viewModel)
    }
}
