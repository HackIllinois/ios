//
//  HICountdownViewController.swift
//  HackIllinois
//
//  Created by HackIllinois Team on 1/20/18.
//  Copyright © 2018 HackIllinois. All rights reserved.
//  This file is part of the Hackillinois iOS App.
//  The Hackillinois iOS App is open source software, released under the University of
//  Illinois/NCSA Open Source License. You should have received a copy of
//  this license in a file with the distribution.
//

import Foundation
import UIKit
import SwiftUI
import Lottie

protocol HICountdownViewControllerDelegate: AnyObject {
    func countdownToDateFor(countdownViewController: HICountdownViewController) -> Date?
}

class HICountdownViewController: UIViewController {

    // MARK: - Constants
    private let FRAMES_PER_TICK = 8
    private let customCountdownBackground = UIColor(red: 224/255, green: 198/255, blue: 159/255, alpha: 1.0)  // #E0C69F


    // MARK: - Properties
    private let days = HILabel(style: .newCountdown)
    private let hours = HILabel(style: .newCountdown)
    private let minutes = HILabel(style: .newCountdown)
    private let seconds = HILabel(style: .newCountdown)
    private let backgroundHIColor: HIColor = \.clear
    private let countdownBackground: HIColor = \.countdownBackground

    private var countdownDate: Date?
    private var dayFrame = 0
    private var hourFrame = 0
    private var minuteFrame = 0
    private var secondFrame = 0
    private var timer: Timer?

    private var timeDifference: TimeInterval = 0.0
    private var daysRemaining: Int { return max(0, Int(timeDifference / Date.DAY_IN_SECONDS) % 365) }
    private var hoursRemaining: Int { return max(0, Int(timeDifference / Date.HOUR_IN_SECONDS) % 24) }
    private var minutesRemaining: Int { return max(0, Int(timeDifference / Date.MINUTE_IN_SECONDS) % 60) }
    private var secondsRemaining: Int { return max(0, Int(timeDifference) % 60) }

    weak var delegate: HICountdownViewControllerDelegate?

    // MARK: - Init
    convenience init(delegate: HICountdownViewControllerDelegate) {
        self.init(nibName: nil, bundle: nil)
        self.delegate = delegate
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshForThemeChange), name: .themeDidChange, object: nil)
        refreshForThemeChange()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) should not be used")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private let countdownFillColor: HIColor = \.baseText
    private var countdownFillColorCallback: ColorValueProvider?

    // MARK: - Themeable
    @objc func refreshForThemeChange() {
        days.backgroundColor <- backgroundHIColor
        hours.backgroundColor <- backgroundHIColor
        minutes.backgroundColor <- backgroundHIColor
        seconds.backgroundColor <- backgroundHIColor
        let countdownFillColorCallback = ColorValueProvider { _ in self.countdownFillColor.value.lottieColorValue }
        self.countdownFillColorCallback = countdownFillColorCallback
    }
}

// MARK: - UIViewController
extension HICountdownViewController {
    override func loadView() {
        view = HIView { $0.backgroundHIColor = \.clear }

        days.contentMode = .scaleAspectFit
        hours.contentMode = .scaleAspectFit
        minutes.contentMode = .scaleAspectFit
        seconds.contentMode = .scaleAspectFit

        let countdownStackView = UIStackView()
        countdownStackView.distribution = .fillEqually
        
        countdownStackView.spacing = 12
        
        countdownStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(countdownStackView)
        countdownStackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        countdownStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        countdownStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        countdownStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        let daysContent = containerView(with: daysRemaining == 1 ? "DAY" : "DAYS", and: days)
        countdownStackView.addArrangedSubview(daysContent)
        let hoursContent = containerView(with: hoursRemaining == 1 ? "HOUR" : "HOURS", and: hours)
        countdownStackView.addArrangedSubview(hoursContent)
        let minutesContent = containerView(with: minutesRemaining == 1 ? "MINUTE" : "MINUTES", and: minutes)
        countdownStackView.addArrangedSubview(minutesContent)
        var countdownSpacingConstant: CGFloat = 8
        if UIDevice.current.userInterfaceIdiom == .pad {
            countdownSpacingConstant = 16
        }
        countdownStackView.setCustomSpacing(countdownSpacingConstant, after: daysContent)
        countdownStackView.setCustomSpacing(countdownSpacingConstant, after: hoursContent)
        countdownStackView.setCustomSpacing(countdownSpacingConstant, after: minutesContent)
    }
    
    func containerView(with labelString: String, and countDownView: HILabel) -> UIView {
        let containerView = UIView()
        
        // Create background image view with combined asset
        let backgroundImageView = UIImageView(image: #imageLiteral(resourceName: "CountdownPillar"))
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.contentMode = .scaleToFill
        
        // Set up views
        countDownView.backgroundColor = .clear  // Since we're using image background
        countDownView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = HILabel {
            $0.textHIColor = \.countdownTextColor
            $0.backgroundHIColor = \.clear
            $0.textAlignment = .center
            if UIDevice.current.userInterfaceIdiom == .pad {
                $0.font = HIAppearance.Font.timeIndicator
            } else {
                $0.font = HIAppearance.Font.glyph
            }
            $0.text = labelString
        }
        
        // Add subviews
        containerView.addSubview(backgroundImageView)
        containerView.addSubview(countDownView)
        containerView.addSubview(label)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            
            containerView.heightAnchor.constraint(equalToConstant: 140),
            containerView.widthAnchor.constraint(equalToConstant: 90),
            
            // Background image constraints
            backgroundImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // CountDownView constraints
            countDownView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            countDownView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
            countDownView.bottomAnchor.constraint(equalTo: label.topAnchor, constant: 4),
            countDownView.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: -8),
            
            // Label constraints
            label.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: -8),
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        
        return containerView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tearDownCountdown()
    }
}

extension HICountdownViewController {
    func startUpCountdown() {
        countdownDate = delegate?.countdownToDateFor(countdownViewController: self)
        updateTimeDifference()
        setupCounters()
        let timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(updateCountdown),
            userInfo: nil,
            repeats: true
        )
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func setupCounters() {
        days.text = String(format: "%02d", (daysRemaining))
        hours.text = String(format: "%02d", (hoursRemaining))
        minutes.text = String(format: "%02d", (minutesRemaining))
        seconds.text = String(format: "%02d", (secondsRemaining))
        days.textAlignment = .center
        hours.textAlignment = .center
        minutes.textAlignment = .center
        seconds.textAlignment = .center
    }

    @objc func updateCountdown() {
        setupCounters()
        updateTimeDifference()
        guard timeDifference > 0 else {
            countdownDate = delegate?.countdownToDateFor(countdownViewController: self)
            return
        }
    }

    func updateTimeDifference() {
        timeDifference = countdownDate?.timeIntervalSince(Date()) ?? 0
    }

    func tearDownCountdown() {
        timer?.invalidate()
        timer = nil
    }
}
