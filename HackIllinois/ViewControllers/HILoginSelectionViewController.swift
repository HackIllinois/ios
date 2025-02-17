//
//  HILoginSelectionViewController.swift
//  HackIllinois
//
//  Created by HackIllinois Team on 11/30/17.
//  Copyright © 2017 HackIllinois. All rights reserved.
//  This file is part of the Hackillinois iOS App.
//  The Hackillinois iOS App is open source software, released under the University of
//  Illinois/NCSA Open Source License. You should have received a copy of
//  this license in a file with the distribution.
//

import Foundation
import UIKit
import HIAPI

protocol HILoginSelectionViewControllerDelegate: AnyObject {
    func loginSelectionViewController(_ loginSelectionViewController: HILoginSelectionViewController, didMakeLoginSelection selection: HIAPI.AuthService.OAuthProvider)
}

class HILoginSelectionViewController: HIBaseViewController {
    // MARK: - Properties
    weak var delegate: HILoginSelectionViewControllerDelegate?
    private let logoImage = HIImageView {
        $0.translatesAutoresizingMaskIntoConstraints = false
        if UIDevice.current.userInterfaceIdiom == .pad {
            $0.hiImage = \.loginLogoPad
        } else {
            $0.hiImage = \.loginLogo
        }
        $0.contentMode = .scaleAspectFit
    }
    private let welcomeHeader = HILabel(style: .welcomeTitle)
    private let spacerView = HIView {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isHidden = true
        $0.isUserInteractionEnabled = false
    }

    // MARK: - Init
    convenience init(delegate: HILoginSelectionViewControllerDelegate) {
        self.init(nibName: nil, bundle: nil)
        self.delegate = delegate
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) should not be used.")
    }

    @objc dynamic override func setUpBackgroundView() {
        super.setUpBackgroundView()
        if UIDevice.current.userInterfaceIdiom == .pad {
            backgroundView.image = UIImage(named: "LoginBackgroundPadNew")
        } else {
            backgroundView.image = UIImage(named: "Login")
        }
    }
}

// MARK: - UIViewController
extension HILoginSelectionViewController {
    override func loadView() {
        super.loadView()
        let tableView = HITableView()
        tableView.alwaysBounceVertical = false
        view.addSubview(welcomeHeader)
        view.addSubview(logoImage)
        view.addSubview(tableView)
        if UIDevice.current.userInterfaceIdiom == .pad {
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
            tableView.widthAnchor.constraint(equalToConstant: 700).isActive = true
            tableView.heightAnchor.constraint(equalToConstant: 370).isActive = true
            tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 150).isActive = true
            logoImage.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -20).isActive = true
            logoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            logoImage.heightAnchor.constraint(equalToConstant: 250).isActive = true
            welcomeHeader.text = "WELCOME TO"
            welcomeHeader.bottomAnchor.constraint(equalTo: logoImage.topAnchor, constant: -25).isActive = true
            welcomeHeader.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            welcomeHeader.heightAnchor.constraint(equalToConstant: 30).isActive = true
        } else {
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
            tableView.widthAnchor.constraint(equalToConstant: 220).isActive = true
            tableView.heightAnchor.constraint(equalToConstant: 240).isActive = true
            tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 175).isActive = true
            logoImage.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -20).isActive = true
            logoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            logoImage.heightAnchor.constraint(equalToConstant: 250).isActive = true
            welcomeHeader.text = "WELCOME TO"
            welcomeHeader.bottomAnchor.constraint(equalTo: logoImage.topAnchor, constant: -15).isActive = true
            welcomeHeader.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            welcomeHeader.heightAnchor.constraint(equalToConstant: 22).isActive = true
        }

        tableView.isScrollEnabled = false
        self.tableView = tableView
    }
}

// MARK: - UITableView Setup
extension HILoginSelectionViewController {
    override func setupTableView() {
        tableView?.register(HILoginSelectionCell.self, forCellReuseIdentifier: HILoginSelectionCell.identifier)
        super.setupTableView()
    }
}

// MARK: - UITableViewDataSource
extension HILoginSelectionViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HIAPI.AuthService.OAuthProvider.all.count + 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Non-interactable text tableviewcells
        if indexPath.row == 0 || indexPath.row == 2 {
            let titleCell = UITableViewCell()
            titleCell.backgroundColor = UIColor.clear
            titleCell.contentView.backgroundColor = UIColor.clear
            titleCell.backgroundView?.backgroundColor = UIColor.clear
            titleCell.textLabel?.textAlignment = .center
            titleCell.textLabel?.backgroundColor = UIColor.clear
            titleCell.selectionStyle = .none // Prevents the "- OR -" cell from being clickable
            if indexPath.row == 0 {
                titleCell.textLabel?.text = "LOGIN"
                titleCell.textLabel?.font = HIAppearance.Font.loginTitle
                titleCell.textLabel?.textColor = .black

            } else {
                titleCell.textLabel?.text = "- OR -"
                titleCell.textLabel?.font = HIAppearance.Font.loginOrTitle
                titleCell.textLabel?.textColor = .black
            }
            return titleCell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: HILoginSelectionCell.identifier, for: indexPath)
        if let cell = cell as? HILoginSelectionCell {
            cell.titleLabel.textColor = UIColor.white
            cell.activeColor = .clear
            // Attendee cell
            if indexPath.row == 1 {
                cell.titleLabel.text = HIAPI.AuthService.OAuthProvider.all[0].displayName
                cell.defaultColor = (\HIAppearance.attendeeBackground).value
                cell.titleLabel.layer.borderColor = (\HIAppearance.attendeeBackground).value.cgColor
                cell.defaultTextColor = .white
                cell.activeTextColor = .white
            } else if indexPath.row > 2 { //After "- OR -" cell roles
                cell.titleLabel.text = HIAPI.AuthService.OAuthProvider.all[indexPath.row - 2].displayName
                cell.defaultColor = .clear
                cell.titleLabel.layer.borderColor = (\HIAppearance.loginDefault).value.cgColor
                cell.defaultTextColor = .black
                cell.activeTextColor = .black
            }
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            cell.titleLabel.layer.cornerRadius = cell.frame.height*(3/8)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

// MARK: - UITableViewDelegate
extension HILoginSelectionViewController {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIDevice.current.userInterfaceIdiom == .pad ? 70 : 45
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Prevents the "- OR -" cell from being clickable
        if indexPath.row == 0 || indexPath.row == 2 {
            return
        }

        if let delegate = delegate {
            if indexPath.row == 1 {
                let selection = HIAPI.AuthService.OAuthProvider.all[0]
                delegate.loginSelectionViewController(self, didMakeLoginSelection: selection)
            } else if indexPath.row > 2 {
                let selection = HIAPI.AuthService.OAuthProvider.all[indexPath.row - 2]
                delegate.loginSelectionViewController(self, didMakeLoginSelection: selection)
                }
        }
        super.tableView(tableView, didSelectRowAt: indexPath)
    }
}
