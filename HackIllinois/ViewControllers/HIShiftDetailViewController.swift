//
//  HIEventDetailViewController.swift
//  HackIllinois
//
//  Created by HackIllinois Team on 02/19/24.
//  Copyright © 2024 HackIllinois. All rights reserved.
//  This file is part of the Hackillinois iOS App.
//  The Hackillinois iOS App is open source software, released under the University of
//  Illinois/NCSA Open Source License. You should have received a copy of
//  this license in a file with the distribution.
//

import Foundation
import UIKit
import MapKit
import HIAPI
import APIManager
import GoogleMaps

class HIShiftDetailViewController: HIBaseViewController {
    // MARK: - Properties
    var shiftName: String?
    var shiftTime: String?
    var shiftLocation: String?
    var shiftDescription: String?
    
    // MARK: Views
    private let eventDetailContainer = HIView {
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundHIColor = \.clear
    }
    private let upperContainerView = HIView {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundHIColor = \.clear
    }
    private let titleLabel = HILabel(style: .detailTitle)

    private let eventTypeView = HIView { (view) in
        if UIDevice.current.userInterfaceIdiom == .pad {
            view.layer.cornerRadius = 12
        } else {
            view.layer.cornerRadius = 8
        }
        view.backgroundHIColor = \.buttonSienna
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    private let eventTypeLabel = HILabel(style: .eventType)
    private let timeImageView = UIImageView(image: UIImage(named: "Clock"))
    private let timeLabel = HILabel(style: .description)
    private let locationLabel = HILabel(style: .location)
    private let locationImageView = UIImageView(image: UIImage(named: "LocationSign"))
    private let descriptionLabel = HILabel(style: .detailText)
    private let closeButton = HIButton {
        $0.tintHIColor = \.baseText
        $0.backgroundHIColor = \.clear
        $0.activeImage = #imageLiteral(resourceName: "MenuClose")
        $0.baseImage = #imageLiteral(resourceName: "MenuClose")
    }
    
    // MARK: Constraints
    private var descriptionLabelHeight = NSLayoutConstraint()

}

// MARK: - Actions
extension HIShiftDetailViewController {

    @objc func didSelectCloseButton(_ sender: HIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIViewController
extension HIShiftDetailViewController {

    override func loadView() {
        super.loadView()

        setupCloseButton()
        setupContainers()
        setupTitle()
        setupTime()
        setupLocation()
        setupDescription()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleLabel.text = shiftName
        descriptionLabel.text = shiftDescription
        timeLabel.text = shiftTime
        view.layoutIfNeeded()
        let targetSize = CGSize(width: descriptionLabel.frame.width, height: .greatestFiniteMagnitude)
        let neededSize = descriptionLabel.sizeThatFits(targetSize)
        descriptionLabelHeight.constant = neededSize.height
        // Default text for online events
        locationLabel.text = shiftLocation
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func setupContainers() {
        view.addSubview(eventDetailContainer)
        eventDetailContainer.topAnchor.constraint(equalTo: closeButton.bottomAnchor).isActive = true
        eventDetailContainer.constrain(to: view.safeAreaLayoutGuide, trailingInset: -8, bottomInset: 0, leadingInset: 8)

        eventDetailContainer.addSubview(upperContainerView)
        upperContainerView.constrain(to: eventDetailContainer, topInset: 25, trailingInset: 0, leadingInset: 0)
        upperContainerView.constrain(height: 95)
    }
    func setupTitle() {
        upperContainerView.addSubview(titleLabel)
        titleLabel.leadingAnchor.constraint(equalTo: closeButton.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12).isActive = true
        titleLabel.topAnchor.constraint(equalTo: upperContainerView.topAnchor).isActive = true
    }
    func setupTime() {
        upperContainerView.addSubview(timeImageView)
        timeImageView.translatesAutoresizingMaskIntoConstraints = false
        timeImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        timeImageView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true

        upperContainerView.addSubview(timeLabel)
        timeLabel.centerYAnchor.constraint(equalTo: timeImageView.centerYAnchor).isActive = true
        timeLabel.leadingAnchor.constraint(equalTo: timeImageView.leadingAnchor, constant: 20).isActive = true
    }
    func setupDescription() {
        eventDetailContainer.addSubview(descriptionLabel)
        descriptionLabel.topAnchor.constraint(equalTo: locationImageView.bottomAnchor, constant: 30).isActive = true
        descriptionLabel.constrain(to: eventDetailContainer, trailingInset: 0)
        descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        descriptionLabelHeight = descriptionLabel.heightAnchor.constraint(equalToConstant: 100)
        descriptionLabelHeight.isActive = true
    }
    func setupLocation() {
        upperContainerView.addSubview(locationImageView)
        locationImageView.translatesAutoresizingMaskIntoConstraints = false
        locationImageView.topAnchor.constraint(equalTo: timeImageView.bottomAnchor, constant: 10).isActive = true
        locationImageView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 2).isActive = true
        upperContainerView.addSubview(locationLabel)
        locationLabel.centerYAnchor.constraint(equalTo: locationImageView.centerYAnchor).isActive = true
        locationLabel.leadingAnchor.constraint(equalTo: locationImageView.leadingAnchor, constant: 18).isActive = true
    }
    func setupCloseButton() {
        view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(didSelectCloseButton(_:)), for: .touchUpInside)
        closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 12).isActive = true
        closeButton.constrain(height: 20)
    }
}

// MARK: - UINavigationItem Setup
extension HIShiftDetailViewController {
    @objc dynamic override func setupNavigationItem() {
        super.setupNavigationItem()
        title = "STAFF SHIFT DETAILS"
    }
}

// MARK: - UIImageView Setup
extension HIShiftDetailViewController {
    @objc dynamic override func setUpBackgroundView() {
        view.layer.backgroundColor = #colorLiteral(red: 1, green: 0.9803921569, blue: 0.8, alpha: 1)
    }
}
