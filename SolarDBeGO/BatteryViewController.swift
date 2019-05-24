//
//  BatteryViewController.swift
//  SolarDBeGO
//
//  Created by Christian Menschel on 23.05.19.
//  Copyright © 2019 SolarDB. All rights reserved.
//

import UIKit

struct BatteryViewModel {
    let isCharging: Bool
    let batteryValue: Double
    let maxBatteryCapacity: Double
    let currentLoadingPower: Double

    init(_ battery: Battery) {
        self.batteryValue = battery.chargeLevel
        self.maxBatteryCapacity = battery.capacity
        self.currentLoadingPower = battery.loadingPower
        self.isCharging = battery.isCharging
    }

    var title: String {
        if batteryValue >= 100 {
            return "Battery fully juiced ;-)"
        }
        if isCharging {
            return "Current charging power: \(currentLoadingPower.decimalFormatted) kW"
        }
        return "Battery ready to charge"
    }

    var maxCapacityText: String {
        return "Max\n\(maxBatteryCapacity.decimalFormatted) kWh"
    }
    var chargingText: String {
        let currentKWH = (maxBatteryCapacity * batteryValue) / 100
        return "\(batteryValue.decimalFormatted)%\n(\(currentKWH.decimalFormatted) kWh)"
    }
}

class BatteryViewController: UIViewController {

    private lazy var batteryView = BatteryView()

    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBatteryView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateInfotainment()
    }
    
    func updateInfotainment() {
        guard let data = batteryView.image?.pngData() else {
            print("Couldn't generate image from screen")
            return
        }
        API.shared.updateInfotainement(with: data)
    }

    func update(viewModel: BatteryViewModel) {
        batteryView.update(vm: viewModel)
        updateInfotainment()
        API.shared.updateStateOfCharge(viewModel.currentLoadingPower, charging: true)
    }

    // MARK: Setup
    private func setupBatteryView() {
        view.addSubview(batteryView)
        batteryView.pinToEdges(of: view.safeAreaLayoutGuide)
    }
}

class BatteryView: UIView {

    private let chargedBarView = UIView()
    private var chargedBarWidthConstraint: NSLayoutConstraint?
    private let currentLevelLabel = UILabel()
    private let maxBatteryCapacityLabel = UILabel()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .lightGray
        setupChargedBarView()
        setupLabels()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Update & Setup
    private func setupChargedBarView() {
        addSubview(chargedBarView)
        chargedBarView.backgroundColor = .green
        chargedBarView.pinToEdges([.left, .top, .bottom], of: self)
        let constraint = chargedBarView.widthAnchor.constraint(equalToConstant: 0)
        constraint.isActive = true
        chargedBarWidthConstraint = constraint
    }

    private func setupLabels() {
        addSubview(titleLabel)
        titleLabel.pinToEdges(.top, of: self, inset: 5)
        titleLabel.centerX(of: self)

        addSubview(currentLevelLabel)
        currentLevelLabel.center(of: self)
        currentLevelLabel.numberOfLines = 2
        currentLevelLabel.textAlignment = .center

        maxBatteryCapacityLabel.numberOfLines = 2
        maxBatteryCapacityLabel.textAlignment = .center
        addSubview(maxBatteryCapacityLabel)
        maxBatteryCapacityLabel.pinToEdges(.right, of: self, inset: 5)
        maxBatteryCapacityLabel.centerY(of: self)
    }

    func update(vm: BatteryViewModel) {
        titleLabel.text = vm.title
        maxBatteryCapacityLabel.text = vm.maxCapacityText
        let width = bounds.width * CGFloat(vm.batteryValue / 100)
        chargedBarWidthConstraint?.constant = width
        currentLevelLabel.text = vm.chargingText
    }
    
    var image: UIImage? { get {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    } }
}
