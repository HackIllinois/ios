//
//  HILabel.swift
//  HackIllinois
//
//  Created by HackIllinois Team on 2/21/18.
//  Copyright © 2018 HackIllinois. All rights reserved.
//  This file is part of the Hackillinois iOS App.
//  The Hackillinois iOS App is open source software, released under the University of
//  Illinois/NCSA Open Source License. You should have received a copy of
//  this license in a file with the distribution.
//

import Foundation
import UIKit

class HILabel: UILabel {
    // MARK: - Types
    enum Style {
        case location
        case event
        case smallEvent
        case eventTime
        case eventType
        case sponsor
        case project
        case viewTitle
        case viewTitleBrown
        case detailTitle
        case subtitle
        case description
        case cellDescription
        case loginHeader
        case loginSelection
        case welcomeTitle
        case backgroundTitle
        case detailSubtitle
        case detailText
        case profileName
        case profileSubtitle
        case profileNumberFigure
        case profileTier
        case profileUsername
        case profileInterests
        case profileDietaryRestrictions
        case countdown
        case navigationInfo
        case pointsText
        case error
        case codeError
        case onboardingDescription
        case onboardingTitle
        case clock
        case leaderboardRank
        case leaderboardName
        case leaderboardPoints
        case newCountdown
        // Cases used on bubble event cell
        case newLocation
        case time
        case QRSelection
    }

    // MARK: - Properties
    let style: Style?

    var textHIColor: HIColor?
    var backgroundHIColor: HIColor?

    // MARK: - Init
    // Waive swiftlint warning
    // swiftlint:disable:next function_body_length
    init(style: Style? = nil, additionalConfiguration: ((HILabel) -> Void)? = nil) {
        self.style = style
        super.init(frame: .zero)
        additionalConfiguration?(self)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshForThemeChange), name: .themeDidChange, object: nil)

        translatesAutoresizingMaskIntoConstraints = false
        if let style = style {
        switch style {
        case .newCountdown:
            textHIColor = \.countdownTextColor
            backgroundHIColor = \.countdownBackground
            if UIDevice.current.userInterfaceIdiom == .pad {
                font = HIAppearance.Font.newCountdownTextPad
            } else {
                font = HIAppearance.Font.newCountdownText
            }

        case .location:
            textHIColor = \.baseText
            backgroundHIColor = \.clear
            if UIDevice.current.userInterfaceIdiom == .pad {
                font = HIAppearance.Font.contentTextPad
            } else {
                font = HIAppearance.Font.contentText
            }

        case .event:
            textHIColor = \.baseText
            backgroundHIColor = \.clear
            if UIDevice.current.userInterfaceIdiom == .pad {
                font = HIAppearance.Font.eventTitlePad
            } else {
                font = HIAppearance.Font.eventTitle
            }
            
        case .smallEvent:
            textHIColor = \.baseText
            backgroundHIColor = \.clear
            if UIDevice.current.userInterfaceIdiom == .pad {
                font = HIAppearance.Font.smallEventPad
            } else {
                font = HIAppearance.Font.smallEvent
            }
            
        case .eventTime:
            textHIColor = \.baseText
            backgroundHIColor = \.clear
            font = HIAppearance.Font.eventTime
            
        case .eventType:
            textHIColor = \.whiteText
            backgroundHIColor = \.clear
            font = HIAppearance.Font.eventButtonText

        case .sponsor:
            textHIColor = \.baseText
            backgroundHIColor = \.clear
            font = HIAppearance.Font.sponsorText

        case .detailTitle:
            textHIColor = \.baseText
            backgroundHIColor = \.clear
            font = HIAppearance.Font.detailTitle
            numberOfLines = 0

        case .detailSubtitle:
            textHIColor = \.baseText
            backgroundHIColor = \.clear
            font = HIAppearance.Font.detailSubtitle
            numberOfLines = 0

        case .detailText:
            textHIColor = \.baseText
            backgroundHIColor = \.clear
            font = HIAppearance.Font.detailText
            numberOfLines = 0

        case .project: // "Schedule"
            textHIColor = \.white
            backgroundHIColor = \.clear
            font = HIAppearance.Font.contentTitle

        case .viewTitle: // "What's cooking"
            textHIColor = \.whiteText
            backgroundHIColor = \.clear
            textAlignment = .center
            font = HIAppearance.Font.viewTitle
        
        case .viewTitleBrown:
            textHIColor = \.viewTitleBrown
            backgroundHIColor = \.clear
            textAlignment = .center
            font = HIAppearance.Font.viewTitle

        case .subtitle:
            textHIColor = \.accent
            backgroundHIColor = \.clear
            font = HIAppearance.Font.contentSubtitle

        case .description:
            textHIColor = \.baseText
            backgroundHIColor = \.clear
            if UIDevice.current.userInterfaceIdiom == .pad {
                font = HIAppearance.Font.descriptionTextPad
            } else {
                font = HIAppearance.Font.descriptionText
            }
            numberOfLines = 0

        case .cellDescription:
            textHIColor = \.baseText
            backgroundHIColor = \.clear
            if UIDevice.current.userInterfaceIdiom == .pad {
                font = HIAppearance.Font.detailTextPad
            } else {
                font = HIAppearance.Font.eventDetails
            }
            numberOfLines = 0

        case .loginHeader:
            textHIColor = \.loginTitleBackground
            backgroundHIColor = \.clear
            font = HIAppearance.Font.loginTitle

        case .welcomeTitle:
            textHIColor = \.black
            backgroundHIColor = \.clear
            font = HIAppearance.Font.welcomeTitle

        case .backgroundTitle:
            textHIColor = \.baseText
            backgroundHIColor = \.clear
            textAlignment = .center
            font = HIAppearance.Font.navigationSubtitle

        case .loginSelection:
            textHIColor = \.loginSelectionText
            backgroundHIColor = \.clear
            textAlignment = .center
            font = HIAppearance.Font.loginSelection
            layer.borderWidth = 2.0
            layer.borderColor = (\HIAppearance.loginSelectionText).value.cgColor
            layer.backgroundColor = UIColor.clear.cgColor

        case .profileName: // Used to display the profile owner's name
            textHIColor = \.baseText
            backgroundHIColor = \.clear
            textAlignment = .center
            font = HIAppearance.Font.profileName

        case .profileSubtitle: // Used to display profile subtitle, "points", and whatever that says "time zone"
            backgroundHIColor = \.clear
            textHIColor = \.baseText
            textAlignment = .center
            font = HIAppearance.Font.profileSubtitle

        case .profileNumberFigure: // Used to display number of points and time (?)
            textHIColor = \.baseText
            backgroundHIColor = \.clear
            textAlignment = .center
            font = HIAppearance.Font.profileNumberFigure

        case .profileTier: // Used to display "short description"
            textHIColor = \.baseText
            backgroundHIColor = \.clear
            textAlignment = .left
            font = HIAppearance.Font.profileTier

        case .profileUsername: // Used to display Discord username, etc.
            textHIColor = \.whiteTagFont
            backgroundHIColor = \.clear
            textAlignment = .left
            font = HIAppearance.Font.profileUsername

        case .profileInterests:
            textHIColor = \.whiteTagFont
            backgroundHIColor = \.clear
            textAlignment = .center
            font = HIAppearance.Font.profileInterests

        case .profileDietaryRestrictions:
            textHIColor = \.baseText
            backgroundHIColor = \.clear
            textAlignment = .center
            font = HIAppearance.Font.profileDietaryRestrictions

        case .navigationInfo: // "All times are in CDT"
            textHIColor = \.white
            backgroundHIColor = \.clear
            font = HIAppearance.Font.navigationInfoText
            textAlignment = .left
            
        case .countdown:
            textHIColor = \.titleText
            backgroundHIColor = \.clear
            font = HIAppearance.Font.countdownText

        case .pointsText:
            textHIColor = \.white
            backgroundHIColor = \.clear
            if UIDevice.current.userInterfaceIdiom == .pad {
                font = HIAppearance.Font.glyph
            } else {
                font = HIAppearance.Font.eventButtonText
            }
            textAlignment = .center

        case .error:
            textHIColor = \.white
            backgroundHIColor = \.clear
            font = HIAppearance.Font.detailSubtitle
            textAlignment = .center
            numberOfLines = 0

        case .codeError:
            textHIColor = \.white
            backgroundHIColor = \.clear
            font = HIAppearance.Font.detailSubtitle
            textAlignment = .center
            numberOfLines = 0

        case .onboardingDescription:
            textHIColor = \.black
            backgroundHIColor = \.clear
            font = HIAppearance.Font.profileNumberFigure
            textAlignment = .center
            numberOfLines = 0

        case .onboardingTitle:
            textHIColor = \.black
            backgroundHIColor = \.clear
            font = HIAppearance.Font.scheduleSegmentedPad
            textAlignment = .center
            numberOfLines = 0

        case .clock:
            textHIColor = \.whiteText
            backgroundHIColor = \.clear
            font = HIAppearance.Font.clockText
            textAlignment = .center
            numberOfLines = 1

        // Leaderboard label fonts
        case .leaderboardRank:
            textHIColor = \.leaderboardText
            backgroundHIColor = \.clear
            if UIDevice.current.userInterfaceIdiom == .pad {
                font = HIAppearance.Font.leaderboardRankPad
            } else {
                font = HIAppearance.Font.leaderboardRank
            }

        case .leaderboardName:
            textHIColor = \.leaderboardText
            backgroundHIColor = \.clear
            if UIDevice.current.userInterfaceIdiom == .pad {
                font = HIAppearance.Font.leaderboardNamePad
            } else {
                font = HIAppearance.Font.leaderboardName
            }

        case .leaderboardPoints:
            textHIColor = \.leaderboardText
            backgroundHIColor = \.pointsBackground
            if UIDevice.current.userInterfaceIdiom == .pad {
                font = HIAppearance.Font.leaderboardPointsPad
            } else {
                font = HIAppearance.Font.leaderboardPoints
            }
            
        // Case for event bubble cell time info
        case .time:
            textHIColor = \.black
            backgroundHIColor = \.clear
            font = HIAppearance.Font.timeText
            
        // Case for event bubble cell location info
        case .newLocation:
            textHIColor = \.black
            backgroundHIColor = \.clear
            font = HIAppearance.Font.locationText
            
        case .QRSelection:
            textHIColor = \.whiteText
            backgroundHIColor = \.clear
            font = HIAppearance.Font.QRSelection
        }
        }

        refreshForThemeChange()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) should not be used.")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func changeTextColor(color: HIColor) {
        textColor <- color
    }

    // MARK: - Themeable
    @objc func refreshForThemeChange() {
        textColor <- textHIColor
        backgroundColor <- backgroundHIColor
    }
}

// MARK: - Auto-Sizing
extension HILabel {
    static func heightForView(text: String, font: UIFont, width: CGFloat, numLines: Int = 0) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = numLines
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text

        label.sizeToFit()
        return label.frame.height
   }
}
