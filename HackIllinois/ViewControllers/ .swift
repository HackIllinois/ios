//
//  HIEventListViewController.swift
//  HackIllinois
//
//  Created by HackIllinois Team on 1/12/18.
//  Copyright © 2018 HackIllinois. All rights reserved.
//  This file is part of the Hackillinois iOS App.
//  The Hackillinois iOS App is open source software, released under the University of
//  Illinois/NCSA Open Source License. You should have received a copy of
//  this license in a file with the distribution.
//

import Foundation
import UIKit
import HIAPI
import APIManager

class HIEventListViewController: HIBaseViewController {
    let eventDetailViewController = HIEventDetailViewController()
}

// MARK: - UITableView Setup
extension HIEventListViewController {
    override func setupTableView() {
        if let tableView = tableView {
            tableView.register(HIDateHeader.self, forHeaderFooterViewReuseIdentifier: HIDateHeader.identifier)
            tableView.register(HIEventCell.self, forCellReuseIdentifier: HIEventCell.identifier)
            #warning("I don't think this is being used. Related to 3D touch and previewing")
//            registerForPreviewing(with: self, sourceView: tableView)
        }
        super.setupTableView()
    }
}

// MARK: - UITableViewDataSource
extension HIEventListViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HIEventCell.identifier, for: indexPath)
        if let cell = cell as? HIEventCell, let event = _fetchedResultsController?.object(at: indexPath) as? Event {
            cell <- event
            cell.delegate = self
            cell.indexPath = indexPath
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HIEventListViewController {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let event = _fetchedResultsController?.object(at: indexPath) as? Event else {
            return CGFloat.leastNonzeroMagnitude
        }
        return HIEventCell.heightForCell(with: event, width: tableView.frame.width)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        eventDetailViewController.event = _fetchedResultsController?.object(at: indexPath) as? Event
        self.present(eventDetailViewController, animated: true, completion: nil)
        super.tableView(tableView, didSelectRowAt: indexPath)
    }
}

// MARK: - UIRefreshControl
extension HIEventListViewController {
    override func refresh(_ sender: UIRefreshControl) {
        super.refresh(sender)
        HIEventDataSource.refresh(completion: endRefreshing)
    }
}

// MARK: - HIEventCellDelegate
extension HIEventListViewController: HIEventCellDelegate {
    // This method is necessary to refresh the indecies and sections in the table view controller
    func fetchAndReloadData() {
        try? _fetchedResultsController?.performFetch()
        tableView?.reloadData()
    }
    
    func eventCellDidSelectFavoriteButton(_ eventCell: HIEventCell) {
        guard let indexPath = eventCell.indexPath else { return }
        // Ensure the section and item indices are within bounds
        guard indexPath.section < _fetchedResultsController?.sections?.count ?? 0,
            indexPath.item < _fetchedResultsController?.sections?[indexPath.section].numberOfObjects ?? 0 else {
           return
        }
        guard let event = _fetchedResultsController?.object(at: indexPath) as? Event else { return }
        guard let user = HIApplicationStateController.shared.user else { return }

        let changeFavoriteStatusRequest: APIRequest<FollowStatus> =
            eventCell.favoritedButton.isActive ?
        HIAPI.UserService.unfavoriteEvent(userToken: user.token, eventID: event.id) :
        HIAPI.UserService.favoriteEvent(userToken: user.token, eventID: event.id)

        changeFavoriteStatusRequest
        .onCompletion { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    event.favorite.toggle()
                    if event.favorite {
                        HILocalNotificationController.shared.scheduleNotification(for: event)
                    } else {
                        HILocalNotificationController.shared.unscheduleNotification(for: event)
                    }
                    // Call the fetchAndReloadData method to update the fetched results controller and reload the table view, otherwise index and section of next events will be incorrect
                    self.fetchAndReloadData()
                }
            case .failure(let error):
                print(error, error.localizedDescription)
            }
        }
        .authorize(with: HIApplicationStateController.shared.user)
        .launch()
    }
}

#warning("I don't think this is being used. Related to 3D touch and previewing")
// MARK: - UIViewControllerPreviewingDelegate
//extension HIEventListViewController: UIViewControllerPreviewingDelegate {
//    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
//        guard let tableView = tableView,
//            let indexPath = tableView.indexPathForRow(at: location),
//            let event = _fetchedResultsController?.object(at: indexPath) as? Event else {
//                return nil
//        }
//        previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
//        eventDetailViewController.event = event
//        return eventDetailViewController
//    }
//
//    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
//        self.present(viewControllerToCommit, animated: true, completion: nil)
//    }
//}
