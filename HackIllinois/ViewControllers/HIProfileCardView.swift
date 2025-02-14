//
//  HIProfileViewController.swift
//  HackIllinois
//
//  Created by HackIllinois Team on 11/30/22.
//  Copyright © 2022 HackIllinois. All rights reserved.
//  This file is part of the Hackillinois iOS App.
//  The Hackillinois iOS App is open source software, released under the University of
//  Illinois/NCSA Open Source License. You should have received a copy of
//  this license in a file with the distribution.
//

import SwiftUI
import URLImage
import HIAPI

// Loads url data and converts into image
//extension String {
//    func loadImage(completion: @escaping (UIImage?) -> Void) {
//            guard let url = URL(string: self) else {
//                completion(nil)
//                return
//            }
//
//            URLSession.shared.dataTask(with: url) { data, _, error in
//                if let data = data, let image = UIImage(data: data) {
//                    completion(image)
//                } else {
//                    completion(nil)
//                }
//            }.resume()
//        }
//}

extension String {
    func load() -> UIImage {
        do {
            guard let url = URL(string: self) else {
                return UIImage()
            }
            let data: Data = try Data(contentsOf: url)
            return UIImage(data: data) ?? UIImage()
        } catch {}
        return UIImage()
    }
}

struct HIProfileCardView: View {
    @State private var rank: Int = 0
    let displayName: String
    let points: Int
    let tier: String
    let foodWave: Int
    let avatarUrl: String
    let background = (\HIAppearance.profileCardBackground).value
    let baseText = (\HIAppearance.profileBaseText).value
    let userId: String
    let isIpad = UIDevice.current.userInterfaceIdiom == .pad
    let role: String
    @State var startFetchingQR = false
    @State var qrInfo = "hackillinois://user?userToken=11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111"
//    Factors used to change frame to alter based on device
    let padFactor = UIScreen.main.bounds.height/1366
    let phoneFactor = UIScreen.main.bounds.height/844
    
    // Screen size
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height

    var body: some View {
        ZStack(alignment: .bottom) {  // Stack elements and anchor to bottom
            // placeholders so the compiler doesn't get mad at long arithmetic within views
            let height_adjustment_factor = (40 / 841) * screenHeight
            
            let flame_y = (521 / 841) * screenHeight - (screenHeight * (262 / 841)) / 2 - (screenHeight * (450 / 841)) / 2 + (13 / 841) * screenHeight + height_adjustment_factor
            let pillar_y = (521 / 841) * screenHeight// Centered at the bottom
            let orb_y = (521 / 841) * screenHeight - (screenHeight * (262 / 841)) / 2 - (screenHeight * (450 / 841)) - (screenHeight * (140.49 / 841)) / 2 + (13 / 841) * screenHeight + (140.49 / 841) * screenHeight + height_adjustment_factor
            
            Image("flame-vector")
                .resizable()
                .scaledToFit()
                .frame(
                    width: screenWidth * (371.01 / 393),  // Scaled width
                    height: screenHeight * (450 / 841)  // Scaled height
                )
                .position(
                    x: screenWidth / 2,
                    y: flame_y
                ) // Position at the top of the pillar
            // Pillar Image - Anchored at the bottom
            Image("pillar-vector")
                .resizable()
                .scaledToFit()
                .frame(
                    width: screenWidth * (361 / 393),  // Scaled width
                    height: screenHeight * (262 / 841)  // Scaled height
                )
                .position(
                    x: screenWidth / 2,
                    y: pillar_y
                )
            
            // Profile Orb - Stacked on top of the flame
            Image("profile-orb")
                .resizable()
                .scaledToFit()
                .frame(
                    width: screenWidth * (174.99 / 393),  // Scaled width
                    height: screenHeight * (140.49 / 841)  // Scaled height
                )
                .position(
                    x: screenWidth / 2,
                    y: orb_y
                ) // Positioned on top of the flame
            
        }
        .edgesIgnoringSafeArea(.bottom) // Extend to the bottom edge
    }

    func formatName() -> String {
        if displayName.count > 20 {
            let names = displayName.split(separator: " ")
            if names.count >= 2 {
                let firstName = String(names[0])
                let lastName = String(names[1])
                let abbreviatedName = firstName + " " + String(lastName.prefix(1)) + "."
                return abbreviatedName
            } else {
                return displayName
            }
        } else {
            return displayName
        }
    }

    func getQRCodeDate(text: String) -> Data? {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        let data = text.data(using: .ascii, allowLossyConversion: false)
        filter.setValue(data, forKey: "inputMessage")
        
        // Change color of QR code
        guard let colorFilter = CIFilter(name: "CIFalseColor") else { return nil }
        colorFilter.setValue(filter.outputImage, forKey: "inputImage")
        colorFilter.setValue(CIColor(red: 1, green: 248/255, blue: 245/255), forKey: "inputColor1") // Background off-white
        colorFilter.setValue(CIColor(red: 102/255, green: 43/255, blue: 19/255), forKey: "inputColor0") // Barcode brown
        
        guard let ciimage = colorFilter.outputImage else { return nil }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledCIImage = ciimage.transformed(by: transform)
        let uiimage = UIImage(ciImage: scaledCIImage)
        return uiimage.pngData()!
    }

    func QRFetchLoop() {
        if startFetchingQR {
            getQRInfo()
            DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                QRFetchLoop()
            }
        }
    }

    func getQRInfo() {
        guard let user = HIApplicationStateController.shared.user else { return }
        HIAPI.UserService.getQR(userToken: user.token)
            .onCompletion { result in
                do {
                    let (qr, _) = try result.get()
                    DispatchQueue.main.async {
                        self.qrInfo = qr.qrInfo
                    }
                } catch {
                    print("An error has occurred \(error)")
                }
            }
            .authorize(with: user)
            .launch()
    }
    
    func getRank(completion: @escaping (Int) -> Void) {
        guard let user = HIApplicationStateController.shared.user else { return }

        var rank = 0
        HIAPI.ProfileService.getUserRanking(userToken: user.token)
            .onCompletion { result in
                do {
                    let (userRanking, _) = try result.get()
                    rank = userRanking.ranking
                    completion(rank)
                } catch {
                    print("An error has occurred in ranking \(error)")
                }
            }
            .authorize(with: user)
            .launch()
    }

}

struct HIProfileCardView_Previews: PreviewProvider {
    static var previews: some View {
        HIProfileCardView(displayName: "first last",
                          points: 100,
                          tier: "Pro",
                          foodWave: 1,
                          avatarUrl: "https://raw.githubusercontent.com/HackIllinois/adonix-metadata/main/avatars/fishercat.png", userId: "https://www.hackillinois.org", role: "Pro"
        )
    }
}
