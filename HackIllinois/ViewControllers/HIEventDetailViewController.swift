//
//  HIEventDetailViewController.swift
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
import MapKit
import HIAPI
import APIManager
import GoogleMaps

class HIEventDetailViewController: HIBaseViewController, UIGestureRecognizerDelegate {
    // MARK: - Properties
    var event: Event?

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
    private let sponsorLabel = HILabel(style: .sponsor)
    private let timeImageView = UIImageView(image: UIImage(named: "SandTimer"))
    private let timeLabel = HILabel(style: .description)
    private let locationLabel = HILabel(style: .location)
    private let locationImageView = UIImageView(image: UIImage(named: "Location"))
    private let descriptionLabel = HILabel(style: .detailText)
    let pointsView = HIView { (view) in
        if UIDevice.current.userInterfaceIdiom == .pad {
            view.layer.cornerRadius = 12
        } else {
            view.layer.cornerRadius = 8
        }
        view.backgroundHIColor = \.buttonBlue
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    private let pointsLabel = HILabel(style: .eventType)
    private let favoritedButton = HIButton {
        $0.tintHIColor = \.accent
        $0.backgroundHIColor = \.clear
        $0.activeImage = #imageLiteral(resourceName: "Favorited")
        $0.baseImage = #imageLiteral(resourceName: "Unfavorited")
    }
    private let closeButton = HIButton {
        $0.tintHIColor = \.baseText
        $0.backgroundHIColor = \.clear
        $0.activeImage = #imageLiteral(resourceName: "MenuClose")
        $0.baseImage = #imageLiteral(resourceName: "MenuClose")
    }
    private let mapContainer = HIView {
        $0.layer.cornerRadius = 12
        $0.layer.borderColor = #colorLiteral(red: 0.9254901961, green: 0.8235294118, blue: 0.8235294118, alpha: 1)
        $0.layer.borderWidth = 4.0
        $0.layer.masksToBounds = true
        $0.layer.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundHIColor = \.white
    }
    
    private var mapView: UIImageView = UIImageView()
    var isZooming = false
    var originalImageCenter:CGPoint?
    
    // MARK: Constraints
    private var descriptionLabelHeight = NSLayoutConstraint()

}

// MARK: - Actions
extension HIEventDetailViewController {
    @objc func didSelectFavoriteButton(_ sender: HIButton) {
        guard let event = event else { return }

        let changeFavoriteStatusRequest: APIRequest<EventFavorites> =
        sender.isActive ?
        HIAPI.EventService.unfavoriteBy(id: event.id) :
        HIAPI.EventService.favoriteBy(id: event.id)

        changeFavoriteStatusRequest
            .onCompletion { result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        sender.isActive.toggle()
                        event.favorite.toggle()
                        if event.favorite {
                            HILocalNotificationController.shared.scheduleNotification(for: event)
                        } else {
                            HILocalNotificationController.shared.unscheduleNotification(for: event)
                        }
                    }
                case .failure(let error):
                    print(error, error.localizedDescription)
                }
            }
            .authorize(with: HIApplicationStateController.shared.user)
            .launch()
    }

    @objc func didSelectCloseButton(_ sender: HIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIViewController
extension HIEventDetailViewController {

    override func loadView() {
        super.loadView()

        setupCloseButton()
        setupContainers()
        setupTitle()
        setupEventType()
        setupSponsor()
        // Only attendees can favorite events
        if !HIApplicationStateController.shared.isGuest {
            setupFavoritedButton()
        }
        setupTime()
        setupPoints()
        setupLocation()
        setupMap()
        setupDescription()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let event = event else { return }
        titleLabel.text = event.name
        if !event.sponsor.isEmpty {
            sponsorLabel.text = "Sponsored by \(event.sponsor)"
        } else {
            sponsorLabel.text = ""
        }
        descriptionLabel.text = event.info
        if event.startTime.timeIntervalSince1970 == 0 || event.endTime.timeIntervalSince1970 == 0 {
            // Default text for async events
            timeLabel.text = HIConstants.ASYNC_EVENT_TIME_TEXT
        } else {
            timeLabel.text = Formatter.simpleTime.string(from: event.startTime) + " - " + Formatter.simpleTime.string(from: event.endTime)
        }
        favoritedButton.isActive = event.favorite
        pointsLabel.text = "  + \(event.points) pts  "
        eventTypeLabel.text = "   \(event.eventType.lowercased().capitalized)   "
        view.layoutIfNeeded()
        let targetSize = CGSize(width: descriptionLabel.frame.width, height: .greatestFiniteMagnitude)
        let neededSize = descriptionLabel.sizeThatFits(targetSize)
        descriptionLabelHeight.constant = neededSize.height
        // Default text for online events
        locationLabel.text = HIConstants.ONLINE_EVENT_LOCATION_TEXT
        // check if this event has a location
        if event.locations.count > 0 {
            // concatenate all location names
            locationLabel.text = event.locations.map { ($0 as AnyObject).name }.joined(separator: ", ")
        }
        setupMap()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if event == nil {
            presentErrorController(title: "Uh oh", message: "Failed to load event.", dismissParentOnCompletion: true)
        }
    }

    func setupContainers() {
        view.addSubview(eventDetailContainer)
        eventDetailContainer.topAnchor.constraint(equalTo: closeButton.bottomAnchor).isActive = true
        eventDetailContainer.constrain(to: view.safeAreaLayoutGuide, trailingInset: -8, bottomInset: 0, leadingInset: 8)

        eventDetailContainer.addSubview(upperContainerView)
        upperContainerView.constrain(to: eventDetailContainer, topInset: 25, trailingInset: 0, leadingInset: 0)
        upperContainerView.constrain(height: 95)
    }
    func setupEventType() {
        upperContainerView.addSubview(eventTypeView)
        eventTypeView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        eventTypeView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        eventTypeView.addSubview(eventTypeLabel)
        eventTypeLabel.constrain(to: eventTypeView, topInset: 0, trailingInset: 0, bottomInset: 0, leadingInset: 0)
    }
    func setupSponsor() {
        upperContainerView.addSubview(sponsorLabel)
        sponsorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        sponsorLabel.topAnchor.constraint(equalTo: eventTypeLabel.bottomAnchor, constant: 5).isActive = true
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
        timeImageView.topAnchor.constraint(equalTo: sponsorLabel.bottomAnchor, constant: 10).isActive = true
        timeImageView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true

        upperContainerView.addSubview(timeLabel)
        timeLabel.centerYAnchor.constraint(equalTo: timeImageView.centerYAnchor).isActive = true
        timeLabel.leadingAnchor.constraint(equalTo: timeImageView.leadingAnchor, constant: 20).isActive = true
    }
    func setupPoints() {
        upperContainerView.addSubview(pointsView)
        pointsView.centerYAnchor.constraint(equalTo: eventTypeView.centerYAnchor).isActive = true
        pointsView.leadingAnchor.constraint(equalTo: eventTypeView.trailingAnchor, constant: 10).isActive = true
        pointsView.addSubview(pointsLabel)
        pointsLabel.constrain(to: pointsView, topInset: 0, trailingInset: 0, bottomInset: 0, leadingInset: 0)
    }
    func setupDescription() {
        eventDetailContainer.addSubview(descriptionLabel)
        descriptionLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 15).isActive = true
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
    func setupMap() {
        guard let event = event else { return }
        
        // Check if the image URL ends with "svg" and replace it with "png"
        var imageUrlString = event.mapImageUrl
        if imageUrlString.lowercased().hasSuffix("svg") {
            imageUrlString = imageUrlString.replacingOccurrences(of: "svg", with: "png")
        }
        
        if let mapUrl = URL(string: imageUrlString) {
            let session = URLSession.shared
            self.mapView.image = nil
            let task = session.dataTask(with: mapUrl) { (data, response, error) in
                if let error = error {
                    print("Error loading map image: \(error.localizedDescription)")
                    return
                }
                if let data = data {
                    DispatchQueue.main.async {
                        self.mapView.image = UIImage(data: data)
                        self.mapView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    }
                }
            }
            task.resume()
        }
        eventDetailContainer.addSubview(mapContainer)
        mapContainer.translatesAutoresizingMaskIntoConstraints = false
        mapContainer.leadingAnchor.constraint(equalTo: eventDetailContainer.leadingAnchor).isActive = true
        mapContainer.trailingAnchor.constraint(equalTo: eventDetailContainer.trailingAnchor).isActive = true
        mapContainer.topAnchor.constraint(equalTo: locationImageView.bottomAnchor, constant: 15).isActive = true
        let mapHeight: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 450 : 250
        mapContainer.constrain(height: mapHeight)
        
        mapContainer.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.leadingAnchor.constraint(equalTo: mapContainer.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: mapContainer.trailingAnchor).isActive = true
        mapView.topAnchor.constraint(equalTo: mapContainer.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: mapContainer.bottomAnchor).isActive = true
        mapView.layer.cornerRadius = 20
        mapView.isUserInteractionEnabled = true
        
        // Add pinch gesture recognizer
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        mapView.addGestureRecognizer(pinchGesture)
        
        // Add pan gesture recognizer
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.pan(sender:)))
        pan.delegate = self
        self.mapView.addGestureRecognizer(pan)
    }

    @objc func pan(sender: UIPanGestureRecognizer) {
        if self.isZooming && sender.state == .began {
            self.originalImageCenter = sender.view?.center
        } else if self.isZooming && sender.state == .changed {
            let translation = sender.translation(in: self.mapView)
        if let view = sender.view {
            view.center = CGPoint(x: view.center.x + translation.x,
                                  y: view.center.y + translation.y)
        }
        sender.setTranslation(CGPoint.zero, in: self.mapView.superview)
        }
    }
    
    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let view = gesture.view else {return}
        self.originalImageCenter = gesture.view?.center
        switch gesture.state {
        case .began:
            let currentScale = self.mapView.frame.size.width / self.mapView.bounds.size.width
            let newScale = currentScale * gesture.scale
            if newScale > 1 {
                self.isZooming = true
            }
        case .changed:
            let pinchCenter = CGPoint(x: gesture.location(in: view).x - view.bounds.midX,
            y: gesture.location(in: view).y - view.bounds.midY)
            let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
            .scaledBy(x: gesture.scale, y: gesture.scale)
            .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
            let currentScale = self.mapView.frame.size.width / self.mapView.bounds.size.width
            var newScale = currentScale*gesture.scale
            if newScale < 1 {
                newScale = 1
                let transform = CGAffineTransform(scaleX: newScale, y: newScale)
                self.mapView.transform = transform
                gesture.scale = 1
            } else {
                view.transform = transform
                gesture.scale = 1
            }
        case .ended:
            guard let center = self.originalImageCenter else {return}
            UIView.animate(withDuration: 0.3, animations: {
                // Reset the transform to the original size
                view.center = center
                view.transform = .identity
                view.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5) // Reset anchor point to center
            }, completion: { _ in
                self.isZooming = false
                })
        default:
            break
        }
    }

    func setupCloseButton() {
        view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(didSelectCloseButton(_:)), for: .touchUpInside)
        closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 12).isActive = true
        closeButton.constrain(height: 20)
    }
    func setupFavoritedButton() {
        view.addSubview(favoritedButton)
        favoritedButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        favoritedButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12).isActive = true
        favoritedButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        favoritedButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        favoritedButton.addTarget(self, action: #selector(didSelectFavoriteButton(_:)), for: .touchUpInside)
    }
}

// MARK: - UINavigationItem Setup
extension HIEventDetailViewController {
    @objc dynamic override func setupNavigationItem() {
        super.setupNavigationItem()
        title = "EVENT DETAILS"
    }
}

// MARK: - UIImageView Setup
extension HIEventDetailViewController {
    @objc dynamic override func setUpBackgroundView() {
        view.layer.backgroundColor = (\HIAppearance.contentBackground).value.cgColor
    }
}
