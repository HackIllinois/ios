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

    private init() { }

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
    @Published var items: [String: Int] = [:]

    private init() {
        preloadCartItems()
    }

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
                        print("Failed to preload cart items with error: \(error)")
                    }
                }
            }
            .authorize(with: HIApplicationStateController.shared.user)
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
    @State var startFetchingQR = false
    @State var loading = true
    @State var qrCode = "hackillinois://user?userToken=11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111"
    
    let isIpad = UIDevice.current.userInterfaceIdiom == .pad
    let resizeFactor = [(UIScreen.main.bounds.width/428), (UIScreen.main.bounds.height/926)] // sizing done based on iPhone 13 pro max, resizing factor to modify spacing [width, height]

    var body: some View {
        if flowView == 0 {
            ZStack {
                // 1) Background
                Image("PointShopBackground")
                    .resizable()
                    .ignoresSafeArea()
                
                // 2) Coins display + tab bar
                VStack {
                    HStack(alignment: .center, spacing: 7) {
                        Image("Coin")
                            .resizable()
                            .frame(width: 25 * resizeFactor[0], height: 25 * resizeFactor[0])
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
                
                CustomTopTabBar(tabIndex: $tabIndex)
                    .offset(y: -240 * (UIScreen.main.bounds.height/852))
                
                // 3) BOTTOM VSTACK: two rows pinned to bottom
                VStack(spacing: 16) {
                    let listedItems = filterShopItems(shopItems: shopManager.items, index: tabIndex)
                    
                    if listedItems.count >= 2 {
                        HStack(spacing: 16) {
                            ForEach(listedItems.prefix(2), id: \.name) { item in
                                PointShopItemCell(item: item)
                            }
                        }
                    }
                    
                    // Row 2: horizontal scroll for the rest
                    if listedItems.count > 2 {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(listedItems.dropFirst(2), id: \.name) { item in
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
                            .frame(width: 85 * resizeFactor[0], height: 30 * resizeFactor[1])
                            .onTapGesture {
                                title = "CART"
                                flowView = 1
                            }
                    }
                    .frame(height: 60 * resizeFactor[1])
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .onAppear {
                // Fetch coins
                getCoins { newCoins in
                    coins = newCoins
                }
                shopManager.preloadItems()
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
                            .frame(width: 25 * resizeFactor[0], height: 25 * resizeFactor[0])
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
                        .frame(width: 34 * resizeFactor[0])
                        .foregroundColor(Color(red: 139/255, green: 109/255, blue: 116/255))
                    Image(systemName: "chevron.left")
                        .bold()
                }
                .frame(width: UIScreen.main.bounds.width - 50 * resizeFactor[0], height: UIScreen.main.bounds.height - 250 * resizeFactor[1], alignment: .topLeading)
                .onTapGesture {
                    title = "POINT SHOP"
                    flowView = 0
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
                            startFetchingQR = true
                            title = ""
                            flowView = 2
                        }
                }
                
                VStack(spacing: 5) {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 5),
                            GridItem(.flexible(), spacing: 5)
                        ], spacing: 16) {
                            ForEach(Array(cartManager.items.keys).sorted { $0 > $1 }, id: \.self) { key in
                                CartItemCell(count: cartManager.items[key] ?? 0, item: findItem(by: key, in: shopManager.items)!)
                            }
                        }
                    }
                }
                .frame(height: 500 * resizeFactor[1])
                .padding(.bottom, 60 * resizeFactor[0])
            }
            .onAppear {
                cartManager.preloadCartItems()
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
                            .frame(width: 80 * resizeFactor[0])
                            .onTapGesture {
                                startFetchingQR = false
                                title = "POINT SHOP"
                                flowView = 0
                            }
                            .padding(.leading, 35)
                        Spacer()
                    }
                    Spacer()
                }
                VStack {
                    Text("SCAN HERE TO COMPLETE PURCHASE")
                        .padding(.bottom, 50)
                        .multilineTextAlignment(.center)
                        .frame(width: 250 * resizeFactor[0])
                        .font(Font.custom("Montserrat", size: 24).weight(.bold))
                    Image(uiImage: UIImage(data: getQRCodeDate(text: qrCode)!)!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250 * resizeFactor[0], height: 250 * resizeFactor[0])
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
    
    func QRFetchLoop() {
        if startFetchingQR {
            getQRInfo() { _ in
                print("QR code received")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                QRFetchLoop()
            }
        }
    }
    
    func getCoins(completion: @escaping (Int) -> Void) {
            guard let user = HIApplicationStateController.shared.user else { return }
            HIAPI.ProfileService.getUserProfile(userToken: user.token)
                .onCompletion { result in
                    do {
                        let (apiProfile, _) = try result.get()
                        print(user.token)
                        DispatchQueue.main.async {
                            completion(apiProfile.points)
                        }
                    } catch {
                        print("Failed to reload coins with error: \(error)")
                    }
                }
                .authorize(with: user)
                .launch()
    }
    
    func getQRInfo(completion: @escaping (Int) -> Void) {
        guard let user = HIApplicationStateController.shared.user else { return }
        HIAPI.ShopService.getQR(userToken: user.token)
            .onCompletion { result in
                do {
                    let (qr, _) = try result.get()
                    DispatchQueue.main.async {
                        self.qrCode = qr.QRCode!
                    }
                } catch {
                    print("An error has occurred \(error)")
                }
            }
            .authorize(with: user)
            .launch()
    }
    
    func getQRCodeDate(text: String) -> Data? {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        let data = text.data(using: .ascii, allowLossyConversion: false)
        filter.setValue(data, forKey: "inputMessage")
        
        // Change color of QR code
        guard let colorFilter = CIFilter(name: "CIFalseColor") else { return nil }
        colorFilter.setValue(filter.outputImage, forKey: "inputImage")
        colorFilter.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: "inputColor1") // Background off-white
        colorFilter.setValue(CIColor(red: 0, green: 0, blue: 0), forKey: "inputColor0") // Barcode brown
        
        guard let ciimage = colorFilter.outputImage else { return nil }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledCIImage = ciimage.transformed(by: transform)
        let uiimage = UIImage(ciImage: scaledCIImage)
        return uiimage.pngData()!
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
                    .frame(width: 75 * (UIScreen.main.bounds.width/428))
                
                // Item image
                Image(systemName: "Profile0")
                    .data(url: URL(string: item.imageURL)!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60 * (UIScreen.main.bounds.width/428), height: 60 * (UIScreen.main.bounds.width/428))

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
        .frame(width: 140 * (UIScreen.main.bounds.width/428), height: 140 * (UIScreen.main.bounds.width/428))
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
                        .frame(width: 18 * (UIScreen.main.bounds.width/428))
                        .foregroundColor(.white)
                    Image(systemName: "plus")
                        .foregroundColor(.black)
                }
                .padding(6)
            },
            alignment: .topTrailing
        )
    }
}

struct CartItemCell: View {
    let count: Int
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
                    .frame(width: 75 * (UIScreen.main.bounds.width/428))
                
                // Item image
                Image(systemName: "Profile0")
                    .data(url: URL(string: item.imageURL)!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60 * (UIScreen.main.bounds.width/428), height: 60 * (UIScreen.main.bounds.width/428))

                // Price + quantity
                HStack(spacing: 4) {
                    Button(action: {
                        removeItemFromCart(itemId: item.itemId) { itemName in
                            print("Removed \(itemName) from cart")
                        }
                    }) {
                        Image(systemName: "minus")
                            .foregroundColor(.black)
                            .frame(width: 6, height: 6)
                            .padding(.leading, 3)
                    }
                    Text(" | \(count) | ")
                        .foregroundColor(.black)
                        .font(Font.custom("Montserrat", size: 18).weight(.bold))
                    Button(action: {
                        addItemToCart(itemId: item.itemId) { itemName in
                            print("Added \(itemName) to cart")
                        }
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.black)
                            .frame(width: 6, height: 6)
                            .padding(.trailing, 3)
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
        .frame(width: 140 * (UIScreen.main.bounds.width/428), height: 140 * (UIScreen.main.bounds.width/428))
        .cornerRadius(12)
    }
}

func addItemToCart(itemId: String, completion: @escaping (String) -> Void) {
    guard let user = HIApplicationStateController.shared.user else { return }
    HIAPI.ShopService.addToCart(itemId: itemId, userToken: user.token)
        .onCompletion { result in
            do {
                let (codeResult, _) = try result.get()
                CartManager.shared.items = codeResult.items ?? CartManager.shared.items
            } catch {
                print("Failed to add to cart: \(error)")
            }
        }
        .authorize(with: user)
        .launch()
}

func removeItemFromCart(itemId: String, completion: @escaping (String) -> Void) {
    guard let user = HIApplicationStateController.shared.user else { return }
    HIAPI.ShopService.removeFromCart(itemId: itemId, userToken: user.token)
        .onCompletion { result in
            do {
                let (codeResult, _) = try result.get()
                CartManager.shared.items = codeResult.items ?? CartManager.shared.items
            } catch {
                print("Failed to add to cart: \(error)")
            }
        }
        .authorize(with: user)
        .launch()
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

func findItem(by itemId: String, in shopItems: [Item]) -> Item? {
    return shopItems.first(where: { $0.itemId == itemId })
}

func filterShopItems(shopItems: [Item], index: Int) -> [Item] {
    return shopItems.filter { $0.isRaffle == (index == 1) }
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
