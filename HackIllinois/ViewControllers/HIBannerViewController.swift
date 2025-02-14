//
//  HIBannerViewController.swift
//  HackIllinois
//
//  Created by HackIllinois Team on 12/30/22.
//  Copyright © 2022 HackIllinois. All rights reserved.
//  This file is part of the Hackillinois iOS App.
//  The Hackillinois iOS App is open source software, released under the University of
//  Illinois/NCSA Open Source License. You should have received a copy of
//  this license in a file with the distribution.
//

import Foundation
import UIKit

class HIBannerViewController: UIViewController {
    private let backgroundHIColor: HIColor = \.clear
    private let bannerBackground: HIColor = \.bannerBackground
    private let label = HILabel {
        $0.textHIColor = \.countdownTextColor
        $0.backgroundHIColor = \.clear
        $0.textAlignment = .center
        $0.font = HIAppearance.Font.glyph
    }
}

extension HIBannerViewController {
    override func loadView() {
        view = HIView { $0.backgroundHIColor = \.clear }

        let bannerStackView = UIStackView()
        view.addSubview(bannerStackView)
        bannerStackView.distribution = .fillEqually
        bannerStackView.translatesAutoresizingMaskIntoConstraints = false
        bannerStackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bannerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bannerStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bannerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        let daysContent = bannerView(with: label)
        bannerStackView.addArrangedSubview(daysContent)
    }
    func bannerView(with label: HILabel) -> UIView {
        let bannerView = UIView()
        bannerView.addSubview(label)
        
        bannerView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        label.constrain(to: bannerView, topInset: 0, trailingInset: 0, bottomInset: 0, leadingInset: 0)
        label.widthAnchor.constraint(equalTo: bannerView.widthAnchor).isActive = true

        bannerView.layer.cornerRadius = 7.5
        bannerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//        bannerView.backgroundColor = bannerBackground.value
        bannerView.backgroundColor = UIColor(red: 224/255, green: 198/255, blue: 159/255, alpha: 1.0)  // #E0C69F

        
        return bannerView
    }
    public func updateLabel(with text: String) {
        label.text = text
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
