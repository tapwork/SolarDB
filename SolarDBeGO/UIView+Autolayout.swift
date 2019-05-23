//
//  UIView+Autolayout.swift
//  SolarDBeGO
//
//  Created by Christian Menschel on 23.05.19.
//  Copyright © 2019 SolarDB. All rights reserved.
//

import UIKit

public protocol AutoLayoutContainer {
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
    var centerXAnchor: NSLayoutXAxisAnchor { get }
    var centerYAnchor: NSLayoutYAxisAnchor { get }
    var widthAnchor: NSLayoutDimension { get }
    var heightAnchor: NSLayoutDimension { get }
}

extension UIView: AutoLayoutContainer {}
extension UILayoutGuide: AutoLayoutContainer {}

public extension AutoLayoutContainer {
    // MARK: All Edges
    @discardableResult
    func pinToEdges(_ edges: UIRectEdge = .all, of container: AutoLayoutContainer, inset: CGFloat = 0) -> [NSLayoutConstraint] {
        if let view = self as? UIView {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        var constraints = [NSLayoutConstraint]()
        if edges.contains(.top) {
            constraints.append(topAnchor.constraint(equalTo: container.topAnchor, constant: inset))
        }
        if edges.contains(.left) {
            constraints.append(leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: inset))
        }
        if edges.contains(.bottom) {
            constraints.append(bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -inset))
        }
        if edges.contains(.right) {
            constraints.append(trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -inset))
        }
        constraints.forEach { $0.isActive = true }
        return constraints
    }

    @discardableResult
    func pinLeading(to constraint: NSLayoutAnchor<NSLayoutXAxisAnchor>, inset: CGFloat = 0) -> NSLayoutConstraint {
        if let view = self as? UIView {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        let constraint = leadingAnchor.constraint(equalTo: constraint, constant: inset)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func pinTrailing(to constraint: NSLayoutAnchor<NSLayoutXAxisAnchor>, inset: CGFloat = 0) -> NSLayoutConstraint {
        if let view = self as? UIView {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        let constraint = trailingAnchor.constraint(equalTo: constraint, constant: -inset)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func pinToTop(of container: AutoLayoutContainer, inset: CGFloat = 0) -> NSLayoutConstraint {
        if let view = self as? UIView {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        let constraint = topAnchor.constraint(equalTo: container.topAnchor, constant: inset)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func pinToBottom(of container: AutoLayoutContainer, inset: CGFloat = 0) -> NSLayoutConstraint {
        if let view = self as? UIView {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        let constraint = bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -inset)
        constraint.isActive = true
        return constraint
    }

    // MARK: Center
    @discardableResult
    func centerX(of container: AutoLayoutContainer) -> NSLayoutConstraint {
        if let view = self as? UIView {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        let constraint = centerXAnchor.constraint(equalTo: container.centerXAnchor)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func centerY(of container: AutoLayoutContainer) -> NSLayoutConstraint {
        if let view = self as? UIView {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        let constraint = centerYAnchor.constraint(equalTo: container.centerYAnchor)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func center(of container: AutoLayoutContainer) -> [NSLayoutConstraint] {
        if let view = self as? UIView {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        let constraints = [
            centerXAnchor.constraint(equalTo: container.centerXAnchor),
            centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ]
        constraints.forEach { $0.isActive = true }
        return constraints
    }

    // MARK: Size
    @discardableResult
    func pinWidth(of container: AutoLayoutContainer, inset: CGFloat = 0) -> NSLayoutConstraint {
        if let view = self as? UIView {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        let constraint = widthAnchor.constraint(equalTo: container.widthAnchor, constant: -inset)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func pinHeight(of container: AutoLayoutContainer, inset: CGFloat = 0) -> NSLayoutConstraint {
        if let view = self as? UIView {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        let constraint = heightAnchor.constraint(equalTo: container.heightAnchor, constant: -inset)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func setConstant(size: CGSize) -> [NSLayoutConstraint] {
        if let view = self as? UIView {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        let widthConstraint = widthAnchor.constraint(equalToConstant: size.width)
        let heightConstraint = heightAnchor.constraint(equalToConstant: size.height)
        widthConstraint.isActive = true
        heightConstraint.isActive = true
        return [widthConstraint, heightConstraint]
    }

    @discardableResult
    func setConstant(width: CGFloat) -> [NSLayoutConstraint] {
        if let view = self as? UIView {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        let constraint = widthAnchor.constraint(equalToConstant: width)
        constraint.isActive = true
        return [constraint]
    }

    @discardableResult
    func setConstant(height: CGFloat) -> [NSLayoutConstraint] {
        if let view = self as? UIView {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        let constraint = heightAnchor.constraint(equalToConstant: height)
        constraint.isActive = true
        return [constraint]
    }
}
