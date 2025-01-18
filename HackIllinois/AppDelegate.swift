//
//  AppDelegate.swift
//  HackIllinois
//
//  Created by HackIllinois Team on 4/16/17.
//  Copyright © 2017 HackIllinois. All rights reserved.
//  This file is part of the Hackillinois iOS App.
//  The Hackillinois iOS App is open source software, released under the University of
//  Illinois/NCSA Open Source License. You should have received a copy of
//  this license in a file with the distribution.
//

import UIKit
import CoreLocation
import UserNotifications
import HIAPI
import GoogleMaps
import Firebase
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    private var obfuscatedApiKey: [UInt8] = [92, 213, 228, 193, 244, 27, 239, 139, 188, 14, 85, 191, 47, 237, 55, 13, 85, 89, 111, 212, 35, 80, 45, 104, 189, 229,
                                   33, 32, 70, 63, 90, 163, 173, 232, 167, 90, 203, 22, 169, 29, 156, 158, 160, 167, 98,
                                   174, 239, 247, 118, 96, 207, 104, 180, 14, 90, 58, 61, 89, 186, 89, 7, 114, 25, 255, 141,
                                   115, 113, 117, 78, 10, 150, 197, 161, 158, 98, 129, 87, 228]
    var fcmToken: String?
    // Handle remote notification registration.
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        guard let user = HIApplicationStateController.shared.user else { return }
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().delegate = self

        // Send the token to notifications server
        if let unwrappedToken = fcmToken {
            NotificationService.sendDeviceToken(deviceToken: unwrappedToken)
                    .onCompletion { result in
                        do {
                            _ = try result.get()
                        } catch {
                            print(error)
                        }
                    }
                    .authorize(with: user)
                    .launch()
            } else {
                NSLog("fcmToken is nil")
            }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Handle the URL with your custom scheme
        print("This is our url: " + url.description)
        if url.scheme == "hackillinois" {
            // Extract and process the data from the URL, e.g., JWT token
            // Perform the necessary actions based on the authentication result
            return true
        }
        return false
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        setupNavigationBarAppearance()
        setupTableViewAppearance()
        _ = HIThemeEngine.shared
        _ = HICoreDataController.shared
        _ = HILocalNotificationController.shared
        GMSServices.provideAPIKey(String(bytes: obfuscatedApiKey.deobfuscated, encoding: .utf8)!)
        HIApplicationStateController.shared.initalize()
        // Check the app version and prompt the user to update if needed
        checkAppVersion()
        // Preload point shop items
        PointShopManager.shared.preloadItems()
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
            // Called when the app has successfully registered with FCM and received a registration token
            self.fcmToken = fcmToken
            
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
               // Log the notification details
        print(notification.request.content.userInfo)

        completionHandler([.alert, .sound, .badge])
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        do {
            try HICoreDataController.shared.viewContext.save()
        } catch {
            print(error)
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        do {
            try HICoreDataController.shared.viewContext.save()
        } catch {
            print(error)
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        UIApplication.shared.registerForRemoteNotifications()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        do {
            try HICoreDataController.shared.viewContext.save()
        } catch {
            print(error)
        }
    }
}

// MARK: - Appearance Customization
extension AppDelegate {
    func setupNavigationBarAppearance() {
        let navigationBarAppearace = UINavigationBar.appearance()

        navigationBarAppearace.titleTextAttributes = [
            NSAttributedString.Key.font: HIAppearance.Font.navigationTitle as Any,
            NSAttributedString.Key.foregroundColor: (\HIAppearance.titleText).value as Any
        ]
        navigationBarAppearace.shadowImage = UIImage()
        navigationBarAppearace.isTranslucent = false
    }

    func setupTableViewAppearance() {
        let tableViewAppearance = UITableView.appearance()
        tableViewAppearance.separatorStyle = .none
        tableViewAppearance.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat.leastNonzeroMagnitude, height: CGFloat.leastNonzeroMagnitude))
        tableViewAppearance.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat.leastNonzeroMagnitude, height: CGFloat.leastNonzeroMagnitude))
        tableViewAppearance.showsHorizontalScrollIndicator = false
    }
}

// MARK: - App Update Check
extension AppDelegate {
    // Check version of app against version of API
    func checkAppVersion() {
        let apiEndpointURL = URL(string: "https://adonix.hackillinois.org/version/ios")!

        // Create an URLSession task to fetch the API version
        let task = URLSession.shared.dataTask(with: apiEndpointURL) { data, response, error in
            if let error = error {
                NSLog("Error fetching API version: \(error)")
                return
            }
            guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                NSLog("Invalid response or status code from API endpoint")
                return
            }
            do {
                // Parse the JSON response to obtain the API version
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let apiVersion = json["version"] as? String {
                    NSLog("API version is \(apiVersion)")
                    // Get the app's version from Info.plist
                    if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                        if appVersion.compare(apiVersion, options: .numeric) == .orderedAscending {
                            // App version is less than API version, prompt the user to update
//                            self.showUpdateAlert()
                        }
                    }
                }
            } catch {
                NSLog("Error parsing API response: \(error)")
            }
        }

        task.resume()
    }

    func showUpdateAlert() {
        let alert = UIAlertController(
            title: "Update Required",
            message: "A new version of the app is available. Please update to continue.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { _ in
            // Open the App Store page for app for the user to update
            if let appURL = URL(string: "https://apps.apple.com/us/app/hackillinois/id1451755268") {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            }
        }))
        DispatchQueue.main.async {
            if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                if let rootViewController = keyWindow.rootViewController {
                    rootViewController.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
