//
//  HIQRAttendeeScannerSelection.swift
//  HackIllinois
//
//  Created by HackIllinois on 1/12/24.
//  Copyright © 2024 HackIllinois. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit
import HIAPI

class HIQRAttendeeScannerSelection: HIBaseViewController {
    private let backgroundHIColor: HIColor = \.clear
    private let containerView = HIView {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundHIColor = \.baseBackground
    }
    private let errorView = HIErrorView(style: .codePopup)
    private let closeButton = HIButton {
        $0.tintHIColor = \.action
        $0.backgroundHIColor = \.clear
        $0.activeImage = #imageLiteral(resourceName: "CloseButton")
        $0.baseImage = #imageLiteral(resourceName: "CloseButton")
    }
    private let previewView = HIView {
        $0.backgroundHIColor = \.baseBackground
    }
    private let label = HILabel {
        $0.textHIColor = \.whiteText
        $0.backgroundHIColor = \.clear
        $0.textAlignment = .center
        $0.font = HIAppearance.Font.glyph
    }
    private let eventCheckInButton = HIButton {
        $0.tintHIColor = \.action
        $0.backgroundHIColor = \.scannerButtonPink
        $0.layer.borderWidth = 4.0
        $0.layer.borderColor = #colorLiteral(red: 0.4588235294, green: 0.1960784314, blue: 0.07843137255, alpha: 1)
        // 3D Effect
        $0.layer.masksToBounds = false
        $0.layer.shadowColor = #colorLiteral(red: 0.337254902, green: 0.1411764706, blue: 0.06666666667, alpha: 1)
        $0.layer.shadowOpacity = 1
        $0.layer.shadowOffset = CGSize(width: 0, height: 12)
        $0.layer.shadowRadius = 0
    }
    private let mentorCheckInButton = HIButton {
        $0.tintHIColor = \.action
        $0.backgroundHIColor = \.scannerButtonTeal
        $0.layer.borderWidth = 4.0
        $0.layer.borderColor = #colorLiteral(red: 0.4588235294, green: 0.1960784314, blue: 0.07843137255, alpha: 1)
        // 3D Effect
        $0.layer.masksToBounds = false
        $0.layer.shadowColor = #colorLiteral(red: 0.337254902, green: 0.1411764706, blue: 0.06666666667, alpha: 1)
        $0.layer.shadowOpacity = 1
        $0.layer.shadowOffset = CGSize(width: 0, height: 12)
        $0.layer.shadowRadius = 0
    }
    private let pointShopScanButton = HIButton {
        $0.tintHIColor = \.action
        $0.backgroundHIColor = \.scannerButtonYellow
        $0.layer.borderWidth = 4.0
        $0.layer.borderColor = #colorLiteral(red: 0.4588235294, green: 0.1960784314, blue: 0.07843137255, alpha: 1)
        // 3D Effect
        $0.layer.masksToBounds = false
        $0.layer.shadowColor = #colorLiteral(red: 0.337254902, green: 0.1411764706, blue: 0.06666666667, alpha: 1)
        $0.layer.shadowOpacity = 1
        $0.layer.shadowOffset = CGSize(width: 0, height: 10)
        $0.layer.shadowRadius = 0
    }
    @objc dynamic override func setUpBackgroundView() {
        super.setUpBackgroundView()
        if UIDevice.current.userInterfaceIdiom == .pad {
            backgroundView.image = UIImage(named: "BackgroundPad")
        } else {
            backgroundView.image = #imageLiteral(resourceName: "scanner-menu")
        }
    }
}

// MARK: - UIViewController
extension HIQRAttendeeScannerSelection {
    override func loadView() {
        super.loadView()
        guard let user = HIApplicationStateController.shared.user else { return }
        if HIApplicationStateController.shared.isGuest && !user.roles.contains(.STAFF) { // Guest
            // Guest handler
            let background = #imageLiteral(resourceName: "PurpleBackground")
            let imageView: UIImageView = UIImageView(frame: view.bounds)
            view.addSubview(imageView)
            view.sendSubviewToBack(imageView)
            layoutErrorView()
        } else if !user.roles.contains(.STAFF) {
            view.addSubview(eventCheckInButton)
            view.addSubview(mentorCheckInButton)
            view.addSubview(pointShopScanButton)
            view.addSubview(closeButton)
            view.addSubview(label)

            // Add constraints for meetingButton and attendeeButton here
            eventCheckInButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 140).isActive = true
            eventCheckInButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            eventCheckInButton.addTarget(self, action: #selector(didSelectEventCheckInButton(_:)), for: .touchUpInside)
            eventCheckInButton.layer.cornerRadius = (UIDevice.current.userInterfaceIdiom == .pad) ? 30 : 15
            eventCheckInButton.constrain(width: (UIDevice.current.userInterfaceIdiom == .pad) ? 500 : 290, height: (UIDevice.current.userInterfaceIdiom == .pad) ? 150 : 80)
            eventCheckInButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true

            mentorCheckInButton.topAnchor.constraint(equalTo: eventCheckInButton.bottomAnchor, constant: (UIDevice.current.userInterfaceIdiom == .pad) ? 100 : 50).isActive = true
            mentorCheckInButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            mentorCheckInButton.addTarget(self, action: #selector(didSelectMentorCheckInButton(_:)), for: .touchUpInside)
            mentorCheckInButton.layer.cornerRadius = (UIDevice.current.userInterfaceIdiom == .pad) ? 30 : 15
            mentorCheckInButton.constrain(width: (UIDevice.current.userInterfaceIdiom == .pad) ? 500 : 290, height: (UIDevice.current.userInterfaceIdiom == .pad) ? 150 : 80)

            pointShopScanButton.topAnchor.constraint(equalTo: mentorCheckInButton.bottomAnchor, constant: (UIDevice.current.userInterfaceIdiom == .pad) ? 100 : 50).isActive = true
            pointShopScanButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            pointShopScanButton.addTarget(self, action: #selector(didSelectPointsShopButton(_:)), for: .touchUpInside)
            pointShopScanButton.layer.cornerRadius = (UIDevice.current.userInterfaceIdiom == .pad) ? 30 : 15
            pointShopScanButton.constrain(width: (UIDevice.current.userInterfaceIdiom == .pad) ? 500 : 290, height: (UIDevice.current.userInterfaceIdiom == .pad) ? 150 : 80)

            let eventCheckInLabel = HILabel(style: .QRSelection)
            eventCheckInLabel.text = "Event Check In"
            eventCheckInButton.addSubview(eventCheckInLabel)
            eventCheckInLabel.centerYAnchor.constraint(equalTo: eventCheckInButton.centerYAnchor).isActive = true
            eventCheckInLabel.centerXAnchor.constraint(equalTo: eventCheckInButton.centerXAnchor).isActive = true

            let mentorCheckInLabel = HILabel(style: .QRSelection)
            mentorCheckInLabel.text = "Mentor Check In"
            mentorCheckInButton.addSubview(mentorCheckInLabel)
            mentorCheckInLabel.centerYAnchor.constraint(equalTo: mentorCheckInButton.centerYAnchor).isActive = true
            mentorCheckInLabel.centerXAnchor.constraint(equalTo: mentorCheckInButton.centerXAnchor).isActive = true

            let pointsShopLabel = HILabel(style: .QRSelection)
            pointsShopLabel.text = "Points Shop"
            pointShopScanButton.addSubview(pointsShopLabel)
            pointsShopLabel.centerYAnchor.constraint(equalTo: pointShopScanButton.centerYAnchor).isActive = true
            pointsShopLabel.centerXAnchor.constraint(equalTo: pointShopScanButton.centerXAnchor).isActive = true
        }
        closeButton.addTarget(self, action: #selector(didSelectCloseButton(_:)), for: .touchUpInside)
        closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
        closeButton.constrain(width: 60, height: 60)
        closeButton.imageView?.contentMode = .scaleToFill
        let label = HILabel(style: .viewTitle)
        label.text = "SCANNER"
        view.addSubview(label)
        label.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: closeButton.trailingAnchor, constant: 3).isActive = true
    }
    override func viewDidLoad() {
        setCustomTitle(customTitle: "SCANNER")
        super.viewDidLoad()
    }
    func layoutErrorView() {
        errorView.delegate = self
        view.addSubview(errorView)
        errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        errorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        errorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        errorView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        errorView.addSubview(closeButton)
    }
}

// MARK: - HIErrorViewDelegate
extension HIQRAttendeeScannerSelection: HIErrorViewDelegate {
    func didSelectErrorLogout(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(
            UIAlertAction(title: "Log Out", style: .destructive) { _ in
                self.dismiss(animated: true, completion: nil)
                NotificationCenter.default.post(name: .logoutUser, object: nil)
            }
        )
        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        )
        alert.popoverPresentationController?.sourceView = sender
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Actions
extension HIQRAttendeeScannerSelection {
    @objc func didSelectCloseButton(_ sender: HIButton) {
        self.dismiss(animated: true, completion: nil)
        let scanQRCodePopup = HIQRAttendeeScannerSelection()
        scanQRCodePopup.modalPresentationStyle = .overFullScreen
        scanQRCodePopup.modalTransitionStyle = .crossDissolve
        self.present(scanQRCodePopup, animated: true, completion: nil)
    }
}

extension HIQRAttendeeScannerSelection {
    @objc func didSelectEventCheckInButton(_ sender: HIButton) {
        let scanQRCodePopup = HIScanQRCodeViewController()
        scanQRCodePopup.modalPresentationStyle = .overFullScreen
        scanQRCodePopup.modalTransitionStyle = .crossDissolve
        self.present(scanQRCodePopup, animated: true, completion: nil)
    }
}

extension HIQRAttendeeScannerSelection {
    @objc func didSelectMentorCheckInButton(_ sender: HIButton) {
        let scanQRCodePopup = HIScanMentorViewController()
        scanQRCodePopup.modalPresentationStyle = .overFullScreen
        scanQRCodePopup.modalTransitionStyle = .crossDissolve
        self.present(scanQRCodePopup, animated: true, completion: nil)
    }
}

extension HIQRAttendeeScannerSelection {
    @objc func didSelectPointsShopButton(_ sender: HIButton) {
        let scanQRCodePopup = HIScanPointsShopViewController()
        scanQRCodePopup.modalPresentationStyle = .overFullScreen
        scanQRCodePopup.modalTransitionStyle = .crossDissolve
        self.present(scanQRCodePopup, animated: true, completion: nil)
    }
}
