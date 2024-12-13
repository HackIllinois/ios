//
//  HIScanAttendanceViewController.swift
//  HackIllinois
//
//  Created by HackIllinois on 9/24/23.
//  Copyright © 2023 HackIllinois. All rights reserved.
//

import Foundation
import UIKit
import Combine
import AVKit
import CoreData
import APIManager
import HIAPI
import SwiftUI

class HIScanAttendanceViewController: HIBaseViewController {
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
    var currentUserID = ""
    private var cancellables = Set<AnyCancellable>()
}

// MARK: - UIViewController
extension HIScanAttendanceViewController {
    override func loadView() {
        super.loadView()
        print("Meeting Attendance QR Scanner")
        guard let user = HIApplicationStateController.shared.user else { return }
        if (HIApplicationStateController.shared.isGuest && !user.roles.contains(.STAFF)) || !user.roles.contains(.STAFF) {
            let imageView: UIImageView = UIImageView(frame: view.bounds)
            view.addSubview(imageView)
            view.sendSubviewToBack(imageView)
            layoutErrorView()
        } else if user.roles.contains(.STAFF) {
            view.addSubview(containerView)
            view.bringSubviewToFront(containerView)
            containerView.constrain(to: view, topInset: 0, bottomInset: 0)
            containerView.constrain(to: view, trailingInset: 0, leadingInset: 0)
            containerView.addSubview(previewView)
            setupCaptureSession()
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
extension HIScanAttendanceViewController {
    @objc func didSelectCloseButton(_ sender: HIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - HIErrorViewDelegate
extension HIScanAttendanceViewController: HIErrorViewDelegate {
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
extension HIScanAttendanceViewController: AVCaptureMetadataOutputObjectsDelegate {
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
        print("All good")
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

    func handleStaffCheckInAlert(status: String) {
        var alertTitle = "Error!"
        var alertMessage = ""

        self.respondingToQRCodeFound = true

        switch status {
        case "Check-in successful!":
            alertTitle = "Success!"
            alertMessage = "You have successfully checked in."
            self.respondingToQRCodeFound = false
        case "QR code expired.":
            alertMessage = "The check-in code for this event has expired."
        case "NotFound":
            alertMessage = "The event could not be found. Ensure the QR code is correct and try again."
        case "Invalid token.":
            alertMessage = "Invalid token. You do not have the necessary permissions to check in."
        case "Internal server error.":
            alertMessage = "An internal server error occurred. Please try again later."
        default:
            alertMessage = "Something isn't quite right."
        }

        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)

        if alertTitle == "Success!" {
            alert.addAction(
                UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.dismiss(animated: true, completion: nil)
                    // Dismisses the view controller
                    self.didSelectCloseButton(self.closeButton)
                    NotificationCenter.default.post(name: .qrCodeSuccessfulScan, object: nil)
                })
            )
        } else {
            alert.addAction(
                UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.registerForKeyboardNotifications()
                })
            )
        }

        self.present(alert, animated: true, completion: nil)
    }

    // This function detects whether a QRCode has been found
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard respondingToQRCodeFound else { return }
        print("QR code was found")
        let meta = metadataObjects.first as? AVMetadataMachineReadableCodeObject
        let code = meta?.stringValue ?? ""
        guard let user = HIApplicationStateController.shared.user else { return }
        if user.roles.contains(.STAFF) {
            let eventId = code.description
            print(eventId)
            respondingToQRCodeFound = false
            print(user.token)
            var codeResult: Attendance?
            HIAPI.EventService.staffMeetingAttendanceCheckIn(userToken: String(user.token), eventId: eventId)
                .onCompletion { result in
                    switch result {
                    case .success(let (attendance, _)): // `attendance` is already decoded into the `Attendance` model
                            print("Success Response: \(attendance)")

                            DispatchQueue.main.async {
                                if let success = attendance.success, success {
                                                self.handleStaffCheckInAlert(status: "Check-in successful!")
                                            } else if let error = attendance.error {
                                                self.handleStaffCheckInAlert(status: error)
                                            } else {
                                                self.handleStaffCheckInAlert(status: "Something isn't quite right")
                                            }
                                        }
                    case .failure(let error): // Handle failure responses
                               print("Request failed with error: \(error)")

                        DispatchQueue.main.async {
                                // Extract error description
                            let rawErrorString = String(describing: error).lowercased()
                            print("Raw Error String: \(rawErrorString)")
                                if rawErrorString.contains("code: 400") {
                                    self.handleStaffCheckInAlert(status: "QR code expired.")
                                } else if rawErrorString.contains("code: 401") {
                                    self.handleStaffCheckInAlert(status: "Invalid token.")
                                } else if rawErrorString.contains("code: 500") {
                                    self.handleStaffCheckInAlert(status: "Internal server error.")
                                } else if rawErrorString.contains("code: 404") {
                                    self.handleStaffCheckInAlert(status: "NotFound")
                                } else {
                                    self.handleStaffCheckInAlert(status: "Something isn't quite right.")
                                }
                            }
                           }
                    sleep(2)
                }
                .authorize(with: HIApplicationStateController.shared.user)
                .launch()
        }
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
