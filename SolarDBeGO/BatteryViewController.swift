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

    private lazy var batteryView = BatteryViewContainer()

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
        API.shared.updateInfotainment(with: data)
    }

    func update(viewModel: BatteryViewModel) {
        batteryView.update(vm: viewModel)
        updateInfotainment()
        API.shared.updateStateOfCharge(viewModel.batteryValue, charging: true)
    }

    // MARK: Setup
    private func setupBatteryView() {
        view.addSubview(batteryView)
        batteryView.pinToEdges(of: view.safeAreaLayoutGuide)
    }
}

class BatteryView: UIView {
    private let emptyView = UIImageView()
    private let levelView = UIImageView()
    private var levelWidthConstraint: NSLayoutConstraint?
    let leftinset: CGFloat = 22.0
    let rightinset: CGFloat = 35.0

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        addSubview(emptyView)
        emptyView.image = UIImage(named: "empty.jpg")
        emptyView.pinToEdges(of: self)
        emptyView.setConstant(height: 100)
        emptyView.setConstant(width: 320)
        backgroundColor = .black

        emptyView.addSubview(levelView)
        levelView.image = UIImage(named: "green.jpg")

        levelView.pinToEdges(.left, of: emptyView, inset: leftinset)
        levelView.pinToEdges([.top, .bottom], of: emptyView)
        levelWidthConstraint = levelView.widthAnchor.constraint(equalToConstant: 0)
        levelWidthConstraint?.isActive = true
    }

    func updateLevel(_ level: CGFloat) {
        let width = bounds.size.width - leftinset - rightinset
        levelWidthConstraint?.constant = width * (level / 100)
    }
}

class BatteryViewContainer: UIView {

    struct Layout {
        static let padding: CGFloat = 10.0
    }
    private let batteryView = BatteryView()
    private let currentLevelLabel = UILabel()
    private let maxBatteryCapacityLabel = UILabel()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .black

        setupTitleLabel()
        setupBatteryView()
        setupLabels()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Update & Setup
    private func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.numberOfLines = 0
        titleLabel.pinToEdges(.top, of: self, inset: Layout.padding)
        titleLabel.centerX(of: self)
        titleLabel.textColor = .white
    }

    private func setupBatteryView() {
        addSubview(batteryView)
        batteryView.pinTop(to: titleLabel.bottomAnchor, inset: Layout.padding)
        batteryView.centerX(of: self)
    }

    private func setupLabels() {
        addSubview(currentLevelLabel)
        currentLevelLabel.pinTop(to: batteryView.bottomAnchor, inset: Layout.padding)
        currentLevelLabel.centerX(of: self)
        currentLevelLabel.pinBottom(to: bottomAnchor, inset: Layout.padding)
        currentLevelLabel.numberOfLines = 2
        currentLevelLabel.textColor = .white
        currentLevelLabel.textAlignment = .center

        addSubview(maxBatteryCapacityLabel)
        maxBatteryCapacityLabel.numberOfLines = 2
        maxBatteryCapacityLabel.textColor = .white
        maxBatteryCapacityLabel.textAlignment = .center
        maxBatteryCapacityLabel.pinToEdges(.right, of: self, inset: Layout.padding)
        maxBatteryCapacityLabel.centerY(of: currentLevelLabel)
    }

    func update(vm: BatteryViewModel) {
        titleLabel.text = vm.title
        maxBatteryCapacityLabel.text = vm.maxCapacityText
        batteryView.updateLevel(CGFloat(vm.batteryValue))
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
