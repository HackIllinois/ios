//
//  HILeaderboardViewController.swift
//  HackIllinois
//
//  Created by HackIllinois Team on 11/03/21.
//  Copyright © 2021 HackIllinois. All rights reserved.
//  This file is part of the Hackillinois iOS App.
//  The Hackillinois iOS App is open source software, released under the University of
//  Illinois/NCSA Open Source License. You should have received a copy of
//  this license in a file with the distribution.
//

import Foundation
import UIKit
import CoreData

class HILeaderboardViewController: HILeaderboardListViewController {
     // MARK: - Properties
    lazy var fetchedResultsController: NSFetchedResultsController<LeaderboardProfile> = {
        let fetchRequest: NSFetchRequest<LeaderboardProfile> = LeaderboardProfile.fetchRequest()

        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "points", ascending: false),
            NSSortDescriptor(key: "discord", ascending: true)
        ]

        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: HICoreDataController.shared.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        fetchedResultsController.delegate = self

        return fetchedResultsController
    }()

    @objc dynamic override func setUpBackgroundView() {
        super.setUpBackgroundView()
        backgroundView.image = #imageLiteral(resourceName: "ProfileBackground")
    }
}

// MARK: - UITabBarItem Setup
extension HILeaderboardViewController {
    override func setupTabBarItem() {
        tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "leaderboard"), selectedImage: UIImage(named: "LeaderboardSelected"))
    }
}

// MARK: - Actions
extension HILeaderboardViewController {
    func animateReload() {
        try? fetchedResultsController.performFetch()
        animateTableViewReload()
        if let tableView = tableView, !tableView.visibleCells.isEmpty {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }
}

// MARK: - UIViewController
extension HILeaderboardViewController {
    override func loadView() {
        super.loadView()
        layoutProfiles()
    }

    func layoutProfiles() {
        // Add tableView to handle leaderboard
        var padConstant = 1.0
        if UIDevice.current.userInterfaceIdiom == .pad {
            padConstant = 2.0
        }
        let tableView = HITableView()
        view.addSubview(tableView)
        tableView.layer.cornerRadius = 8
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15 * padConstant).isActive = true
        tableView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.90).isActive = true
        tableView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 1).isActive = true
        tableView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        self.tableView = tableView
    }

    override func viewWillAppear(_ animated: Bool) {
        HIProfileDataSource.refresh(completion: endRefreshing)
    }

    override func viewDidLoad() {
        _fetchedResultsController = fetchedResultsController as? NSFetchedResultsController<NSManagedObject>
        setupRefreshControl()
        setCustomTitle(customTitle: "LEADERBOARD")
        super.viewDidLoad()
    }
}

// MARK: - UITableViewDelegate
extension HILeaderboardViewController {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
    }
}

// MARK: - UIRefreshControl
extension HILeaderboardViewController {
    override func refresh(_ sender: UIRefreshControl) {
        super.refresh(sender)
        HIProfileDataSource.refresh(completion: endRefreshing)
    }
}
