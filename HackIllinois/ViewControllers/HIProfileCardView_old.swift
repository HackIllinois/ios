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

    var body: some View {
        ScrollView {
            ZStack {
                ZStack(alignment: .top) {
                    ZStack(alignment: .bottom) {
                        Image("ProfileCardBackground")
                            .resizable()
                            .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 566.93*padFactor : 338*phoneFactor, height: UIDevice.current.userInterfaceIdiom == .pad ? 777.2*padFactor : 463.36*phoneFactor)
                        ZStack {
                            Image("ProfileBanner")
                                .resizable()
                                .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 395.7*padFactor : 235.91*phoneFactor, height: UIDevice.current.userInterfaceIdiom == .pad ? 137.71*padFactor : 82.1*phoneFactor)
                            VStack(spacing: 0) {
                                Text("Your Ranking")
                                    .foregroundColor(.white)
                                
                                    .font(Font(HIAppearance.Font.profileSubtitle ?? .systemFont(ofSize: 20)))
                                HStack(alignment: .bottom, spacing: UIDevice.current.userInterfaceIdiom == .pad ? 5*padFactor : 5*phoneFactor) {
                                    Image("RankSymbol")
                                    Text("\(rank != 0 ? "\(rank)" : "...")")
                                                    .foregroundColor(.white)
                                                    .font(Font(HIAppearance.Font.profileSubtitle ?? .systemFont(ofSize: 20)))
                                                    .onAppear {
                                                        // Call getRank and update the rank when it's available
                                                        getRank { rank in
                                                            self.rank = rank
                                                        }
                                                    }
                                }
                            }.padding(.bottom, isIpad ? 40*padFactor : 25*phoneFactor)
                        }.alignmentGuide(.bottom) {dimensions in dimensions[.bottom] / 1.2 }
                    }
                    Image(uiImage: avatarUrl.load())
                        .resizable()
                        .frame(width: isIpad ? 249.92*padFactor : 149*phoneFactor, height: isIpad ? 286.4*padFactor : 170.75*phoneFactor)
                        .alignmentGuide(.top) {dimensions in dimensions[VerticalAlignment.center] / 0.9 }
                }
                VStack(spacing: 0) {
                    Spacer().frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 90*padFactor : (90*phoneFactor))
                    Text(formatName())
                        .font(Font(HIAppearance.Font.profileName ?? .systemFont(ofSize: 24)))
                        .foregroundColor(Color((\HIAppearance.countdownTextColor).value))
                        .padding(isIpad ? 32*padFactor : 16*phoneFactor)
                    HStack(spacing: isIpad ? 16*padFactor : 8*phoneFactor) {
                        Rectangle()
                            .frame(width: isIpad ? 148*padFactor : 74*phoneFactor, height: isIpad ? 48*padFactor : 24*phoneFactor)
                            .cornerRadius(isIpad ? 40*padFactor : 20*phoneFactor)
                            .foregroundColor(Color(red: 226/255, green: 142/255, blue: 174/255))
                            .overlay(
                                Text(role)
                                    .font(Font(HIAppearance.Font.profileSubtitle ?? .systemFont(ofSize: 12)))
                                    .foregroundColor(Color(red: 1, green: 248/255, blue: 245/255))
                            )

                        Rectangle()
                            .frame(width: isIpad ? 136*padFactor : 68*phoneFactor, height: isIpad ? 48*padFactor : 24*phoneFactor)
                            .cornerRadius(isIpad ? 40*padFactor : 20*phoneFactor)
                            .foregroundColor(
                                (Color(red: 226/255, green: 142/255, blue: 174/255)))
                            .overlay(
                                Text("Wave \(foodWave)")
                                    .font(Font(HIAppearance.Font.profileSubtitle ?? .systemFont(ofSize: 12)))
                                    .foregroundColor((Color(red: 1, green: 248/255, blue: 245/255)))
                            )
                    }.padding(.bottom)
                    Image(uiImage: UIImage(data: getQRCodeDate(text: qrInfo)!)!)
                                                    .resizable()
                                                    .frame(width: isIpad ? 371*padFactor : 221*phoneFactor, height: isIpad ? 371*padFactor : 221*phoneFactor)
                                                    .padding(.bottom, 20*phoneFactor)
                }
                .padding(.top, isIpad ? 50*padFactor : 0)
            }
            .padding(.top, 24)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            startFetchingQR = true
            QRFetchLoop()
        }
        .onDisappear {
            startFetchingQR = false
        }
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
