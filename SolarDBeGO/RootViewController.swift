//
//  ViewController.swift
//  SolarDBeGO
//
//  Created by Christian Menschel on 23.05.19.
//  Copyright © 2019 SolarDB. All rights reserved.
//

import UIKit
import HomeKit

class LoadingViewController: UIViewController {

    private lazy var activityIndicator = UIActivityIndicatorView(style: .gray)
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        view.addSubview(activityIndicator)
        activityIndicator.center(of: view)
        activityIndicator.hidesWhenStopped = true
    }

    func stop() {
        view.isHidden = true
        activityIndicator.stopAnimating()
    }

    func start() {
        view.isHidden = false
        activityIndicator.startAnimating()
    }
}

class RootViewController: UIViewController {

    // MARK: Properties
    lazy var sunViewController: PowerSliderViewController = {
        return PowerSliderViewController(viewModel: PowerSliderViewModel.sun)
    }()

    lazy var powerPlugViewController: PowerSliderViewController = {
        return PowerSliderViewController(viewModel: PowerSliderViewModel.outlet)
    }()
    lazy var loadingViewController = LoadingViewController()
    lazy var batteryViewController = BatteryViewController()
    lazy var homeKitHandler = HomeKitHandler()
    lazy var batterySimulator = BatterySimulator()

    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        addSunViewController()
        addBatteryViewController()
        addPowerPlugViewController()
        addBatteryLoadingSimulator()
        addLoadingViewController()
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

    private func addBatteryLoadingSimulator() {
        batterySimulator.canStartCharging = {[weak self] battery in
            guard let self = self else { return }
            self.loadingViewController.stop()
            self.batteryViewController.update(viewModel: BatteryViewModel(battery))
        }
        batterySimulator.updateHandler = {[weak self] battery in
            guard let self = self else { return }
            self.batteryViewController.update(viewModel: BatteryViewModel(battery))
        }
    }

    private func addLoadingViewController() {
        addChild(loadingViewController)
        view.addSubview(loadingViewController.view)
        loadingViewController.didMove(toParent: self)
        loadingViewController.start()
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
        state == .on ? batterySimulator.juice() : batterySimulator.pause()
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
