//
//  HIScanMentorViewController.swift
//  HackIllinois
//
//  Created by HackIllinois on 2/11/24.
//  Copyright © 2024 HackIllinois. All rights reserved.
//

import Foundation
import UIKit
import Combine
import AVKit
import CoreData
import APIManager
import HIAPI
import SwiftUI

class HIScanMentorViewController: HIBaseViewController {
    private var captureSession: AVCaptureSession?
    private let containerView = HIView {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundHIColor = \.baseBackground
    }
    private let previewView = HIView {
        $0.backgroundHIColor = \.baseBackground
    }
    private var previewLayer: AVCaptureVideoPreviewLayer?
    let hapticGenerator = UINotificationFeedbackGenerator()
    private let pickerView = UIPickerView()
    private var loadFailed = false
    var respondingToQRCodeFound = true
    private let closeButton = HIButton {
        $0.tintHIColor = \.action
        $0.backgroundHIColor = \.clear
        $0.activeImage = #imageLiteral(resourceName: "CloseButton")
        $0.baseImage = #imageLiteral(resourceName: "CloseButton")
    }
    private let errorView = HIErrorView(style: .codePopup)
    private var selectedEventID = ""
    private var cancellables = Set<AnyCancellable>()
    var currentUserID = ""
    var currentUserName = ""
    var dietaryString = ""
}

// MARK: - UIViewController
extension HIScanMentorViewController {
    override func loadView() {
        super.loadView()
        print("Points Shop QR scanner")
        guard let user = HIApplicationStateController.shared.user else { return }
        if HIApplicationStateController.shared.isGuest && !user.roles.contains(.STAFF) {
            let background = #imageLiteral(resourceName: "ProfileBackground")
            let imageView: UIImageView = UIImageView(frame: view.bounds)
            view.addSubview(imageView)
            view.sendSubviewToBack(imageView)
            layoutErrorView()
        } else {
            view.addSubview(containerView)
            view.bringSubviewToFront(containerView)
            containerView.constrain(to: view, topInset: 0, bottomInset: 0)
            containerView.constrain(to: view, trailingInset: 0, leadingInset: 0)
            containerView.addSubview(previewView)
            setupCaptureSession()
            if user.roles.contains(.STAFF) {
                let observable = HIStaffButtonViewObservable()
                observable.$selectedEventId.sink { eventID in
                    self.selectedEventID = eventID
                }.store(in: &cancellables)
                let staffButtonController = UIHostingController(rootView: HIStaffButtonView(observable: observable))
                addChild(staffButtonController)
                staffButtonController.view.backgroundColor = .clear
                staffButtonController.view.frame = CGRect(x: 0, y: 100, width: Int(view.frame.maxX), height: 600)
                view.addSubview(staffButtonController.view)
            }
        }
        view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(didSelectCloseButton(_:)), for: .touchUpInside)
        closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
        closeButton.constrain(width: 60, height: 60)
        closeButton.imageView?.contentMode = .scaleToFill
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if loadFailed {
            presentErrorController(
                title: "Scanning not supported",
                message: "Your device does not support scanning a code from an item. Please use a device with a camera.",
                dismissParentOnCompletion: true
            )
        } else if captureSession?.isRunning == false {
            previewLayer?.frame = view.layer.bounds
            DispatchQueue.main.async { [weak self] in
                self?.captureSession?.startRunning()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession?.isRunning == true {
            DispatchQueue.main.async { [weak self] in
                self?.captureSession?.stopRunning()
            }
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { [weak self] (_) in
            self?.setFrameForPreviewLayer()
        }, completion: nil)
    }
    func layoutErrorView() {
        errorView.delegate = self
        view.addSubview(errorView)
        errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        errorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        errorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        errorView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
}

// MARK: - Actions
extension HIScanMentorViewController {
    @objc func didSelectCloseButton(_ sender: HIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - HIErrorViewDelegate
extension HIScanMentorViewController: HIErrorViewDelegate {
    func didSelectErrorLogout(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(
            UIAlertAction(title: "Log Out", style: .destructive) { _ in
                self.dismiss(animated: true, completion: nil)
                NotificationCenter.default.post(name: .logoutUser, object: nil)
            }
        )
        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        )
        alert.popoverPresentationController?.sourceView = sender
        present(alert, animated: true, completion: nil)
    }
}

// MARK: AVCaptureMetadataOutputObjectsDelegate
extension HIScanMentorViewController: AVCaptureMetadataOutputObjectsDelegate {
    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        let metadataOutput = AVCaptureMetadataOutput()
        guard
            let captureSession = captureSession,
            let videoCaptureDevice = AVCaptureDevice.default(for: .video),
            let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
            captureSession.canAddInput(videoInput),
            captureSession.canAddOutput(metadataOutput) else {
            loadFailed = true
            return
        }
        captureSession.addInput(videoInput)
        captureSession.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        self.previewLayer = previewLayer
        setFrameForPreviewLayer()
        previewView.layer.addSublayer(previewLayer)
    }

    func setFrameForPreviewLayer() {
        guard let previewLayer = previewLayer else { return }
        previewLayer.frame = previewView.layer.bounds
        guard previewLayer.connection?.isVideoOrientationSupported == true else { return }
#warning("Not Tested")
        let interfaceOrientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
        switch interfaceOrientation {
        case .portrait, .unknown:
            previewLayer.connection?.videoOrientation = .portrait
        case .portraitUpsideDown:
            previewLayer.connection?.videoOrientation = .portraitUpsideDown
        case .landscapeLeft:
            previewLayer.connection?.videoOrientation = .landscapeLeft
        case .landscapeRight:
            previewLayer.connection?.videoOrientation = .landscapeRight
        case .none:
            break
        @unknown default:
            previewLayer.connection?.videoOrientation = .portrait
        }
    }

    func handleMentorAlert(status: String, points: Int) {
        print(status)
        var alertTitle = ""
        var alertMessage = ""
        var error = true
        switch status {
        case "Success":
            alertTitle = "\n\nPoints Earned!"
            alertMessage = "\nYou have obtained \(points) points from mentor office hours!"
            error = false
        default:
            alertTitle = "\n\nError!"
            alertMessage = "\nThis QR code is invalid or you have already checked in to this mentor's office hours."
            self.respondingToQRCodeFound = true
        }
        // Create custom alert for attendee check in functionality
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        let titleFont = UIFont(name: "MontserratRoman-Bold", size: 22)
        let messageFont = UIFont(name: "MontserratRoman-Medium", size: 16)
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        let titleColor: UIColor = (userInterfaceStyle == .dark) ? UIColor.white : #colorLiteral(red: 0.337254902, green: 0.1411764706, blue: 0.06666666667, alpha: 1)
        let messageColor: UIColor = (userInterfaceStyle == .dark) ? UIColor.white : #colorLiteral(red: 0.337254902, green: 0.1411764706, blue: 0.06666666667, alpha: 1)
        
        let attributedTitle = NSAttributedString(string: alertTitle, attributes: [NSAttributedString.Key.font: titleFont as Any, NSAttributedString.Key.foregroundColor: titleColor])
        let attributedMessage = NSAttributedString(string: alertMessage, attributes: [NSAttributedString.Key.font: messageFont as Any, NSAttributedString.Key.foregroundColor: messageColor])
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        alert.setValue(attributedMessage, forKey: "attributedMessage")

        // Create image view
        let imageView = UIImageView(image: UIImage(named: "Treasure Chest"))
        imageView.contentMode = .scaleAspectFit
        alert.view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: alert.view.topAnchor, constant: -5).isActive = true
        if alertTitle == "Success!" {
            alert.addAction(
                UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.dismiss(animated: true, completion: nil)
                    //Dismisses view controller
                    self.didSelectCloseButton(self.closeButton)
                    NotificationCenter.default.post(name: .qrCodeSuccessfulScan, object: nil)
                }))
        } else {
            alert.addAction(
                UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.registerForKeyboardNotifications()
                }))
        }
        self.present(alert, animated: true, completion: nil)
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            guard respondingToQRCodeFound else { return }
            let meta = metadataObjects.first as? AVMetadataMachineReadableCodeObject
            let code = meta?.stringValue ?? ""
            guard let user = HIApplicationStateController.shared.user else { return }
            respondingToQRCodeFound = false
            HIAPI.MentorService.recordMentorAttendance(userToken: user.token, mentorId: String(code))
                .onCompletion { result in
                    do {
                        let (codeResult, _) = try result.get()
                        let status = codeResult.status
                        NSLog(status ?? "Success")
                        DispatchQueue.main.async {
                            self.handleMentorAlert(status: status ?? "Success", points: codeResult.points ?? 0)
                        }
                    } catch {
                        NSLog("Error info: \(error)")
                        DispatchQueue.main.async { [self] in
                            self.handleMentorAlert(status: "\(error)", points: 0)
                        }
                    }
                    sleep(2)
                }
            .authorize(with: HIApplicationStateController.shared.user)
            .launch()
    }
    func decode(_ token: String) -> [String: AnyObject]? {
        let string = token.components(separatedBy: ".")
        if string.count == 1 { return nil }
        let toDecode = string[1] as String
        var stringtoDecode: String = toDecode.replacingOccurrences(of: "-", with: "+") // 62nd char of encoding
        stringtoDecode = stringtoDecode.replacingOccurrences(of: "_", with: "/") // 63rd char of encoding
        switch stringtoDecode.utf16.count % 4 {
        case 2: stringtoDecode = "\(stringtoDecode)=="
        case 3: stringtoDecode = "\(stringtoDecode)="
        default: // nothing to do stringtoDecode can stay the same
            print("")
        }
        let dataToDecode = Data(base64Encoded: stringtoDecode, options: [])
        let base64DecodedString = NSString(data: dataToDecode!, encoding: String.Encoding.utf8.rawValue)
        var values: [String: AnyObject]?
        if let string = base64DecodedString {
            if let data = string.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: true) {
                values = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject]
            }
        }
        return values
    }
}
