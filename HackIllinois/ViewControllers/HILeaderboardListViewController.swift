//
//  HILeaderboardListViewController.swift
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
import HIAPI
import APIManager

class HILeaderboardListViewController: HIBaseViewController {

}

// MARK: - UITableView Setup
extension HILeaderboardListViewController {
    override func setupTableView() {
        if let tableView = tableView {
            tableView.register(HILeaderboardCell.self, forCellReuseIdentifier: HILeaderboardCell.identifier)
        }
        
        super.setupTableView()
    }
}

// MARK: - UITableViewDataSource
extension HILeaderboardListViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HILeaderboardCell.identifier, for: indexPath)
        if let cell = cell as? HILeaderboardCell, let leaderboardProfile = _fetchedResultsController?.object(at: indexPath) as? LeaderboardProfile {
            cell <- leaderboardProfile
            cell.indexPath = indexPath
            cell.rankLabel.text = "\((indexPath.row) + 1)"
            cell.backgroundColor = .clear
            
            cell.cellView.backgroundColor = #colorLiteral(red: 0.7882352941, green: 0.8235294118, blue: 0.8980392157, alpha: 1)

            // Round certain corners based on row
            if indexPath.row == 0 {
                cell.cellView.layer.cornerRadius = 20
                cell.cellView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                cell.separatorView.isHidden = false
            } else if indexPath.row == 9 {
                cell.cellView.layer.cornerRadius = 20
                cell.cellView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                cell.separatorView.isHidden = true
            } else {
                cell.cellView.layer.cornerRadius = 0
                cell.separatorView.isHidden = false
            }
        }

        return cell
    }
}

// MARK: - UITableViewDelegate
extension HILeaderboardListViewController {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tHeight = tableView.frame.height
        let rHeight = tHeight / 10
        return rHeight
    }
}
