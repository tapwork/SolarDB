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
    private lazy var wattLabel = UILabel()
    weak var delegate: PowerSliderViewControllerDelegate?
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

        view.addSubview(wattLabel)
        wattLabel.pinTop(to: slider.bottomAnchor, inset: 15)
        wattLabel.centerX(of: slider)
        wattLabel.textColor = viewModel.fontColor
        updatePeak()
    }

    // MARK: Actions
    @objc func updatePeak() {
        let value = viewModel.maxWatt * Double(slider.value)
        wattLabel.text = value.decimalFormatted
        viewModel.watt = value
        delegate?.powerSliderViewController(self, didUpdate: viewModel)
    }
}
