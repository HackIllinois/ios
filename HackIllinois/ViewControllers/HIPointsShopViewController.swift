//
//  HIPointsShopViewController.swift
//  HackIllinois
//
//  Created by HackIllinois on 12/19/23.
//  Copyright © 2023 HackIllinois. All rights reserved.
//


import Foundation
import CoreData
import UIKit
import HIAPI
import SwiftUI

class HIPointsShopViewController: HIBaseViewController {
    // MARK: - Properties
    private var profile = HIProfile()
}

// MARK: - UITabBarItem Setup
extension HIPointsShopViewController {
    override func setupTabBarItem() {
        tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "leaderboard"), selectedImage: #imageLiteral(resourceName: "leaderboard"))
    }
}

// MARK: - UIViewController
extension HIPointsShopViewController {
    override func loadView() {
        super.loadView()
        let swiftUIView = HIPointShopSwiftUIView()
            let hostingController = UIHostingController(rootView: swiftUIView)
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        hostingController.didMove(toParent: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        super.setCustomTitle(customTitle: "POINT SHOP")
    }
}

// MARK: - API
extension HIPointsShopViewController {
}

// MARK: - UITableViewDelegate
extension HIPointsShopViewController {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
    }
}

// MARK: - HIErrorViewDelegate
extension HIPointsShopViewController: HIErrorViewDelegate {
    func didSelectErrorLogout(_ sender: UIButton) {
    }
}
