
//
//  HITabBarController.swift
//  HackIllinois
//
//  Created by HackIllinois Team on 1/21/18.
//  Copyright © 2020 HackIllinois. All rights reserved.
//  This file is part of the Hackillinois iOS App.
//  The Hackillinois iOS App is open source software, released under the University of
//  Illinois/NCSA Open Source License. You should have received a copy of
//  this license in a file with the distribution.
//

import Foundation
import UIKit
import SwiftUI

class HITabBarController: UITabBarController {
    private var tabBarShapeLayer: CAShapeLayer?

    // Animation for when a tab bar item is clicked
    private var bounceAnimation: CAKeyframeAnimation = {
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0, 1.4, 0.9, 1.02, 1.0]
        bounceAnimation.duration = TimeInterval(0.3)
        bounceAnimation.calculationMode = CAAnimationCalculationMode.cubic
        return bounceAnimation
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupQRScanButton()
        setupTabBar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        //Redefine the tab bar path when orientation rotated
        if let tabBarShapeLayer = tabBarShapeLayer {
            tabBarShapeLayer.path = createPath()
        }
    }

    @objc private func qrScannerPopupButtonPressed(_ sender: UIButton) {
        guard let user = HIApplicationStateController.shared.user else { return }
        if user.roles.contains(.ATTENDEE) && !user.roles.contains(.STAFF) {
            let scanQRCodePopup = HIQRAttendeeScannerSelection()
            scanQRCodePopup.modalPresentationStyle = .overFullScreen
            scanQRCodePopup.modalTransitionStyle = .crossDissolve
            self.present(scanQRCodePopup, animated: true, completion: nil)
        } else if user.roles.contains(.STAFF) {
            let scanQRCodePopup = HIQRScannerSelection()
            scanQRCodePopup.modalPresentationStyle = .overFullScreen
            scanQRCodePopup.modalTransitionStyle = .crossDissolve
            self.present(scanQRCodePopup, animated: true, completion: nil)
        } else if HIApplicationStateController.shared.isGuest {
            let scanQRCodePopup = HIScanQRCodeViewController()
            scanQRCodePopup.modalPresentationStyle = .overFullScreen
            scanQRCodePopup.modalTransitionStyle = .crossDissolve
            self.present(scanQRCodePopup, animated: true, completion: nil)
        }
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        moreNavigationController.tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "DisclosureIndicator"), tag: 0)
    }

    func setupQRScanButton() {
        //Setup QR Scanner Popup Button
        let qrScannerPopupButton = UIButton()
        view.addSubview(qrScannerPopupButton)
        qrScannerPopupButton.translatesAutoresizingMaskIntoConstraints = false
        qrScannerPopupButton.frame.size = CGSize(width: 75, height: 75)
        qrScannerPopupButton.layer.cornerRadius = 38
        qrScannerPopupButton.center = CGPoint(x: view.center.x, y: 0)
        if self.selectedViewController is HIQRScannerSelection {
            qrScannerPopupButton.backgroundColor = (\HIAppearance.greenCodePopupTab).value
        } else {
            qrScannerPopupButton.backgroundColor = (\HIAppearance.codePopupTab).value
        }
        qrScannerPopupButton.setImage(#imageLiteral(resourceName: "QRScannerPopupTabIcon"), for: .normal)
        qrScannerPopupButton.imageView?.contentMode = .scaleAspectFill

        // Button Shadow
        qrScannerPopupButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.45).cgColor
        qrScannerPopupButton.layer.shadowOpacity = 1
        qrScannerPopupButton.layer.shadowRadius = 20
        qrScannerPopupButton.layer.masksToBounds = false
        qrScannerPopupButton.layer.shadowOffset = CGSize(width: 0, height: 0)

        //QR Scanner PopupButton Constraints
        qrScannerPopupButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        qrScannerPopupButton.centerYAnchor.constraint(equalTo: tabBar.topAnchor, constant: 0).isActive = true
        qrScannerPopupButton.constrain(width: 75, height: 75)

        //QR Scanner PopupAction
        qrScannerPopupButton.addTarget(self, action: #selector(qrScannerPopupButtonPressed(_:)), for: .touchUpInside)
    }

    func setupTabBar() {
        let tabBarFrame = self.tabBar.frame
        tabBar.frame = CGRect(x: tabBarFrame.minX, y: tabBarFrame.minY, width: tabBarFrame.width, height: UIScreen.main.bounds.height - tabBarFrame.height + 28)
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.clipsToBounds = true
        tabBar.layer.borderWidth = 0
        tabBar.backgroundColor = UIColor.clear
        tabBar.unselectedItemTintColor = (\HIAppearance.navbarTabTint).value
        tabBar.tintColor = (\HIAppearance.navbarTabTint).value
        addTabBarShape()
    }

    func addTabBarShape() {
        tabBarShapeLayer = CAShapeLayer()
        if let tabBarShapeLayer = tabBarShapeLayer {
            tabBarShapeLayer.path = createPath()
            tabBarShapeLayer.fillColor = (\HIAppearance.navbarBackground).value.cgColor
            tabBarShapeLayer.lineWidth = 1.0

            self.tabBar.layer.insertSublayer(tabBarShapeLayer, at: 0)
        }
    }

    func createPath() -> CGPath {
        let radius: CGFloat = 43.0
        let smallRadius: CGFloat = 8.0
        let path = UIBezierPath()

        // start top left before rounded corner
        path.move(to: CGPoint(x: 0, y: 0 + smallRadius))

        // top left rounded corner
        path.addArc(withCenter: CGPoint(x: smallRadius, y: smallRadius),
                    radius: smallRadius,
                    startAngle: .pi,
                    endAngle: 3 * .pi / 2,
                    clockwise: true)

        // start of left arc before middle arc
        path.addLine(to: CGPoint(x: (self.tabBar.frame.width/2 - radius - smallRadius/2), y: 0))

        // end of left arc before middle arc
        path.addArc(withCenter: CGPoint(x: self.tabBar.frame.width/2 - radius - smallRadius/2, y: smallRadius/2),
                    radius: smallRadius/2,
                    startAngle: 3 * .pi / 2,
                    endAngle: 0,
                    clockwise: true)

        // middle arc
        path.addArc(withCenter: CGPoint(x: self.tabBar.frame.width/2, y: 0),
                    radius: radius,
                    startAngle: .pi,
                    endAngle: 0,
                    clockwise: false)

        // right arc after middle arc
        path.addArc(withCenter: CGPoint(x: self.tabBar.frame.width/2 + radius + smallRadius/2, y: smallRadius/2),
                    radius: smallRadius/2,
                    startAngle: .pi,
                    endAngle: 3 * .pi / 2,
                    clockwise: true)

        // before top right rounded corner
        path.addLine(to: CGPoint(x: self.tabBar.frame.width - smallRadius, y: 0))

        // top right rounded corner
        path.addArc(withCenter: CGPoint(x: self.tabBar.frame.width - smallRadius, y: smallRadius),
                    radius: smallRadius,
                    startAngle: 3 * .pi / 2,
                    endAngle: 0,
                    clockwise: true)

        // finish the rest
        path.addLine(to: CGPoint(x: self.tabBar.frame.width, y: UIScreen.main.bounds.height))
        path.addLine(to: CGPoint(x: 0, y: UIScreen.main.bounds.height))
        path.close()

        return path.cgPath
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupMenuFor(_ viewControllers: [UIViewController]) {
        self.viewControllers = viewControllers.map {
            _ = $0.view // forces viewDidLoad to run, allows .title to be accessible
            return HINavigationController(rootViewController: $0)
        }
    }
}



