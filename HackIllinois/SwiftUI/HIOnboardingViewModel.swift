//
//  HIOnboardingp.swift
//  HackIllinois
//
//  Created by HackIllinois Team on 10/30/22.
//  Copyright © 2022 HackIllinois. All rights reserved.
//  This file is part of the Hackillinois iOS App.
//  The Hackillinois iOS App is open source software, released under the University of
//  Illinois/NCSA Open Source License. You should have received a copy of
//  this license in a file with the distribution.
//

import SwiftUI

class HIOnboardingViewModel: ObservableObject {
    @Published var data: [CarouselData] = UIDevice.current.userInterfaceIdiom == .pad ? [
        CarouselData(image: #imageLiteral(resourceName: "Onboarding0"), titleText: "Welcome!", descriptionText: "Swipe to see what our app has to offer!"),
        CarouselData(image: UIImage(named: "iPadOnboarding1"), titleText: "Countdown", descriptionText: "See how much time you have left to hack!"),
        CarouselData(image: UIImage(named: "iPadOnboarding2"), titleText: "Schedule", descriptionText: "See the times and details of all of our events."),
        CarouselData(image: UIImage(named: "iPadOnboarding3"), titleText: "Scanner", descriptionText: "Scan QR codes to obtain points and redeem items from the point shop."),
        CarouselData(image: UIImage(named: "iPadOnboarding4"), titleText: "Profile", descriptionText: "View your QR code, food wave, and other personal information."),
        CarouselData(image: UIImage(named: "iPadOnboarding5"), titleText: "Point Shop", descriptionText: "View the available prizes you can redeem using your earned coins!")
    ] : [
        CarouselData(image: #imageLiteral(resourceName: "Onboarding0"), titleText: "Welcome", descriptionText: "Swipe to see what our app has to offer!"),
        CarouselData(image: UIImage(named: "Onboarding1"), titleText: "Overview", descriptionText: "View the hackathon’s major events and how much time is left to hack!"),
        CarouselData(image: UIImage(named: "Onboarding2"), titleText: "Schedule", descriptionText: "See the times and details of all of our events."),
        CarouselData(image: UIImage(named: "Onboarding3"), titleText: "Check-In", descriptionText: "Quickly scan QR code to check in to events and earn points!"),
        CarouselData(image: UIImage(named: "Onboarding4"), titleText: "Point Shop", descriptionText: "View the available prizes you can redeem using your earned coins!"),
        CarouselData(image: UIImage(named: "Onboarding5"), titleText: "Cart", descriptionText: "Modify your prize inventory before redemption."),
        CarouselData(image: UIImage(named: "Onboarding6"), titleText: "Scanner", descriptionText: "Scan QR codes and redeem items from the point shop."),
        CarouselData(image: UIImage(named: "Onboarding7"), titleText: "Profile", descriptionText: "View your QR code, food wave and other personal information.")
    ]
    @Published var shouldDisplayAnimationOnNextAppearance = true
}
