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

class PointShopManager: ObservableObject {
    /// Singleton instance
    static let shared = PointShopManager()

    /// Published array of items that will notify SwiftUI of changes
    @Published var items: [Item] = []

    private init() {
        preloadItems()
    }

    /// Fetch items from the API and store them in `items`.
    /// Publishing to `items` will automatically trigger UI updates in SwiftUI.
    func preloadItems() {
        HIAPI.ShopService.getAllItems()
            .onCompletion { [weak self] result in
                // Always hop back onto the main thread before changing any
                // Published properties, as they must update the UI on main.
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    do {
                        let (containedItem, _) = try result.get()
                        self.items = containedItem.items
                    } catch {
                        print("Failed to preload point shop items with error: \(error)")
                    }
                }
            }
            .launch()
    }
}

class CartManager: ObservableObject {
    /// Singleton instance
    static let shared = CartManager()

    /// Published array of items that will notify SwiftUI of changes
    @Published var items: [CartItem] = []

    private init() { }

    /// Fetch items from the API and store them in `items`.
    /// Publishing to `items` will automatically trigger UI updates in SwiftUI.
    func preloadCartItems() {
        HIAPI.ShopService.getCartItems()
            .onCompletion { [weak self] result in
                // Always hop back onto the main thread before changing any
                // Published properties, as they must update the UI on main.
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    do {
                        let (containedItem, _) = try result.get()
                        self.items = containedItem.items
                    } catch {
                        print("Failed to preload point shop items with error: \(error)")
                    }
                }
            }
            .launch()
    }
}

struct HIPointShopSwiftUIView: View {
    @ObservedObject var shopManager = PointShopManager.shared
    @ObservedObject var cartManager = CartManager.shared
    
    @State private var coins = 0
    @State var tabIndex = 0
    @Binding var title: String
    @State var flowView = 0
    
    let isIpad = UIDevice.current.userInterfaceIdiom == .pad

    var body: some View {
        if flowView == 0 {
            ZStack {
                // 1) Background
                Image("PointShopBackground")
                    .resizable()
                    .ignoresSafeArea()
                
                // 2) TOP BAR (coins + tab) pinned to top
                VStack(spacing: 0) {
                    // Coins row (top-right)
                    HStack {
                        Spacer()
                        HStack(alignment: .center, spacing: 7) {
                            Image("Coin")
                                .resizable()
                                .frame(width: isIpad ? 40 : 25,
                                       height: isIpad ? 40 : 25)
                            Text("\(coins)")
                                .font(.system(size: isIpad ? 26 : 16).bold())
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 11)
                        .padding(.vertical, 3)
                        .background(Color(red: 0.96, green: 0.94, blue: 0.87))
                        .cornerRadius(1000)
                        .offset(x: -25, y: -38)
                    }
                    .frame(height: 60)
                    
                    // Tab bar
                    CustomTopTabBar(tabIndex: $tabIndex)
                }
                .frame(maxHeight: .infinity, alignment: .top)
                
                // 3) BOTTOM VSTACK: two rows pinned to bottom
                VStack(spacing: 16) {
                    // Row 1: first two items
                    if shopManager.items.count >= 2 {
                        HStack(spacing: 16) {
                            ForEach(shopManager.items.prefix(2), id: \.name) { item in
                                PointShopItemCell(item: item)
                            }
                        }
                    }
                    
                    // Row 2: horizontal scroll for the rest
                    if shopManager.items.count > 2 {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(shopManager.items.dropFirst(2), id: \.name) { item in
                                    PointShopItemCell(item: item)
                                }
                            }
                            .padding(.horizontal, 8)
                        }
                    }
                }
                // Pin the VSTACK to the bottom of the screen
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 35) // Adjust as needed
                
                VStack {
                    HStack {
                        Image("Cart")
                            .resizable()
                            .frame(width: 85, height: 30)
                            .onTapGesture {
                                title = "CART"
                                flowView = 1
                            }
                    }
                    .frame(height: 60)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        
            .onAppear {
                // Optionally fetch items if not done in AppDelegate
                // shopManager.preloadItems()

                // Fetch coins
                getCoins { newCoins in
                    coins = newCoins
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
                // Back button to go back to point shop
                ZStack {
                    Circle()
                        .frame(width: 34)
                        .foregroundColor(Color(red: 139/255, green: 109/255, blue: 116/255))
                    Image(systemName: "chevron.left")
                        .bold()
                }
                .frame(width: UIScreen.main.bounds.width - 50, height: UIScreen.main.bounds.height - 250, alignment: .topLeading)
                .onTapGesture {
                    title = "POINT SHOP"
                    flowView = 0
                }
                // Cart scroll view
                VStack(spacing: 16) {
                    ScrollView(.vertical, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(cartManager.items, id: \.self) { item in
                                VStack(spacing: 8) {
                                    ForEach(item.additionalProperties.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                        HStack {
                                            Text(key) // Display the property key
                                                .font(.headline)
                                            Spacer()
                                            Text("\(value)") // Display the property value
                                                .font(.subheadline)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                }
                // Redeem button to go to QR
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
            .onCompletion { result in
                DispatchQueue.main.async {
                    do {
                        let (containedItem, _) = try result.get()
                        // ✅ Update the manager’s items
                        shopManager.items = containedItem.items
                    } catch {
                        print("Failed to reload points shop: \(error)")
                    }
                }
            }
            .launch()
    }
    
    func getCartItems() {
        HIAPI.ShopService.getCartItems()
            .onCompletion { result in
                DispatchQueue.main.async {
                    do {
                        let (containedItem, _) = try result.get()
                        // ✅ Update the manager’s items
                        cartManager.items = containedItem.items
                    } catch {
                        print("Failed to reload cart: \(error)")
                    }
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
                        DispatchQueue.main.async {
                            completion(apiProfile.coins)
                        }
                    } catch {
                        print("Failed to reload coins with error: \(error)")
                    }
                }
                .authorize(with: user)
                .launch()
    }
}

struct PointShopItemCell: View {
    @ObservedObject var shopManager = PointShopManager.shared
    let item: Item

    var body: some View {
        ZStack {
            // Use a rounded rectangle for the background
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red:139/255,green:109/255,blue:117/255).opacity(0.89))

            VStack(spacing: 4) {
                // Name
                Text(item.name)
                    .font(.caption)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(width: 75)
                
                // Item image
                Image(systemName: "Profile0")
                    .data(url: URL(string: item.imageURL)!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)

                // Price + quantity
                HStack(spacing: 4) {
                    Image("Coin")
                        .resizable()
                        .frame(width: 15, height: 15)
                    if item.isRaffle {
                        Text("\(item.price)")
                            .font(.footnote).bold()
                            .foregroundColor(.black)
                    } else {
                        Text("\(item.price) | \(item.quantity) Left")
                            .font(.footnote)
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(red:245/255, green:240/255, blue:221/255))
                .clipShape(Capsule())
            }
            .padding()
        }
        // Force a square cell
        .frame(width: 140, height: 140)
        .cornerRadius(12)
        .overlay(
            // Add button in the top right corner
            Button(action: {
                addItemToCart(itemId: item.itemId) { itemName in
                    print("Added \(itemName) to cart")
                }
            }) {
                ZStack {
                    Circle()
                        .frame(width: 18)
                        .foregroundColor(.white)
                    Image(systemName: "plus")
                        .foregroundColor(.black)
                }
                .padding(6)
            },
            alignment: .topTrailing
        )
    }
    
    func addItemToCart(itemId: String, completion: @escaping (String) -> Void) {
        guard let user = HIApplicationStateController.shared.user else { return }
        HIAPI.ShopService.addToCart(itemId: itemId, userToken: user.token)
            .onCompletion { result in
                do {
                    let (redeemItem, _) = try result.get()
                    DispatchQueue.main.async {
                        completion(redeemItem.itemName!)
                    }
                } catch {
                    print("Failed to add to cart: \(error)")
                }
            }
            .authorize(with: user)
            .launch()
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
