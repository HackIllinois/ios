//
//  HIPointShopSwiftUIView.swift
//  HackIllinois
//
//  Created by HackIllinois on 1/12/24.
//  Copyright © 2024 HackIllinois. All rights reserved.
//

import Foundation
import SwiftUI
import HIAPI

class PointShopManager {
    static let shared = PointShopManager()

    var items: [Item] = []

    private init() {
        // Private initializer to enforce singleton pattern
    }

    func preloadItems() {
        // Fetch and populate items
        HIAPI.ShopService.getAllItems()
            .onCompletion { result in
                do {
                    let (containedItem, _) = try result.get()
                    self.items = containedItem.items
                } catch {
                    print("Failed to preload point shop items with the error: \(error)")
                }
            }
            .launch()
    }
}

struct HIPointShopSwiftUIView: View {
    @State var items=[] as [Item]
    @State private var profile = HIProfile()
    @State var coins = 0
    @State var tabIndex = 0
    let isIpad = UIDevice.current.userInterfaceIdiom == .pad
    @Binding var title: String
    @State var flowView = 0 // 0: point shop, 1: cart, 2: QR code

    var body: some View {
      //  NavigationStack{
        if flowView == 0 {
            ZStack {
                Image("PointShopBackground")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        HStack(alignment: .center, spacing: 7) {
                            Image("Coin")
                                .resizable()
                                .frame(width: isIpad ? 40 : 25, height:isIpad ? 40 : 25)
                            Text("\(coins)")
                                .font(Font.custom("MontserratRoman-Bold", size: isIpad ? 26 : 16).weight(.bold))
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 11)
                        .padding(.vertical, 3)
                        .background(Color(red: 0.9607843137254902, green: 0.9411764705882353, blue: 0.8666666666666667))
                        .cornerRadius(1000)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .offset(x: -25, y: -38)
                        Spacer()
                    }
                    Spacer()
                        .frame(height: 25)
                    ZStack {
                        VStack(spacing: 0) {
                            CustomTopTabBar(tabIndex: $tabIndex)
                            Spacer()
                        }
                        Image("Cart")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80)
                            .padding(.bottom, 175)
                            .padding(.trailing, 25)
                            .onTapGesture {
                                title = "CART"
                                flowView = 1
                            }
                    }
                }
            }
        } else if flowView == 1 {
            ZStack {
                Image("CartBackground")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                // Top right coins display
                VStack {
                    HStack(alignment: .center, spacing: 7) {
                        Image("Coin")
                            .resizable()
                            .frame(width: 25, height: 25)
                        Text("\(coins)")
                            .font(Font.custom("MontserratRoman-Bold", size: isIpad ? 26 : 16).weight(.bold))
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 11)
                    .padding(.vertical, 3)
                    .background(Color(red: 0.9607843137254902, green: 0.9411764705882353, blue: 0.8666666666666667))
                    .cornerRadius(1000)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .offset(x: -25, y: -38)
                    Spacer()
                }
                VStack {
                    Spacer()
                    Image("Redeem")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 119)
                        .padding(.bottom, 90)
                        .onTapGesture {
                            title = ""
                            flowView = 2
                        }
                }
            }
        } else {
            ZStack {
                Image("CartBackground")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        Image("PointShopBack")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80)
                            .onTapGesture {
                                title = "POINT SHOP"
                                flowView = 0
                            }
                            .padding(.leading, 35)
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
    }
    func getItems() {
        HIAPI.ShopService.getAllItems()
            .onCompletion { [self] result in
                do {
                    let (containedItem, _) = try result.get()
                    let apiItems = containedItem.items
                    items=[]
                    apiItems.forEach { apiItem in
                        items.append(apiItem)
                    }
                } catch {
                    print("Failed to reload points shop with the error: \(error)")
                }
            }
            .launch()
    }
    func getCoins(completion: @escaping (Int) -> Void) {
        guard let user = HIApplicationStateController.shared.user else { return }
        HIAPI.ProfileService.getUserProfile(userToken: user.token)
        .onCompletion { result in
            do {
                let (apiProfile, _) = try result.get()
                completion(apiProfile.coins)
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .loginProfile, object: nil, userInfo: ["profile": self.profile])
                }
            } catch {
                print("Failed to reload coins with the error: \(error)")
            }
        }
        .authorize(with: user)
        .launch()
    }
}

struct PointShopItemCell: View {
    let item: Item
    let isIpad = UIDevice.current.userInterfaceIdiom == .pad
    var body: some View {
        VStack(spacing: 0) {
            //transparent pane
            ZStack {
                Rectangle()
                    .fill(.white)
                    .frame(width: UIScreen.main.bounds.width > 850 ? 790 : (isIpad ? 690 : 350), height: 157)
                    .opacity(0.4)
                HStack {
                    Spacer()
                        .frame(width: UIScreen.main.bounds.width > 850 ? 210 : (isIpad ? 120 : 30))
                    //IMAGE
                        Image(systemName: "Profile0")
                            .data(url: URL(string: item.imageURL)!)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 145, height: 145)
                    Spacer()

                    //bubble view
                    VStack {
                        HStack{
                            Spacer()
                                .frame(width:15)
                            Text(item.name)
                                .font(
                                    Font.custom("Montserrat", size: 16)
                                        .weight(.semibold)
                                )
                                .foregroundColor(Color(red: 0.05, green: 0.25, blue: 0.25))
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity)
                                .padding(.trailing, 20)

                        }

                        HStack(alignment: .center, spacing: 7) {
                            Image("Coin")
                                .resizable()
                                .frame(width: 25, height: 25)
                            if(item.isRaffle) {
                                Text("\(item.price)")
                                    .font(Font.custom("Montserrat", size: 16).weight(.bold))
                                    .foregroundColor(.white)
                            } else {
                                Group {
                                    Text("\(item.price)")
                                        .font(Font.custom("Montserrat", size: 16).weight(.bold))
                                        .foregroundColor(.white) +
                                    Text(" | \(item.quantity) Left")
                                        .font(Font.custom("Montserrat", size: 16).weight(.regular))
                                        .foregroundColor(.white)
                                }
                            }

                        }
                        .padding(.horizontal, 11)
                        .padding(.vertical, 3)
                        .background(Color(red: 0.05, green: 0.25, blue: 0.25).opacity(0.5))
                        .cornerRadius(1000)
                    }
                    Spacer()
                }
            }
        }
    }
}

struct CustomTopTabBar: View {
    @Binding var tabIndex: Int
    let isIpad = UIDevice.current.userInterfaceIdiom == .pad

    var body: some View {
        HStack {
            TabBarButton(text: "MERCH", isSelected: .constant(tabIndex == 0))
                .onTapGesture { onButtonTapped(index: 0) }
            Spacer()
                .frame(width: isIpad ? 100: 30)
            TabBarButton(text: "RAFFLE", isSelected: .constant(tabIndex == 1))
                .onTapGesture { onButtonTapped(index: 1) }
        }
        .frame(maxWidth: .infinity)
    }
    private func onButtonTapped(index: Int) {
        withAnimation { tabIndex = index }
    }
}

struct TabBarButton: View {
    let text: String
    @Binding var isSelected: Bool
    let isIpad = UIDevice.current.userInterfaceIdiom == .pad
    var body: some View {
        ZStack(alignment: .center) {
            if isSelected {
                Image("PointShopTabSelected")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.width > 850 ? 350 : (isIpad ? 295 : 155), height: isIpad ? 90: 50)
            }else{
                Image("PointShopTabUnselected")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.width > 850 ? 350 : (isIpad ? 295 : 155), height: isIpad ? 90: 50)
            }
            Text(text)
                .foregroundColor(Color(HIAppearance.metallicCopper))
                .fontWeight(.heavy)
                .font(.custom("MontserratRoman-Bold", size: UIDevice.current.userInterfaceIdiom == .pad ? 36 : 16))
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension Image {
    func data(url:URL) -> Self {
            if let data = try? Data(contentsOf: url) {
                return Image(uiImage: UIImage(data: data)!)
                    .resizable()
            }
    return self
    .resizable()
    }
}
