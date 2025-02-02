//
//  HIAppearance.swift
//  HackIllinois
//
//  Created by HackIllinois Team on 1/4/19.
//  Copyright © 2019 HackIllinois. All rights reserved.
//  This file is part of the Hackillinois iOS App.
//  The Hackillinois iOS App is open source software, released under the University of
//  Illinois/NCSA Open Source License. You should have received a copy of
//  this license in a file with the distribution.
//

import UIKit

struct HIAppearance: Equatable {
    let neonCountdownText: UIColor
    let titleText: UIColor
    let whiteText: UIColor
    let darkGreenText: UIColor
    let lightYellowText: UIColor
    let baseText: UIColor
    let accent: UIColor
    let viewTitleBrown: UIColor
    let action: UIColor
    let baseBackground: UIColor
    let contentBackground: UIColor
    let overlay: UIColor
    let frostedTint: UIColor
    let codePopupTab: UIColor
    let greenCodePopupTab: UIColor
    let navbarBackground: UIColor
    let navbarTabTint: UIColor
    let profileContainerTint: UIColor
    let preferredStatusBarStyle: UIStatusBarStyle
    let scrollViewIndicatorStyle: UIScrollView.IndicatorStyle
    let loginDefault: UIColor
    let loginTitleBackground: UIColor
    let loginLogo: UIImage
    let loginLogoPad: UIImage
    let loginSelectionText: UIColor
    let attendeeText: UIColor
    let attendeeBackground: UIColor
    let whiteTagFont: UIColor
    let interestBackground: UIColor
    let buttonGreen: UIColor
    let buttonBrown: UIColor
    let buttonLightPink: UIColor
    let buttonPurple: UIColor
    let buttonDarkBlue: UIColor
    let buttonMagenta: UIColor
    let buttonDarkBlueGreen: UIColor
    let buttonDarkGreen: UIColor
    let buttonOrange: UIColor
    let favoriteStarBackground: UIColor
    let segmentedBackground: UIColor
    let buttonYellow: UIColor
    let buttonViewBackground: UIColor
    let profile0: UIImage
    let profile1: UIImage
    let profile2: UIImage
    let profile3: UIImage
    let profile4: UIImage
    let profile5: UIImage
    let profile6: UIImage
    let profile7: UIImage
    let profile8: UIImage
    let profile9: UIImage
    let profile10: UIImage
    let leaderboardText: UIColor
    let leaderboardBackgroundOne: UIColor
    let leaderboardBackgroundTwo: UIColor
    let pointsBackground: UIColor
    let profileCardBackground: UIColor
    let profileCardVegetarian: UIColor
    let profileCardVegan: UIColor
    let profileCardGlutenFree: UIColor
    let profileCardLactoseIntolerant: UIColor
    let profileCardOther: UIColor
    let profileCardNone: UIColor
    let profileBaseText: UIColor
    let countdownTextColor: UIColor
    let countdownBackground: UIColor
    let bannerBackground: UIColor
    let scannerButtonPink: UIColor
    let scannerButtonTeal: UIColor
    let scannerButtonYellow: UIColor
    let scannerButtonBorder: UIColor
    let scannerButtonShadow: UIColor
    let proBackground: UIColor
    let eventCard: UIColor
    let clear: UIColor = .clear
    let black: UIColor = .black
    let white: UIColor = .white
    // Hack 2023 color palette
    private static let lightBlack = #colorLiteral(red: 0.03137254902, green: 0.08235294118, blue: 0.1058823529, alpha: 1); private static let yellowWhite = #colorLiteral(red: 0.9647058824, green: 0.9568627451, blue: 0.831372549, alpha: 1)
    private static let lightYellow = #colorLiteral(red: 0.9882352941, green: 0.862745098, blue: 0.5607843137, alpha: 1); private static let tan = #colorLiteral(red: 0.9098039216, green: 0.8431372549, blue: 0.6470588235, alpha: 1)
    private static let blue = #colorLiteral(red: 0.03137254902, green: 0.5450980392, blue: 0.7568627451, alpha: 1); private static let mediumOrange = #colorLiteral(red: 0.9764705882, green: 0.5843137255, blue: 0.3411764706, alpha: 1)
    private static let darkBlue = #colorLiteral(red: 0.05098039216, green: 0.2196078431, blue: 0.4862745098, alpha: 1); private static let magenta = #colorLiteral(red: 0.9960784314, green: 0.4392156863, blue: 0.5960784314, alpha: 1)
    private static let darkBlueGreen = #colorLiteral(red: 0.03137254902, green: 0.5450980392, blue: 0.7568627451, alpha: 1); private static let vegetarian = #colorLiteral(red: 0.2156862745, green: 0.8705882353, blue: 0.8039215686, alpha: 1)
    private static let vegan = #colorLiteral(red: 0.9882352941, green: 0.862745098, blue: 0.5607843137, alpha: 1); private static let glutenfree = #colorLiteral(red: 0.9764705882, green: 0.5843137255, blue: 0.3411764706, alpha: 1)
    private static let lactoseintolerant = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1); private static let other = #colorLiteral(red: 0.9960784314, green: 0.6392156863, blue: 0.6666666667, alpha: 1); private static let none = #colorLiteral(red: 0.1137254902, green: 0.1490196078, blue: 0.2666666667, alpha: 1)
    private static let profileBaseText = #colorLiteral(red: 0.1137254902, green: 0.1490196078, blue: 0.2666666667, alpha: 1); private static let yellowGreen = #colorLiteral(red: 0.7882352941, green: 0.8117647059, blue: 0.462745098, alpha: 1)
    private static let green = #colorLiteral(red: 0.4705882353, green: 0.6745098039, blue: 0.2588235294, alpha: 1)
    // Hack 2024 color palette
    private static let icyBlue = #colorLiteral(red: 0.8235294118, green: 0.968627451, blue: 1, alpha: 1); private static let bLightYellow = #colorLiteral(red: 1, green: 0.9803921569, blue: 0.8, alpha: 1)
    private static let bYellow = #colorLiteral(red: 1, green: 0.9568627451, blue: 0.5529411765, alpha: 1); private static let mediumYellow = #colorLiteral(red: 0.9607843137, green: 0.9176470588, blue: 0.5137254902, alpha: 1)
    private static let orange = #colorLiteral(red: 1, green: 0.6980392157, blue: 0.2431372549, alpha: 1); private static let darkOrange = #colorLiteral(red: 0.8705882353, green: 0.5568627451, blue: 0.2705882353, alpha: 1)
    private static let red = #colorLiteral(red: 0.6509803922, green: 0.1176470588, blue: 0, alpha: 1); private static let lightGreen = #colorLiteral(red: 0.7019607843, green: 0.8392156863, blue: 0.537254902, alpha: 1)
    private static let lightBlue = #colorLiteral(red: 0.7176470588, green: 0.8392156863, blue: 0.8392156863, alpha: 1); private static let teal = #colorLiteral(red: 0.537254902, green: 0.7450980392, blue: 0.6666666667, alpha: 1)
    private static let medTeal = #colorLiteral(red: 0.4274509804, green: 0.6117647059, blue: 0.6274509804, alpha: 1); private static let darkGreen = #colorLiteral(red: 0.05098039216, green: 0.2470588235, blue: 0.2549019608, alpha: 1)
    private static let darkestGreen = #colorLiteral(red: 0.02745098039, green: 0.1725490196, blue: 0.1803921569, alpha: 1); private static let lightBrown = #colorLiteral(red: 0.5882352941, green: 0.2980392157, blue: 0.1019607843, alpha: 1)
    private static let medBrown = #colorLiteral(red: 0.4588235294, green: 0.1960784314, blue: 0.07843137255, alpha: 1); private static let brown = #colorLiteral(red: 0.4, green: 0.168627451, blue: 0.07450980392, alpha: 1)
    private static let darkBrown = #colorLiteral(red: 0.337254902, green: 0.1411764706, blue: 0.06666666667, alpha: 1); private static let lightPink = #colorLiteral(red: 0.9215686275, green: 0.8235294118, blue: 0.8235294118, alpha: 1)
    private static let pink = #colorLiteral(red: 0.7921568627, green: 0.431372549, blue: 0.568627451, alpha: 1); private static let darkPink = #colorLiteral(red: 0.7882352941, green: 0.2039215686, blue: 0.3529411765, alpha: 1)
    private static let lightPurple = #colorLiteral(red: 0.662745098, green: 0.4666666667, blue: 0.6705882353, alpha: 1); private static let indigo = #colorLiteral(red: 0.3568627451, green: 0.3803921569, blue: 0.6078431373, alpha: 1)
    private static let darknavy = #colorLiteral(red: 0.1137254902, green: 0.1490196078, blue: 0.2666666667, alpha: 1); private static let white = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1); private static let black = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    private static let buttonPink = #colorLiteral(red: 0.862745098, green: 0.5411764706, blue: 0.662745098, alpha: 1); private static let buttonTeal = #colorLiteral(red: 0.6470588235, green: 0.8549019608, blue: 0.8352941176, alpha: 1)
    private static let buttonYellow = #colorLiteral(red: 1, green: 0.7882352941, blue: 0.3568627451, alpha: 1); private static let offWhite = #colorLiteral(red: 1, green: 0.9725490196, blue: 0.9607843137, alpha: 1)
    private static let transparent2 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
    // Hack 2025 color palette (color name + hex code)
    public static let rawSienna = #colorLiteral(red: 0.8705882353, green: 0.5568627451, blue: 0.2705882353, alpha: 1) // #DE8E45
    public static let neptune = #colorLiteral(red: 0.5176470588, green: 0.737254902, blue: 0.7254901961, alpha: 1) // #84BCB9
    public static let lightningYellow = #colorLiteral(red: 0.9764705882, green: 0.7568627451, blue: 0.1490196078, alpha: 1) // #F9C126
    public static let copper = #colorLiteral(red: 0.7725490196, green: 0.4039215686, blue: 0.2470588235, alpha: 1) // #C5673F
    public static let metallicCopper = #colorLiteral(red: 0.4274509804, green: 0.1607843137, blue: 0.1019607843, alpha: 1) // #6D291A
    public static let yellowOrange = #colorLiteral(red: 1.0, green: 0.6980392157, blue: 0.2431372549, alpha: 1) // #FFB23E
    public static let muleFawn = #colorLiteral(red: 0.537254902, green: 0.2470588235, blue: 0.1843137255, alpha: 1) // #893F2F
    public static let elephant = #colorLiteral(red: 0.05098039216, green: 0.2470588235, blue: 0.2549019608, alpha: 1) // #0D3F41
    public static let transparent = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
    public static let doveGray = #colorLiteral(red: 0.4235294118, green: 0.4235294118, blue: 0.4235294118, alpha: 1) // #6C6C6C
    
    private static var statusBarWhite: UIStatusBarStyle {
        return .lightContent
    }
    private static var statusBarBlack: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .lightContent
        } else { return .lightContent }
    }

    fileprivate static let day = HIAppearance(
        neonCountdownText: lightYellow,
        titleText: lightBlack,
        whiteText: white,
        darkGreenText: darkestGreen,
        lightYellowText: bLightYellow,
        baseText: lightBlack,
        accent: white,
        viewTitleBrown: darkBrown,
        action: tan,
        baseBackground: white,
        contentBackground: offWhite,
        overlay: #colorLiteral(red: 0.05882352941, green: 0.07058823529, blue: 0.1803921569, alpha: 0.33),
        frostedTint: #colorLiteral(red: 0, green: 0.3411764706, blue: 0.462745098, alpha: 0.6),
        codePopupTab: white,
        greenCodePopupTab: darkestGreen,
        navbarBackground: darkGreen,
        navbarTabTint: white,
        profileContainerTint: yellowWhite,
        preferredStatusBarStyle: statusBarBlack,
        scrollViewIndicatorStyle: .black,
        loginDefault: white,
        loginTitleBackground: white,
        loginLogo: #imageLiteral(resourceName: "LoginLogo"),
        loginLogoPad: UIImage(named: "LoginLogoPad")!,
        loginSelectionText: white,
        attendeeText: white,
        attendeeBackground: darknavy,
        whiteTagFont: white,
        interestBackground: orange,
        buttonGreen: yellowGreen,
        buttonBrown: lightBrown,
        buttonLightPink: other,
        buttonPurple: indigo,
        buttonDarkBlue: darkBlue,
        buttonMagenta: magenta,
        buttonDarkBlueGreen: darkBlueGreen,
        buttonDarkGreen: darkGreen,
        buttonOrange: orange,
        favoriteStarBackground: yellowWhite,
        segmentedBackground: white,
        buttonYellow: bLightYellow,
        buttonViewBackground: green,
        profile0: #imageLiteral(resourceName: "Profile0"),
        profile1: #imageLiteral(resourceName: "Profile1"),
        profile2: #imageLiteral(resourceName: "Profile2"),
        profile3: #imageLiteral(resourceName: "Profile3"),
        profile4: #imageLiteral(resourceName: "Profile4"),
        profile5: #imageLiteral(resourceName: "Profile5"),
        profile6: #imageLiteral(resourceName: "Profile6"),
        profile7: #imageLiteral(resourceName: "Profile7"),
        profile8: #imageLiteral(resourceName: "Profile8"),
        profile9: #imageLiteral(resourceName: "Profile9"),
        profile10: #imageLiteral(resourceName: "Profile10"),
        leaderboardText: lightBlack,
        leaderboardBackgroundOne: lightBlue,
        leaderboardBackgroundTwo: lightBlue,
        pointsBackground: white,
        profileCardBackground: lightBlue,
        profileCardVegetarian: vegetarian,
        profileCardVegan: vegan,
        profileCardGlutenFree: glutenfree,
        profileCardLactoseIntolerant: lactoseintolerant,
        profileCardOther: other,
        profileCardNone: none,
        profileBaseText: profileBaseText,
        countdownTextColor: brown,
        countdownBackground: orange,
        bannerBackground: lightYellow,
        scannerButtonPink: buttonPink,
        scannerButtonTeal: buttonTeal,
        scannerButtonYellow: buttonYellow,
        scannerButtonBorder: medBrown,
        scannerButtonShadow: darkBrown,
        proBackground: medTeal,
        eventCard: offWhite
    )

    fileprivate static let night = HIAppearance(
        neonCountdownText: lightYellow,
        titleText: lightBlack,
        whiteText: white,
        darkGreenText: darkestGreen,
        lightYellowText: bLightYellow,
        baseText: lightBlack,
        accent: white,
        viewTitleBrown: darkBrown,
        action: tan,
        baseBackground: white,
        contentBackground: offWhite,
        overlay: #colorLiteral(red: 0.05882352941, green: 0.07058823529, blue: 0.1803921569, alpha: 0.33),
        frostedTint: #colorLiteral(red: 0, green: 0.3411764706, blue: 0.462745098, alpha: 0.6),
        codePopupTab: white,
        greenCodePopupTab: darkestGreen,
        navbarBackground: darkGreen,
        navbarTabTint: white,
        profileContainerTint: yellowWhite,
        preferredStatusBarStyle: statusBarBlack,
        scrollViewIndicatorStyle: .black,
        loginDefault: white,
        loginTitleBackground: white,
        loginLogo: #imageLiteral(resourceName: "LoginLogo"),
        loginLogoPad: UIImage(named: "LoginLogoPad")!,
        loginSelectionText: white,
        attendeeText: white,
        attendeeBackground: darknavy,
        whiteTagFont: white,
        interestBackground: orange,
        buttonGreen: yellowGreen,
        buttonBrown: lightBrown,
        buttonLightPink: other,
        buttonPurple: indigo,
        buttonDarkBlue: darkBlue,
        buttonMagenta: magenta,
        buttonDarkBlueGreen: darkBlueGreen,
        buttonDarkGreen: darkGreen,
        buttonOrange: orange,
        favoriteStarBackground: yellowWhite,
        segmentedBackground: white,
        buttonYellow: bLightYellow,
        buttonViewBackground: green,
        profile0: #imageLiteral(resourceName: "Profile0"),
        profile1: #imageLiteral(resourceName: "Profile1"),
        profile2: #imageLiteral(resourceName: "Profile2"),
        profile3: #imageLiteral(resourceName: "Profile3"),
        profile4: #imageLiteral(resourceName: "Profile4"),
        profile5: #imageLiteral(resourceName: "Profile5"),
        profile6: #imageLiteral(resourceName: "Profile6"),
        profile7: #imageLiteral(resourceName: "Profile7"),
        profile8: #imageLiteral(resourceName: "Profile8"),
        profile9: #imageLiteral(resourceName: "Profile9"),
        profile10: #imageLiteral(resourceName: "Profile10"),
        leaderboardText: lightBlack,
        leaderboardBackgroundOne: lightBlue,
        leaderboardBackgroundTwo: lightBlue,
        pointsBackground: white,
        profileCardBackground: lightBlue,
        profileCardVegetarian: vegetarian,
        profileCardVegan: vegan,
        profileCardGlutenFree: glutenfree,
        profileCardLactoseIntolerant: lactoseintolerant,
        profileCardOther: other,
        profileCardNone: none,
        profileBaseText: profileBaseText,
        countdownTextColor: brown,
        countdownBackground: orange,
        bannerBackground: lightYellow,
        scannerButtonPink: buttonPink,
        scannerButtonTeal: buttonTeal,
        scannerButtonYellow: buttonYellow,
        scannerButtonBorder: medBrown,
        scannerButtonShadow: darkBrown,
        proBackground: medTeal,
        eventCard: offWhite
    )

    fileprivate static var current = day

    static func change(to newAppearance: HIAppearance) {
        guard current != newAppearance else { return }
        current = newAppearance
        NotificationCenter.default.post(name: .themeDidChange, object: nil)
    }

    enum Font {
        // Fonts ending with "Pad" correspond to the iPad font sizes
        // Glyph font corresponds to the time texts that separate the event cells on the schedule page (2023) and the "Memories Made" (2023 app) text
        static let glyph = UIFont(name: "MontserratRoman-Bold", size: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 16)
        
        // Home segemented control fonts
        static let homeSegmentedTitle = UIFont(name: "MontserratRoman-Bold", size: UIDevice.current.userInterfaceIdiom == .pad ? 40 : 24)
        
        // Schedule page segmented control fonts
        static let segmentedNumberText = UIFont(name: "MontserratRoman-SemiBold", size: UIDevice.current.userInterfaceIdiom == .pad ? 64 : 32) // Dates
        static let scheduleSegmentedPad = UIFont(name: "MontserratRoman-SemiBold", size: 32)
        static let segmentedTitle = UIFont(name: "MontserratRoman-Bold", size: 16)
        // More Schedule page fonts
        static let timeIndicator = UIFont(name: "MontserratRoman-Bold", size: 32)
        static let happeningEventTitle = UIFont(name: "MontserratRoman-Bold", size: 25)
        static let dateHeader = UIFont(name: "MontserratRoman-Bold", size: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 14) // Date header event cell separators 2024
        
        // Main header title for each page (Profile, Schedule, etc)
        static let viewTitle = UIFont(name: "MontserratRoman-Bold", size: UIDevice.current.userInterfaceIdiom == .pad ? 48 : 24)
        
        // Event bubble cell fonts
        static let eventTitlePad = UIFont(name: "MontserratRoman-Bold", size: 36)
        static let eventTitle = UIFont(name: "MontserratRoman-SemiBold", size: 18)
        static let locationText = UIFont(name: "MontserratRoman-SemiBold", size: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 12)
        static let sponsorText = UIFont(name: "MontserratRoman-SemiBold", size: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 12)
        static let timeText = UIFont(name: "MontserratRoman-SemiBold", size: UIDevice.current.userInterfaceIdiom == .pad ? 28 : 14)
        static let descriptionTextPad = UIFont(name: "MontserratRoman-SemiBold", size: 18)
        
        // Event card popup
        static let contentText = UIFont(name: "MontserratRoman-Regular", size: 14) // Location text
        static let contentTextPad = UIFont(name: "MontserratRoman-SemiBold", size: 18)
        static let detailTitle = UIFont(name: "MontserratRoman-SemiBold", size: 24)
        static let detailTextPad = UIFont(name: "MontserratRoman-Regular", size: 24)
        static let detailSubtitle = UIFont(name: "MontserratRoman-Medium", size: 16)
        static let detailText = UIFont(name: "MontserratRoman-Regular", size: UIDevice.current.userInterfaceIdiom == .pad ? 19 : 16)
        static let eventTime = UIFont(name: "MontserratRoman-Regular", size: 15)
        static let eventDetails = UIFont(name: "MontserratRoman-Regular", size: 14)
        static let eventButtonText = UIFont(name: "MontserratRoman-SemiBold", size: UIDevice.current.userInterfaceIdiom == .pad ? 18 : 14)
        static let eventCategoryText = UIFont(name: "MontserratRoman-Regular", size: 16)
        static let clockText = UIFont(name: "MontserratRoman-SemiBold", size: 48)
        static let descriptionText = UIFont(name: "MontserratRoman-Regular", size: 16)
        static let contentSubtitle = UIFont(name: "MontserratRoman-Light", size: 13)
        static let contentTitle = UIFont(name: "MontserratRoman-Medium", size: 18)
        
        // Navigation fonts
        static let navigationSubtitle = UIFont(name: "MontserratRoman-Medium", size: 14)
        static let navigationTitle = UIFont(name: "MontserratRoman-SemiBold", size: 22)
        static let navigationInfoText = UIFont(name: "MontserratRoman-Regular", size: 12)
        
        // Login fonts
        static let loginTitle = UIFont(name: "MontserratRoman-Bold", size: UIDevice.current.userInterfaceIdiom == .pad ? 32: 24)
        static let loginOrTitle = UIFont(name: "MontserratRoman-Bold", size: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 16)
        static let loginSelection = UIFont(name: "MontserratRoman-SemiBold", size: UIDevice.current.userInterfaceIdiom == .pad ? 26: 16)
        
        // Profile-related fonts
        static let profileName = UIFont(name: "MontserratRoman-Bold", size: UIDevice.current.userInterfaceIdiom == .pad ? 40 : 20)
        static let profileSubtitle = UIFont(name: "MontserratRoman-Bold", size: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 12)
        static let profileDietaryRestrictions = UIFont(name: "MontserratRoman-SemiBold", size: UIDevice.current.userInterfaceIdiom == .pad ? 32 : 16)
        static let profileDietaryRestrictionsLabel = UIFont(name: "MontserratRoman-Bold", size: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 12)
        static let profileTier = UIFont(name: "MontserratRoman-Bold", size: UIDevice.current.userInterfaceIdiom == .pad ? 36 : 18)
        static let profileNumberFigure = UIFont(name: "MontserratRoman-SemiBold", size: 24)
        static let profileUsername = UIFont(name: "MontserratRoman-Bold", size: 16)
        static let profileInterests = UIFont(name: "MontserratRoman-SemiBold", size: 14)
        
        // QR code fonts
        static let QRCheckInFont = UIFont(name: "MontserratRoman-SemiBold", size: 14)
        
        // Home page countdown fonts
//        static let newCountdownText = UIFont(name: "MontserratRoman-Bold", size: 48) // Hack 2023
        static let newCountdownText = UIFont(name: "MontserratRoman-Bold", size: 42) // Hack 2024
        static let newCountdownTextPad = UIFont(name: "MontserratRoman-Bold", size: 56) // Hack 2024
        static let countdownText = UIFont(name: "MontserratRoman-Bold", size: 25)
        
        // Onboarding fonts
        static let onboardingGetStartedText = UIFont(name: "MontserratRoman-SemiBold", size: 25)
        static let onboardingTitle = UIFont(name: "MontserratRoman-Bold", size: 30)
        static let onboardingDescription = UIFont(name: "MontserratRoman-Regular", size: 20)
        
        // Leaderboard fonts
        static let leaderboardPoints = UIFont(name: "MontserratRoman-Semibold", size: 12)
        static let leaderboardName = UIFont(name: "MontserratRoman-SemiBold", size: 16)
        static let leaderboardRank = UIFont(name: "MontserratRoman-Bold", size: 24)
        static let leaderboardPointsPad = UIFont(name: "MontserratRoman-Bold", size: 24)
        static let leaderboardNamePad = UIFont(name: "MontserratRoman-SemiBold", size: 32)
        static let leaderboardRankPad = UIFont(name: "MontserratRoman-Bold", size: 48)
        
        // Misc
        static let sectionHeader = UIFont(name: "MontserratRoman-Bold", size: 12)
        static let button = UIFont(name: "MontserratRoman-Regular", size: 15)
        static let welcomeTitle = UIFont(name: "MontserratRoman-Bold", size: UIDevice.current.userInterfaceIdiom == .pad ? 40: 24)
        
        // Font for Staff QR code selection
        static let QRSelection = UIFont(name: "MontserratRoman-Bold", size: 24)
        static let smallEvent = UIFont(name: "MontserratRoman-SemiBold", size: 15)
        static let smallEventPad = UIFont(name: "MontserratRoman-SemiBold", size: 30)
    }
}

// MARK: - HIApperanceKeyPath
extension KeyPath where Root == HIAppearance {
    var value: Value {
        return HIAppearance.current[keyPath: self]
    }
}

// MARK: - HIColor
typealias HIColor = KeyPath<HIAppearance, UIColor>

extension UIColor {
    static func <- (lhs: inout UIColor, rhs: HIColor) {
        lhs = rhs.value
    }
}

extension Optional where Wrapped == UIColor {
    static func <- (lhs: inout UIColor?, rhs: HIColor) {
        lhs = rhs.value
    }

    static func <- (lhs: inout UIColor?, rhs: HIColor?) {
        lhs = rhs?.value
    }
}

// MARK: - HIImage
typealias HIImage = KeyPath<HIAppearance, UIImage>

extension UIImage {
    static func <- (lhs: inout UIImage, rhs: HIImage) {
        lhs = rhs.value
    }
}

extension Optional where Wrapped == UIImage {
    static func <- (lhs: inout UIImage?, rhs: HIImage) {
        lhs = rhs.value
    }

    static func <- (lhs: inout UIImage?, rhs: HIImage?) {
        lhs = rhs?.value
    }
}

// MARK: - HIStatusBarStyle
typealias HIStatusBarStyle = KeyPath<HIAppearance, UIStatusBarStyle>

extension UIStatusBarStyle {
    static func <- (lhs: inout UIStatusBarStyle, rhs: HIStatusBarStyle) {
        lhs = rhs.value
    }
}

extension Optional where Wrapped == UIStatusBarStyle {
    static func <- (lhs: inout UIStatusBarStyle?, rhs: HIStatusBarStyle) {
        lhs = rhs.value
    }

    static func <- (lhs: inout UIStatusBarStyle?, rhs: HIStatusBarStyle?) {
        lhs = rhs?.value
    }
}

// MARK: - HIStatusBarStyle
typealias HIScrollViewIndicatorStyle = KeyPath<HIAppearance, UIScrollView.IndicatorStyle>

extension UIScrollView.IndicatorStyle {
    static func <- (lhs: inout UIScrollView.IndicatorStyle, rhs: HIScrollViewIndicatorStyle) {
        lhs = rhs.value
    }
}

extension Optional where Wrapped == UIScrollView.IndicatorStyle {
    static func <- (lhs: inout UIScrollView.IndicatorStyle?, rhs: HIScrollViewIndicatorStyle) {
        lhs = rhs.value
    }

    static func <- (lhs: inout UIScrollView.IndicatorStyle?, rhs: HIScrollViewIndicatorStyle?) {
        lhs = rhs?.value
    }
}

// MARK: - HIThemeEngine
class HIThemeEngine {
    static let shared = HIThemeEngine()

    // MARK: - Properties
    var timer: Timer?

    // MARK: - Init
    private init() {
        startUpTimer()
    }
    deinit {
        tearDownTimer()
    }

    // MARK: - Theme Timer
    func startUpTimer() {
        timer = Timer.scheduledTimer(
            timeInterval: 300, // every 5 minutes
            target: self,
            selector: #selector(updateThemeIfNeeded),
            userInfo: nil,
            repeats: true
        )
        timer?.fire()
    }
    @objc func updateThemeIfNeeded() {
        let calendar = Calendar.current
        let now = Date()
        guard let sunrise = calendar.date(bySettingHour: 6, minute: 30, second: 0, of: now),
            let sunset = calendar.date(bySettingHour: 17, minute: 30, second: 0, of: now) else { return }

        let newAppearance: HIAppearance
        if now >= sunrise && now <= sunset {
            newAppearance = .day
        } else {
            newAppearance = .night
        }
        HIAppearance.change(to: newAppearance)
    }
    func tearDownTimer() {
        timer?.invalidate()
        timer = nil
    }
}
