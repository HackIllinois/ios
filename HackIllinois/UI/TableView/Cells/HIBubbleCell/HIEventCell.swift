//
//  HIEventCell.swift
//  HackIllinois
//
//  Created by HackIllinois Team on 11/21/17.
//  Copyright © 2017 HackIllinois. All rights reserved.
//  This file is part of the Hackillinois iOS App.
//  The Hackillinois iOS App is open source software, released under the University of
//  Illinois/NCSA Open Source License. You should have received a copy of
//  this license in a file with the distribution.
//

import Foundation
import UIKit
import HIAPI

protocol HIEventCellDelegate: AnyObject {
    func eventCellDidSelectFavoriteButton(_ eventCell: HIEventCell)
}

class HIEventCell: HIBubbleCell {
    // MARK: - Properties
    let favoritedButton = HIButton {
        $0.tintHIColor = \.accent
        $0.backgroundHIColor = \.clear
        $0.activeImage = #imageLiteral(resourceName: "Selected Bookmark")
        $0.baseImage = #imageLiteral(resourceName: "Unselected Bookmark")
        if UIDevice.current.userInterfaceIdiom == .pad {
            $0.activeImage = #imageLiteral(resourceName: "Big Selected Bookmark")
            $0.baseImage = #imageLiteral(resourceName: "Big Unselected Bookmark")
        }
    }
    var headerView = UIStackView()
    var contentStackView = UIStackView()
    var contentStackViewHeight = NSLayoutConstraint()
    
    var indexPath: IndexPath?
    weak var delegate: HIEventCellDelegate?
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        var headerSpacingConstant: CGFloat = 1.0
        if UIDevice.current.userInterfaceIdiom == .pad {
            headerSpacingConstant = 2.0
        }
        backgroundColor = UIColor.clear
        favoritedButton.addTarget(self, action: #selector(didSelectFavoriteButton(_:)), for: .touchUpInside)
        // add bubble view
        contentView.layer.backgroundColor = UIColor.clear.cgColor
        bubbleView.addSubview(headerView)
        headerView.axis = .vertical
        headerView.alignment = .leading
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 17 * headerSpacingConstant).isActive = true
        headerView.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 16 * headerSpacingConstant).isActive = true
        bubbleView.addSubview(favoritedButton)
        favoritedButton.constrain(width: 58 * headerSpacingConstant, height: 50 * headerSpacingConstant)
        favoritedButton.constrain(to: bubbleView, topInset: 0, trailingInset: 0)
        
        bubbleView.addSubview(contentStackView)
        contentStackView.axis = .vertical
        contentStackView.alignment = .leading
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -16).isActive = true
        contentStackView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10 * headerSpacingConstant).isActive = true
        contentStackView.bottomAnchor.constraint(greaterThanOrEqualTo: bubbleView.bottomAnchor, constant: -16 * headerSpacingConstant).isActive = true
        // Don't show favorite button for guests
        if HIApplicationStateController.shared.isGuest {
            favoritedButton.isHidden = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) should not be used.")
    }
}

// MARK: - Actions
extension HIEventCell {
    @objc func didSelectFavoriteButton(_ sender: HIButton) {
        delegate?.eventCellDidSelectFavoriteButton(self)
    }
    
}

// MARK: - Population
extension HIEventCell {
    static func heightForCell(with event: Event, width: CGFloat) -> CGFloat {
        let heightFromEventName = HILabel.heightForView(text: event.name, font: HIAppearance.Font.eventTitle!, width: width - 137)
        var heightConstant: CGFloat = 1.6
        if UIDevice.current.userInterfaceIdiom == .pad {
            heightConstant = 11.0
        }
        let height = heightFromEventName + 160
        if !event.sponsor.isEmpty {
            return height + (20 * heightConstant)
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            return height + (22 * (heightConstant / 1.45))
        }
        return height + 5
    }
    static func <- (lhs: HIEventCell, rhs: Event) {
        lhs.favoritedButton.isActive = rhs.favorite
        var contentStackViewHeight: CGFloat = 0.0; var eventCellSpacing: CGFloat = 8.0
        var stackViewSpacing: CGFloat = 4.7; var bubbleConstant: CGFloat = 1.0
        var locationImageView = UIImageView(image: #imageLiteral(resourceName: "Location")); var timeImageView = UIImageView(image: #imageLiteral(resourceName: "SandTimer"))
        var sponsorImageView = UIImageView(image: #imageLiteral(resourceName: "Sponsor")); let titleLabel = HILabel(style: .event)
        titleLabel.numberOfLines = 2; titleLabel.text = rhs.name
        lhs.headerView.addArrangedSubview(titleLabel)
        lhs.headerView.setCustomSpacing(9, after: titleLabel)
        if UIDevice.current.userInterfaceIdiom == .pad {
            eventCellSpacing = 12.0; stackViewSpacing = 15.0; bubbleConstant = 2.0
            locationImageView = UIImageView(image: #imageLiteral(resourceName: "Location"))
            timeImageView = UIImageView(image: #imageLiteral(resourceName: "SandTimer"))
            sponsorImageView = UIImageView(image: #imageLiteral(resourceName: "Sponsor"))
            lhs.headerView.setCustomSpacing(18, after: titleLabel)
        }
        titleLabel.constrain(width: lhs.contentView.frame.width - 120, height: (HILabel.heightForView(text: rhs.name, font: HIAppearance.Font.eventTitle!, width: lhs.contentView.frame.width - 137)) * bubbleConstant)
        let upperContainerView = HIView {
            lhs.contentStackView.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        let middleContainerView = HIView {
            lhs.contentStackView.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        let timeLabel = HILabel(style: .time)
        // We can check for async events by checking if the event start and end time is 1970-01-01 00:00:00 +0000
        if rhs.startTime.timeIntervalSince1970 == 0 || rhs.endTime.timeIntervalSince1970 == 0 {
            timeLabel.text = HIConstants.ASYNC_EVENT_TIME_TEXT
        } else {
            timeLabel.text = Formatter.simpleTime.string(from: rhs.startTime) + " - " + Formatter.simpleTime.string(from: rhs.endTime)
        }
        let pointsView = HIView { (view) in
            view.layer.cornerRadius = 10.5 * bubbleConstant; view.backgroundHIColor = \.buttonBrown
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        let eventTypeView = HIView { (view) in
            view.layer.cornerRadius = 10.5 * bubbleConstant; view.backgroundHIColor = \.buttonPurple
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        let proTypeView = HIView { (view) in
            view.layer.cornerRadius = 10.5 * bubbleConstant; view.backgroundHIColor = \.proBackground
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        let proLabel = HILabel(style: .pointsText); proLabel.text = "Pro"
        let pointsLabel = HILabel(style: .pointsText)
        upperContainerView.addSubview(pointsView)
        pointsView.addSubview(pointsLabel)
        pointsLabel.constrain(to: pointsView, topInset: 4, trailingInset: -8 * bubbleConstant, bottomInset: -4, leadingInset: 8 * bubbleConstant)
        pointsLabel.text = "+ \(rhs.points) pts"
        let typeLabel = HILabel(style: .pointsText)
        lhs.headerView.addArrangedSubview(eventTypeView)
        eventTypeView.addSubview(typeLabel)
        typeLabel.constrain(to: eventTypeView, topInset: 4, trailingInset: -8, bottomInset: -4, leadingInset: 8)
        typeLabel.text = rhs.eventType.description.lowercased().capitalized
        eventTypeView.constrain(height: 20 * bubbleConstant)
        pointsView.constrain(height: 20 * bubbleConstant)
        pointsView.leadingAnchor.constraint(equalTo: eventTypeView.trailingAnchor, constant: 8 * bubbleConstant).isActive = true
        pointsView.centerYAnchor.constraint(equalTo: eventTypeView.centerYAnchor).isActive = true
        if rhs.isPro {
            upperContainerView.addSubview(proTypeView); proTypeView.addSubview(proLabel); proLabel.text = "Pro"
            proTypeView.constrain(height: 20 * bubbleConstant); proTypeView.centerYAnchor.constraint(equalTo: pointsView.centerYAnchor).isActive = true
            proTypeView.leadingAnchor.constraint(equalTo: pointsView.trailingAnchor, constant: 8 * bubbleConstant).isActive = true
            proLabel.constrain(to: proTypeView, topInset: 4, trailingInset: -8, bottomInset: -4, leadingInset: 8)
        }
        upperContainerView.addSubview(timeImageView)
        upperContainerView.addSubview(timeLabel)
        timeLabel.leadingAnchor.constraint(equalTo: timeImageView.trailingAnchor, constant: eventCellSpacing + 1).isActive = true
        timeLabel.centerYAnchor.constraint(equalTo: timeImageView.centerYAnchor).isActive = true
        if !rhs.sponsor.isEmpty {
            let sponsorLabel = HILabel(style: .sponsor)
            middleContainerView.addSubview(sponsorImageView)
            middleContainerView.addSubview(sponsorLabel)
            sponsorImageView.translatesAutoresizingMaskIntoConstraints = false
            sponsorLabel.text = "\(rhs.sponsor)"
            contentStackViewHeight += sponsorLabel.intrinsicContentSize.height
            sponsorImageView.bottomAnchor.constraint(equalTo: timeImageView.bottomAnchor, constant: (stackViewSpacing * 2.5) + 14).isActive = true
            sponsorLabel.leadingAnchor.constraint(equalTo: sponsorImageView.trailingAnchor, constant: eventCellSpacing + 1).isActive = true
            sponsorLabel.centerYAnchor.constraint(equalTo: sponsorImageView.centerYAnchor).isActive = true
        }
        let locationLabel = HILabel(style: .newLocation); locationLabel.text = "Online"
        if rhs.locations.count > 0 {
            locationLabel.text = rhs.locations.map({ ($0 as AnyObject).name }).joined(separator: ", ")
        }
        middleContainerView.addSubview(locationImageView)
        locationImageView.translatesAutoresizingMaskIntoConstraints = false
        middleContainerView.addSubview(locationLabel)
        if !rhs.sponsor.isEmpty {
            locationImageView.centerYAnchor.constraint(equalTo: sponsorImageView.centerYAnchor, constant: (stackViewSpacing * 2.5) + 14).isActive = true
        } else {
            locationImageView.centerYAnchor.constraint(equalTo: timeImageView.centerYAnchor, constant: (stackViewSpacing * 2.5) + 14).isActive = true
        }
        locationImageView.centerXAnchor.constraint(equalTo: timeImageView.centerXAnchor).isActive = true
        locationLabel.leadingAnchor.constraint(equalTo: timeLabel.leadingAnchor).isActive = true
        locationLabel.centerYAnchor.constraint(equalTo: locationImageView.centerYAnchor).isActive = true
        let descriptionLabel = HILabel(style: .cellDescription)
        descriptionLabel.numberOfLines = 2
        descriptionLabel.text = "\(rhs.info)"
        lhs.contentStackView.addArrangedSubview(descriptionLabel)
        contentStackViewHeight += HILabel.heightForView(text: rhs.name, font: HIAppearance.Font.eventTitle!, width: lhs.contentView.frame.width - 98)
        contentStackViewHeight += timeLabel.intrinsicContentSize.height + locationLabel.intrinsicContentSize.height + 13 + 40 + 3 + 40
    }
}

// MARK: - UITableViewCell
extension HIEventCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        favoritedButton.isActive = false
        headerView.subviews.forEach {(view) in
            headerView.willRemoveSubview(view)
            view.removeFromSuperview()
        }
        contentStackView.arrangedSubviews.forEach { (view) in
            contentStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
}
