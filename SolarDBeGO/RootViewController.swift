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
    lazy var sunViewController = SunViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        addSunViewController()
    }

    // MARK: Setup
    private func addSunViewController() {
        addChild(sunViewController)
        view.addSubview(sunViewController.view)
        sunViewController.didMove(toParent: self)
        sunViewController.view.pinToEdges([.left, .top, .right], of: view.safeAreaLayoutGuide)
        sunViewController.view.setConstant(height: view.bounds.height/2)
    }
}

