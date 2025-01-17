//
//  HIScheduleViewController.swift
//  HackIllinois
//
//  Created by HackIllinois Team on 11/19/17.
//  Copyright © 2017 HackIllinois. All rights reserved.
//  This file is part of the Hackillinois iOS App.
//  The Hackillinois iOS App is open source software, released under the University of
//  Illinois/NCSA Open Source License. You should have received a copy of
//  this license in a file with the distribution.
//

import Foundation
import UIKit
import CoreData
import HIAPI

class HIScheduleViewController: HIEventListViewController {
    // MARK: - Properties
    var staffShifts: [Staff] = []
    private var labelColor: UIColor = .white // Default color
    var hasSelectedShift = false
    var segmentedControl: HIScheduleSegmentedControl!
    
    lazy var fetchedResultsController: NSFetchedResultsController<Event> = {
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()

        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "startTime", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
        ]

        fetchRequest.predicate = currentPredicate()

        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: HICoreDataController.shared.viewContext,
            sectionNameKeyPath: "sectionIdentifier",
            cacheName: nil
        )

        fetchedResultsController.delegate = self

        return fetchedResultsController
    }()
    
    private var currentTab = 0
    private var onlyFavorites = false
    private let onlyFavoritesPredicate = NSPredicate(format: "favorite == YES" )
    private var dataStore: [(displayText: String, predicate: NSPredicate)] = {
        var dataStore = [(displayText: String, predicate: NSPredicate)]()
        let fridayPredicate = NSPredicate(
            format: "%@ =< startTime AND startTime < %@",
            HITimeDataSource.shared.eventTimes.fridayStart as NSDate,
            HITimeDataSource.shared.eventTimes.fridayEnd as NSDate
        )
        dataStore.append((displayText: "FRI", predicate: fridayPredicate))

        let saturdayPredicate = NSPredicate(
            format: "%@ =< startTime AND startTime < %@",
            HITimeDataSource.shared.eventTimes.saturdayStart as NSDate,
            HITimeDataSource.shared.eventTimes.saturdayEnd as NSDate
        )
        dataStore.append((displayText: "SAT", predicate: saturdayPredicate))

        let sundayPredicate = NSPredicate(
            format: "%@ =< startTime AND startTime < %@",
            HITimeDataSource.shared.eventTimes.sundayStart as NSDate,
            HITimeDataSource.shared.eventTimes.sundayEnd as NSDate
        )
        dataStore.append((displayText: "SUN", predicate: sundayPredicate))

        return dataStore
    }()
    
    // Staff shifts functionality
    private var onlyShifts = false

    @objc dynamic override func setUpBackgroundView() {
        super.setUpBackgroundView()
        backgroundView.image = #imageLiteral(resourceName: "ScheduleBackground")
        if UIDevice.current.userInterfaceIdiom == .pad {
            backgroundView.image = #imageLiteral(resourceName: "BackgroundPad")
        }
    }
}

// MARK: - Actions
extension HIScheduleViewController {
    @objc func didSelectTab(_ sender: HISegmentedControl) {
        if hasSelectedShift {
            removeStaffShiftContainerViews()
            setUpShiftCells()
        }
        currentTab = sender.selectedIndex
        updatePredicate()
        animateReload()
    }

    @objc func didSelectFavoritesIcon(_ sender: UIBarButtonItem) {
        onlyFavorites = !onlyFavorites
        sender.image = onlyFavorites ? #imageLiteral(resourceName: "Big Selected Bookmark") : #imageLiteral(resourceName: "Big Unselected Bookmark")
        if UIDevice.current.userInterfaceIdiom == .pad {
            sender.image = onlyFavorites ? #imageLiteral(resourceName: "BookmarkSelected") : #imageLiteral(resourceName: "BookmarkUnselected")
        }
        if sender.image == #imageLiteral(resourceName: "Big Selected Bookmark") {
            super.setCustomTitle(customTitle: "SAVED EVENTS")
        } else {
            super.setCustomTitle(customTitle: "SCHEDULE")
        }
        updatePredicate()
        animateReload()
    }

    func updatePredicate() {
        fetchedResultsController.fetchRequest.predicate = currentPredicate()
    }

    func currentPredicate() -> NSPredicate {
        let currentTabPredicate = dataStore[currentTab].predicate
        if onlyFavorites {
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [currentTabPredicate, onlyFavoritesPredicate])
            return compoundPredicate
        } else if onlyShifts {
            let noEventsPredicate = NSPredicate(value: false)
            return noEventsPredicate
        } else {
            return currentTabPredicate
        }
    }

    func animateReload() {
        try? fetchedResultsController.performFetch()
        animateTableViewReload()
        if let tableView = tableView, !tableView.visibleCells.isEmpty {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }
}

// MARK: - UIViewController
extension HIScheduleViewController {
    override func loadView() {
        super.loadView()

        let items = dataStore.map { $0.displayText }
        segmentedControl = HIScheduleSegmentedControl(titles: items, nums: [23, 24, 25])
        segmentedControl.addTarget(self, action: #selector(didSelectTab(_:)), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)
        var segmentedControlConstant: CGFloat = 0.0
        if UIDevice.current.userInterfaceIdiom == .pad {
            segmentedControlConstant = 40.0
        }

        segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15 + segmentedControlConstant).isActive = true
        segmentedControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: -36).isActive = true
        segmentedControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 40).isActive = true
        segmentedControl.heightAnchor.constraint(equalToConstant: 66 + segmentedControlConstant).isActive = true
        
        // Start the segmented control on the current day
        let now = Date()
        if now > HITimeDataSource.shared.eventTimes.sundayStart {
            segmentedControl.selectedIndex = 2
            currentTab = 2
        }
        else if now > HITimeDataSource.shared.eventTimes.saturdayStart {
            segmentedControl.selectedIndex = 1
            currentTab = 1
        }
        
        let tableView = HITableView()
        view.addSubview(tableView)
        let padConstant = (UIDevice.current.userInterfaceIdiom == .pad) ? 4.0 : 1
        tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 40 * padConstant).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.contentInset = UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 17, left: 0, bottom: 0, right: 0)
        self.tableView = tableView
        
        tableView.addLeftAndRightSwipeGestureRecognizers(
            target: segmentedControl,
            selector: #selector(segmentedControl.handleSwipeGesture(_:))
        )
    }

    override func viewDidLoad() {
        _fetchedResultsController = fetchedResultsController as? NSFetchedResultsController<NSManagedObject>
        setupRefreshControl()
        super.viewDidLoad()
        guard let user = HIApplicationStateController.shared.user else { return }
        if !user.roles.contains(.STAFF) {
            super.setCustomTitle(customTitle: "SCHEDULE")
        } else if user.roles.contains(.STAFF) {
            setStaffShiftsControl()
        }
    }
}

// MARK: - Staff Shifts Control Setup

extension HIScheduleViewController {
    @objc func setStaffShiftsControl() {
        let customFontSize = UIDevice.current.userInterfaceIdiom == .pad ? 48 : 24
        let customFont = UIFont(name: "MontserratRoman-Bold", size: CGFloat(customFontSize))

        // Create flexible space items to add space to the left
        let flexibleSpaceLeft1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let flexibleSpaceLeft2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let flexibleSpaceLeft3 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let scheduleButton = UIBarButtonItem(title: "SCHEDULE", style: .plain, target: self, action: #selector(scheduleButtonTapped(_:)))
        scheduleButton.setTitleTextAttributes([NSAttributedString.Key.font: customFont, NSAttributedString.Key.foregroundColor: labelColor], for: .normal)

        // Add the flexible space items and custom button to the leftBarButtonItems array
        navigationItem.leftBarButtonItems = [flexibleSpaceLeft1, flexibleSpaceLeft2, flexibleSpaceLeft3, scheduleButton]

        // Create flexible space items to add space to the right
        let flexibleSpaceRight1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let flexibleSpaceRight2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        // Create custom right bar button item
        let customButton = UIBarButtonItem(title: "SHIFTS", style: .plain, target: self, action: #selector(shiftsButtonTapped(_:)))
        customButton.setTitleTextAttributes([NSAttributedString.Key.font: customFont, NSAttributedString.Key.foregroundColor: labelColor], for: .normal)

        // Add the flexible space items and custom button to the rightBarButtonItems array
        navigationItem.rightBarButtonItems = [flexibleSpaceRight1, flexibleSpaceRight2, customButton]

        self.navigationItem.leftItemsSupplementBackButton = true
    }
    
    func removeStaffShiftContainerViews() {
        // Iterate through all subviews and remove container views for staff shifts
        for subview in self.view.subviews {
            if let containerView = subview as? UIView, containerView.backgroundColor == #colorLiteral(red: 1, green: 0.9803921569, blue: 0.8, alpha: 1) {
                containerView.removeFromSuperview()
            }
        }
    }
    
    // Actions for left and right buttons
    @objc func scheduleButtonTapped(_ sender: UIButton) {
        if onlyShifts {
            onlyShifts = false
            backgroundView.image = #imageLiteral(resourceName: "ScheduleBackground")
            labelColor = .white // Set label color to brown
            setStaffShiftsControl()
            // Call removeStaffShiftContainerViews to remove container views for staff shifts
            hasSelectedShift = false
            removeStaffShiftContainerViews()
            updatePredicate()
            animateReload()
        }
    }

    @objc func shiftsButtonTapped(_ sender: UIButton) {
        if !onlyShifts {
            onlyShifts = !onlyShifts
            backgroundView.image = #imageLiteral(resourceName: "Pink Background")
            hasSelectedShift = true
            labelColor = #colorLiteral(red: 0.337254902, green: 0.1411764706, blue: 0.06666666667, alpha: 1) // Set label color to brown
            setStaffShiftsControl()

            guard let user = HIApplicationStateController.shared.user else { return }

            HIAPI.StaffService.getStaffShift(userToken: user.token)
                .onCompletion { result in
                    do {
                        let (staffShifts, _) = try result.get()
                        self.staffShifts = staffShifts.shifts

                        DispatchQueue.main.async {
                            // Set up shift cells
                            self.setUpShiftCells()
                            // Update predicate and animate reload
                            self.updatePredicate()
                            self.animateReload()
                        }

                    } catch {
                        print("An error has occurred in getting staff shifts \(error)")
                    }
                }
                .launch()
        }
    }
    
    func setUpShiftCells() {
        // Get filtered events by date
        let sundayStart = HITimeDataSource.shared.eventTimes.sundayStart
        let saturdayStart = HITimeDataSource.shared.eventTimes.saturdayStart
        var padding = 0.0
        // Iterate through each staff shift and add a label to the container view
        for (index, staffShift) in self.staffShifts.enumerated() {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            let dateString = staffShift.startTime
            let calendar = Calendar.current
            let dayComponent = calendar.component(.day, from: dateString)
            var curr_idx = segmentedControl.selectedIndex
            if curr_idx == 0 && dayComponent != 23 {
                continue
            } else if curr_idx == 1 && dayComponent != 24 {
                continue
            } else if curr_idx == 2 && dayComponent != 25 {
                continue
            }
            // Set fixed width and height for the container view
            let containerViewWidth: CGFloat = UIScreen.main.bounds.width > 850 ? 820 : ((UIDevice.current.userInterfaceIdiom == .pad) ? 620 : 340.0)
            let containerViewHeight: CGFloat = UIScreen.main.bounds.width > 850 ? 250 : ((UIDevice.current.userInterfaceIdiom == .pad) ? 200 : 130.0)
    
            // Create a container view with a yellow background
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.backgroundColor = #colorLiteral(red: 1, green: 0.9803921569, blue: 0.8, alpha: 1)
            containerView.layer.cornerRadius = 20.0
            containerView.layer.masksToBounds = true

            // Add the container view to the main view
            self.view.addSubview(containerView)

            // Set up constraints for the fixed width and height
            NSLayoutConstraint.activate([
                containerView.widthAnchor.constraint(equalToConstant: containerViewWidth),
                containerView.heightAnchor.constraint(equalToConstant: containerViewHeight),
                containerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                containerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: ((UIDevice.current.userInterfaceIdiom == .pad) ? 400 : 275) + padding)
            ])
            containerView.tag = index
            
            // Add UITapGestureRecognizer to the containerView
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(containerViewTapped(_:)))
            containerView.addGestureRecognizer(tapGesture)
            
            let label = HILabel(style: .smallEvent)
            label.text = staffShift.name
            label.translatesAutoresizingMaskIntoConstraints = false

            // Add the label to the container view
            containerView.addSubview(label)

            // Set up constraints for the labels within the container view
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15.0),
                label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20.0)
            ])
            
            // Add time, location, and description labels to shift cells
            // Time label set up
            var eventCellSpacing: CGFloat = 8.0
            let locationImageName = (UIDevice.current.userInterfaceIdiom == .pad) ? "VectorPad" : "LocationSign"
            let timeImageName = (UIDevice.current.userInterfaceIdiom == .pad) ? "TimePad" : "Clock"
            var locationImageView = UIImageView(image: #imageLiteral(resourceName: "\(locationImageName)")); var timeImageView = UIImageView(image: #imageLiteral(resourceName: "\(timeImageName)"))
            let timeLabel = HILabel(style: .time)
            timeLabel.text = Formatter.simpleTime.string(from: staffShift.startTime) + " - " + Formatter.simpleTime.string(from: staffShift.endTime)
            containerView.addSubview(timeImageView)
            timeImageView.translatesAutoresizingMaskIntoConstraints = false
            timeImageView.leadingAnchor.constraint(equalTo: label.leadingAnchor).isActive = true
            timeImageView.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant:  UIScreen.main.bounds.width > 850 ? 50 : ((UIDevice.current.userInterfaceIdiom == .pad) ? 40 : 25.0)).isActive = true
            containerView.addSubview(timeLabel)
            timeLabel.leadingAnchor.constraint(equalTo: timeImageView.trailingAnchor, constant: eventCellSpacing).isActive = true
            timeLabel.centerYAnchor.constraint(equalTo: timeImageView.centerYAnchor).isActive = true
            
            // Location label set up
            let locationLabel = HILabel(style: .newLocation)
            if staffShift.locations.count > 0 {
                locationLabel.text = staffShift.locations.map { $0.name }.joined(separator: ", ")
            } else {
                locationLabel.text = "No Location"
            }
            containerView.addSubview(locationImageView)
            locationImageView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(locationLabel)
            locationImageView.leadingAnchor.constraint(equalTo: timeImageView.leadingAnchor, constant: (UIDevice.current.userInterfaceIdiom == .pad ? 5.0 : 2.0)).isActive = true
            locationImageView.bottomAnchor.constraint(equalTo: timeImageView.bottomAnchor, constant: UIScreen.main.bounds.width > 850 ? 50 : ((UIDevice.current.userInterfaceIdiom == .pad) ? 40 : 25.0)).isActive = true
            locationLabel.leadingAnchor.constraint(equalTo: timeLabel.leadingAnchor).isActive = true
            locationLabel.centerYAnchor.constraint(equalTo: locationImageView.centerYAnchor).isActive = true
            
            // Description label set up
            let descriptionLabel = HILabel(style: .cellDescription)
            descriptionLabel.numberOfLines = 1
            descriptionLabel.text = "\(staffShift.description)"
            containerView.addSubview(descriptionLabel)
            descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            descriptionLabel.leadingAnchor.constraint(equalTo: locationImageView.leadingAnchor).isActive = true
            descriptionLabel.bottomAnchor.constraint(equalTo: locationImageView.bottomAnchor, constant: UIScreen.main.bounds.width > 850 ? 50 : ((UIDevice.current.userInterfaceIdiom == .pad) ? 40 : 25.0)).isActive = true
            descriptionLabel.constrain(width: containerViewWidth - 40)
            padding += UIScreen.main.bounds.width > 850 ? 300 : ((UIDevice.current.userInterfaceIdiom == .pad) ? 210 : 140.0)
        }
    }
    @objc func containerViewTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedIndex = sender.view?.tag else {
                return
            }

            let selectedShift = self.staffShifts[tappedIndex]

            let viewControllerToPresent = HIShiftDetailViewController()
            viewControllerToPresent.modalPresentationStyle = .popover

            // Pass data to HIShiftDetailViewController
            viewControllerToPresent.shiftName = selectedShift.name
            viewControllerToPresent.shiftTime = "\(Formatter.simpleTime.string(from: selectedShift.startTime)) - \(Formatter.simpleTime.string(from: selectedShift.endTime))"
            
            if selectedShift.locations.count > 0 {
                viewControllerToPresent.shiftLocation = selectedShift.locations.map { $0.name }.joined(separator: ", ")
            } else {
                viewControllerToPresent.shiftLocation = "No Location"
            }

            viewControllerToPresent.shiftDescription = selectedShift.description
            if let popoverPresentationController = viewControllerToPresent.popoverPresentationController {
                popoverPresentationController.sourceView = sender.view
                popoverPresentationController.sourceRect = sender.view?.bounds ?? CGRect.zero
            }

            self.present(viewControllerToPresent, animated: true, completion: nil)
    }
}


// MARK: - UINavigationItem Setup
extension HIScheduleViewController {
    @objc dynamic override func setupNavigationItem() {
        super.setupNavigationItem()
        if !HIApplicationStateController.shared.isGuest {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "MenuUnfavorited"), style: .plain, target: self, action: #selector(didSelectFavoritesIcon(_:)))
            if UIDevice.current.userInterfaceIdiom == .pad {
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "BookmarkUnselected"), style: .plain, target: self, action: #selector(didSelectFavoritesIcon(_:)))
            }
        }
    }

    override func didMove(toParent parent: UIViewController?) {
        if let navController = navigationController as? HINavigationController {
            navController.infoTitleIsHidden = false
        }
    }
}

// MARK: - UITabBarItem Setup
extension HIScheduleViewController {
    override func setupTabBarItem() {
        tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "schedule"), selectedImage: #imageLiteral(resourceName: "ScheduleSelected"))
    }
}

// MARK: - UITableViewDelegate
extension HIScheduleViewController {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 60
        } else {
            return 30 // Changes height between event cells
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return super.numberOfSections(in: tableView)
    }
}

// MARK: - UITableViewDataSource
extension HIScheduleViewController {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: HIDateHeader.identifier)
        if let header = header as? HIDateHeader,
            let sections = fetchedResultsController.sections,
            section < sections.count,
            let date = Formatter.coreData.date(from: sections[section].name) {
            header.titleLabel.text = Formatter.simpleTime.string(from: date)
            header.titleLabel.textColor <- \.white
            header.titleLabel.textAlignment = .center
            if UIDevice.current.userInterfaceIdiom == .pad {
                header.titleLabel.font = HIAppearance.Font.timeIndicator
            } else {
                header.titleLabel.font = HIAppearance.Font.dateHeader
            }

        }
        return header
    }
}
