//
//  HIProfileViewController.swift
//  HackIllinois
//
//  Created by HackIllinois Team on 2/24/21.
//  Copyright © 2021 HackIllinois. All rights reserved.
//  This file is part of the Hackillinois iOS App.
//  The Hackillinois iOS App is open source software, released under the University of
//  Illinois/NCSA Open Source License. You should have received a copy of
//  this license in a file with the distribution.
//

import Foundation
import UIKit
import CoreData
import HIAPI
import CoreImage.CIFilterBuiltins
import SwiftUI

class HIProfileViewController: HIBaseViewController {
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    // MARK: - Properties
    private var profile = HIProfile()
    private var profileTier = ""
    private var addedProfileCard = false
    private var dietaryRestrictions = [String]()
    private var profileCardController: UIHostingController<HIProfileCardView>?
    private let errorView = HIErrorView(style: .profile)
    private let logoutButton = HIButton {
        $0.tintHIColor = \.baseText
        $0.backgroundHIColor = \.clear
        $0.baseImage = #imageLiteral(resourceName: "LogoutButton")
    }

    @objc dynamic override func setUpBackgroundView() {
        super.setUpBackgroundView()
        backgroundView.image = #imageLiteral(resourceName: "ScheduleBackground")
    }
    private var tiers: [Tier] = []
    private var ranking: Int = 0
    private var role: String = ""
}

// MARK: - UITabBarItem Setup
extension HIProfileViewController {
    override func setupTabBarItem() {
        tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "profile"), selectedImage: #imageLiteral(resourceName: "ProfileSelected"))
    }
}

// MARK: - UIViewController
extension HIProfileViewController {

    override func loadView() {
        super.loadView()
        guard let user = HIApplicationStateController.shared.user else { return }
        if HIApplicationStateController.shared.isGuest || user.roles.contains(.STAFF) {
            layoutErrorView()
        } else {
            updateProfile()
            reloadProfile()
            NotificationCenter.default.addObserver(self, selector: #selector(updateOnCheckin), name: .qrCodeSuccessfulScan, object: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        super.setCustomTitle(customTitle: "PROFILE")
    }

    func updateProfileCard() {
        if addedProfileCard == true {
            profileCardController?.view.removeFromSuperview()
            view.willRemoveSubview(profileCardController!.view)
            profileCardController?.removeFromParent()
        }
//        var rank: Int = 0
//        guard let user = HIApplicationStateController.shared.user else { return }
//        HIAPI.ProfileService.getUserRanking(userToken: user.token)
//            .onCompletion { [weak self] result in
//                do {
//                    let (userRanking, _) = try result.get()
//                    self?.ranking = userRanking.ranking
//                    rank = userRanking.ranking
//                } catch {
//                    print("An error has occurred in ranking \(error)")
//                }
//            }
//            .launch()
//        print("rank \(rank)")
        guard let user = HIApplicationStateController.shared.user else { return }
        var role = "General"
        if user.roles.contains(.PRO) {
            role = "Knight"
        }
        profileCardController = UIHostingController(rootView: HIProfileCardView(displayName: profile.displayName,
                                                                                points: profile.points,
                                                                                tier: profileTier,
                                                                                foodWave: profile.foodWave,
                                                                                avatarUrl: profile.avatarUrl,
                                                                                userId: profile.userId,
                                                                                role: role
                                                                               ))

        addChild(profileCardController!)
        profileCardController!.view.backgroundColor = .clear
        profileCardController!.view.frame = view.bounds
        view.addSubview(profileCardController!.view)
        addedProfileCard = true
    }

    func layoutErrorView() {
        errorView.delegate = self
        view.addSubview(errorView)
        errorView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        errorView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        errorView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        errorView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }

    func layoutLogOutButton() {
        self.navigationItem.rightBarButtonItem = logoutButton.toBarButtonItem()
        logoutButton.constrain(width: 25, height: 25)
        logoutButton.addTarget(self, action: #selector(didSelectLogoutButton(_:)), for: .touchUpInside)
    }

    @objc func updateOnCheckin(_ notification: Notification) {
        guard let user = HIApplicationStateController.shared.user else { return }
        if !HIApplicationStateController.shared.isGuest && !user.roles.contains(.STAFF) {
            reloadProfile()
        }
    }

    func updateProfile() {
        updateProfileCard()
        if tiers.count > 0 {
            var max_threshold = 0
            for tier in tiers where (profile.points >= tier.threshold && tier.threshold >= max_threshold) {
                profileTier = "\(tier.name.capitalized) Tier"
                max_threshold = tier.threshold
            }
        } else {
            profileTier = "Tier: None"
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let user = HIApplicationStateController.shared.user else { return }
        layoutLogOutButton()
        if !HIApplicationStateController.shared.isGuest && !user.roles.contains(.STAFF) {
            reloadProfile()
        }
    }
}

// MARK: - Actions
extension HIProfileViewController {
    @objc func didSelectLogoutButton(_ sender: UIButton) {
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

// MARK: - API
extension HIProfileViewController {
    @objc func reloadProfile () {
        guard let user = HIApplicationStateController.shared.user else { return }
        HIAPI.ProfileService.getUserProfile(userToken: user.token)
        .onCompletion { [weak self] result in
            do {
                let (apiProfile, _) = try result.get()
                print(apiProfile)
                self?.profile.userId = apiProfile.userId
                self?.profile.displayName = apiProfile.displayName
                self?.profile.points = apiProfile.points
                self?.profile.avatarUrl = apiProfile.avatarUrl
                self?.profile.foodWave = apiProfile.foodWave
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .loginProfile, object: nil, userInfo: ["profile": self?.profile])
                    self?.updateProfile()
                }
            } catch {
                print("Failed to reload profile with the error: \(error)")
            }
        }
        .authorize(with: user)
        .launch()
        HIAPI.ProfileService.getTiers()
            .onCompletion { [weak self] result in
                do {
                    let (tiersList, _) = try result.get()
                    self?.tiers = tiersList.tiers
                    DispatchQueue.main.async {
                        self?.updateProfile()
                    }
                } catch {
                    print("An error has occurred \(error)")
                }
            }
            .launch()
        HIAPI.ProfileService.getUserRanking(userToken: user.token)
            .onCompletion { [weak self] result in
                do {
                    let (userRanking, _) = try result.get()
                    self?.ranking = userRanking.ranking
                    print(userRanking.ranking)
                    DispatchQueue.main.async {
                        self?.updateProfile()
                    }
                } catch {
                    print("An error has occurred in ranking \(error)")
                }
            }
            .launch()

        HIAPI.RegistrationService.getAttendee()
            .onCompletion { [weak self] result in
                do {
                    let (apiAttendeeContainer, _) = try result.get()
                    self?.dietaryRestrictions = apiAttendeeContainer.attendee.dietary ?? []
                    DispatchQueue.main.async {
                        self?.updateProfile()
                    }
                } catch {
                    print("An error has occurred \(error)")
                }
            }
            .authorize(with: user)
            .launch()
    }
}

// MARK: - HIErrorViewDelegate
extension HIProfileViewController: HIErrorViewDelegate {
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
