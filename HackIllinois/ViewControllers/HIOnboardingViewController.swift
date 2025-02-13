//
//  HIOnboardingViewController.swift
//  HackIllinois
//
//  Created by HackIllinois Team on 11/24/21.
//  Copyright © 2021 HackIllinois. All rights reserved.
//  This file is part of the Hackillinois iOS App.
//  The Hackillinois iOS App is open source software, released under the University of
//  Illinois/NCSA Open Source License. You should have received a copy of
//  this license in a file with the distribution.
//

import Foundation
import UIKit
import Lottie

class HIOnboardingViewController: HIBaseViewController {
    //source: https://medium.com/swlh/swift-carousel-759800aa2952
    // MARK: - Subviews
    private var carouselView: HICarouselView?
    let animationView = LottieAnimationView(name: "DarkVespaText")
    var shouldDisplayAnimationOnNextAppearance = true

    // MARK: - Properties
    private var carouselData = [HICarouselView.CarouselData]()
    let getStartedButton = HIButton {
        $0.layer.cornerRadius = 25
        $0.titleLabel?.font = HIAppearance.Font.onboardingGetStartedText
        $0.backgroundHIColor = \.buttonViewBackground
        $0.titleHIColor = \.whiteText
        $0.title = "Get Started"
        
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
            $0.configuration = config
        } else {
            $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        }
    }
    @objc dynamic override func setUpBackgroundView() {
        super.setUpBackgroundView()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            backgroundView.image = UIImage(named: "LoginBackgroundPadNew")
        } else {
            backgroundView.image = #imageLiteral(resourceName: "Login")
        }
    }
}

extension HIOnboardingViewController {
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        carouselView = HICarouselView(pages: 6)
        if UIDevice.current.userInterfaceIdiom == .pad {
            carouselData.append(.init(image: #imageLiteral(resourceName: "Onboarding0"), titleText: "Welcome", descriptionText: "Swipe to see what our app has to offer!"))
            carouselData.append(.init(image: UIImage(named: "iPadOnboarding1"), titleText: "Countdown", descriptionText: "See how much time you have left to hack!"))
            carouselData.append(.init(image: UIImage(named: "iPadOnboarding2"), titleText: "Schedule", descriptionText: "See the times and details of all of our events."))
            carouselData.append(.init(image: UIImage(named: "iPadOnboarding3"), titleText: "Scanner", descriptionText: "Scan QR codes to obtain points and redeem items from the point shop."))
            carouselData.append(.init(image: UIImage(named: "iPadOnboarding4"), titleText: "Profile", descriptionText: "View your QR code, food wave, and other personal information."))
            carouselData.append(.init(image: UIImage(named: "iPadOnboarding5"), titleText: "Point Shop", descriptionText: "View the available prizes you can redeem using your earned coins!"))
        } else {
            carouselData.append(.init(image: #imageLiteral(resourceName: "Onboarding0"), titleText: "Welcome", descriptionText: "Swipe to see what our app has to offer!"))
            carouselData.append(.init(image: UIImage(named: "Onboarding1"), titleText: "Countdown", descriptionText: "See how much time you have left to hack!"))
            carouselData.append(.init(image: UIImage(named: "Onboarding2"), titleText: "Schedule", descriptionText: "See the times and details of all of our events."))
            carouselData.append(.init(image: UIImage(named: "Onboarding3"), titleText: "Scanner", descriptionText: "Scan QR codes to obtain points and redeem items from the point shop."))
            carouselData.append(.init(image: UIImage(named: "Onboarding4"), titleText: "Profile", descriptionText: "View your QR code, food wave, and other personal information."))
            carouselData.append(.init(image: UIImage(named: "Onboarding5"), titleText: "Point Shop", descriptionText: "View the available prizes you can redeem using your earned coins!"))
        }
        setupUI()
        let viewAlphaValue = shouldDisplayAnimationOnNextAppearance ? 0.0 : 1.0

        carouselView?.alpha = CGFloat(viewAlphaValue)
//        getStartedButton.alpha = CGFloat(viewAlphaValue)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if shouldDisplayAnimationOnNextAppearance {
            animationView.contentMode = .scaleAspectFit
            animationView.frame = view.frame
            animationView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(animationView)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        carouselView?.configureView(with: carouselData)
        if shouldDisplayAnimationOnNextAppearance {
            setNeedsStatusBarAppearanceUpdate()

            animationView.play { _ in
                // Smooth out background transition into login page
                UIView.animate(withDuration: 1.0, animations: {self.animationView.alpha = 0.0; self.carouselView?.alpha = 1.0},
                completion: { _ in
                    self.animationView.removeFromSuperview()
                })
                UIView.animate(withDuration: 0.25) { () -> Void in
                    self.setNeedsStatusBarAppearanceUpdate()
                }
            }
            shouldDisplayAnimationOnNextAppearance = false
        }
    }
}

// MARK: - Setups

private extension HIOnboardingViewController {
    func setupUI() {
//        getStartedButton.addTarget(self, action: #selector(didSelectGetStarted(_:)), for: .touchUpInside)
//        view.addSubview(getStartedButton)
//        getStartedButton.translatesAutoresizingMaskIntoConstraints = false
//        getStartedButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
//        getStartedButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        getStartedButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6).isActive = true
//        getStartedButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        guard let carouselView = carouselView else { return }
        view.addSubview(carouselView)
        carouselView.translatesAutoresizingMaskIntoConstraints = false
        carouselView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        carouselView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        carouselView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
//        carouselView.bottomAnchor.constraint(equalTo: getStartedButton.topAnchor).isActive = true
    }
}

extension HIOnboardingViewController {
    @objc func didSelectGetStarted(_ sender: HIButton) {
        NotificationCenter.default.post(name: .getStarted, object: nil)
    }
}
