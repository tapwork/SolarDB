//
//  SunViewController.swift
//  SolarDBeGO
//
//  Created by Christian Menschel on 23.05.19.
//  Copyright © 2019 SolarDB. All rights reserved.
//

import UIKit

class SunViewController: UIViewController {

    // MARK: Properties
    private lazy var slider = UISlider()

    // MARK: View Life
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .yellow
        setupSlider()
    }

    // MARK: Setup
    private func setupSlider() {
        view.addSubview(slider)
        slider.center(of: view)
        slider.addTarget(self, action: #selector(handleSlider), for: .primaryActionTriggered)
    }

    // MARK: Actions
    @objc func handleSlider() {
        
    }
}
