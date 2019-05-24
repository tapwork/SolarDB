//
//  LoadingViewController.swift
//  SolarDBeGO
//
//  Created by Christian Menschel on 24.05.19.
//  Copyright © 2019 SolarDB. All rights reserved.
//

import UIKit

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

