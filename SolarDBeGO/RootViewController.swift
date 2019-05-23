//
//  ViewController.swift
//  SolarDBeGO
//
//  Created by Christian Menschel on 23.05.19.
//  Copyright © 2019 SolarDB. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {

    // MARK: Properties
    lazy var sunViewController: PowerSliderViewController = {
        let viewModel = PowerSliderViewModel(maxPeak: 10,
                                             currentPeak: 0,
                                             title: "Simulation of power produced by the sun",
                                             backgroundColor: .yellow,
                                             fontColor: .black)
        return PowerSliderViewController(viewModel: viewModel)
    }()

    lazy var powerPlugViewController: PowerSliderViewController = {
        let viewModel = PowerSliderViewModel(maxPeak: 3.5,
                                             currentPeak: 0,
                                             title: "Minimum power peak (kW) to charge the car",
                                             backgroundColor: .blue,
                                             fontColor: .white)
        return PowerSliderViewController(viewModel: viewModel)
    }()

    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        addSunViewController()
        addPowerPlugViewController()
    }

    // MARK: Setup
    private func addSunViewController() {
        addChild(sunViewController)
        view.addSubview(sunViewController.view)
        sunViewController.delegate = self
        sunViewController.didMove(toParent: self)
        sunViewController.view.pinToEdges([.left, .top, .right], of: view.safeAreaLayoutGuide)
        sunViewController.view.setConstant(height: view.bounds.height/2)
    }

    private func addPowerPlugViewController() {
        addChild(powerPlugViewController)
        view.addSubview(powerPlugViewController.view)
        powerPlugViewController.delegate = self
        powerPlugViewController.didMove(toParent: self)
        powerPlugViewController.view.pinTop(to: sunViewController.view.bottomAnchor)
        powerPlugViewController.view.pinToEdges([.left, .right], of: view.safeAreaLayoutGuide)
        powerPlugViewController.view.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor)
    }
}

extension RootViewController: PowerSliderViewControllerDelegate {
    func powerSliderViewController(_ powerSliderViewController: PowerSliderViewController,
                                   didUpdate viewModel: PowerSliderViewModel) {
        if powerSliderViewController === powerPlugViewController {
            // Start or stop
        }
    }
}
