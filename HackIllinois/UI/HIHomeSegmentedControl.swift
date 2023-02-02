//
//  HIHomeSegmentedControl.swift
//  HackIllinois
//
//  Created by HackIllinois Team on 1/30/21.
//  Copyright © 2021 HackIllinois. All rights reserved.
//  This file is part of the Hackillinois iOS App.
//  The Hackillinois iOS App is open source software, released under the University of
//  Illinois/NCSA Open Source License. You should have received a copy of
//  this license in a file with the distribution.
//

import Foundation
import UIKit
import SwiftUI

class HIHomeSegmentedControl: HISegmentedControl {

    // MARK: - Properties

    private var views = [UIView]()
    private var titleLabels = [UILabel]()

    private let titleFont = HIAppearance.Font.homeSegmentedTitle
    private let titleFontPad = HIAppearance.Font.homeSegmentedTitlePad
    private let numberFont = HIAppearance.Font.segmentedNumberText

    private var viewPadding: CGFloat = 35
    private let indicatorCornerRadiusProp: CGFloat = 0.15

    private var indicatorView = UIImageView(image: #imageLiteral(resourceName: "Indicator"))

    // MARK: - Init
    init(status: [String]) {
        super.init(items: status)

        NotificationCenter.default.addObserver(self, selector: #selector(refreshForThemeChange), name: .themeDidChange, object: nil)
        translatesAutoresizingMaskIntoConstraints = false
        setupView()
        refreshForThemeChange()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) should not be used")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Themeable
    @objc override func refreshForThemeChange() {
        backgroundColor <- \.clear
        titleLabels.forEach {
            $0.textColor <- \.white
            $0.backgroundColor <- \.clear
        }
    }

    // MARK: - UIView
    override func layoutSubviews() {
        super.layoutSubviews()
        let indicatorViewWidth = ((frame.width - viewPadding) / CGFloat(items.count) - viewPadding)
        var indicatorViewConstant: CGFloat = 4
        if UIDevice.current.userInterfaceIdiom == .pad {
            indicatorViewConstant = 6
        }
        indicatorView.frame = CGRect(x: indicatorViewWidth, y: 40 + indicatorViewConstant, width: indicatorViewWidth, height: indicatorViewConstant)
        indicatorView.layer.cornerRadius = frame.height * indicatorCornerRadiusProp
        indicatorView.layer.masksToBounds = true
        indicatorView.contentMode = .center
        indicatorView.contentMode = .scaleAspectFit
        displayNewSelectedIndex()
    }

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)

        for (index, view) in views.enumerated() where view.frame.contains(location) {
                selectedIndex = index
                break
        }

        return false
    }

    // MARK: - View Setup
    override func setupView() {
        setupLabels()
        addSubview(indicatorView)
    }

    override func setupLabels() {
        views.forEach { $0.removeFromSuperview() }
        views.removeAll(keepingCapacity: true)
        items.indices.forEach { setupViewForItem(at: $0) }
        constrain(views: views)
    }

    private func setupViewForItem(at index: Int) {
        let view = UIView()
        let titleLabel = UILabel()
        if UIDevice.current.userInterfaceIdiom == .pad {
            titleLabel.font = titleFontPad
        } else {
            titleLabel.font = titleFont
        }
        titleLabel.textAlignment = .center

        titleLabel.text = items[index]
        titleLabel.textColor <- \.whiteText
        titleLabel.adjustsFontSizeToFitWidth = false

        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.constrain(to: view, topInset: 5, trailingInset: 0, bottomInset: -5, leadingInset: 0)
        view.isUserInteractionEnabled = false
        titleLabel.isUserInteractionEnabled = false
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        views.append(view)
        titleLabels.append(titleLabel)
    }

    override func didSetSelectedIndex(oldValue: Int) {
        if oldValue != selectedIndex {
            displayNewSelectedIndex()
            sendActions(for: .valueChanged)
        }
    }

    override func displayNewSelectedIndex() {
        let selectedView = views[selectedIndex]

        let animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.8)
        animator.addAnimations {
            self.indicatorView.frame.origin.x = selectedView.frame.origin.x
        }
        animator.startAnimation()
    }

    private func constrain(views: [UIView]) {

        for (index, view) in views.enumerated() {

            // top and bottom
            view.constrain(to: self, topInset: 0, bottomInset: 0)

            // right
            if index == items.count - 1 {
                view.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -viewPadding).isActive = true
            }

            // left
            if index == 0 {
                view.leftAnchor.constraint(equalTo: self.leftAnchor, constant: viewPadding).isActive = true
            } else {
                let prevView = views[index - 1]
                view.leftAnchor.constraint(equalTo: prevView.rightAnchor, constant: viewPadding).isActive = true
            }

            // width
            if index != 0 {
                let firstView = views[0]
                view.widthAnchor.constraint(equalTo: firstView.widthAnchor).isActive = true
            }
        }
    }
}
