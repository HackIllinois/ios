//
//  ShopService.swift
//  HIAPI
//
//  Created by HackIllinois on 12/19/23.
//  Copyright © 2023 HackIllinois. All rights reserved.
//

import Foundation
import APIManager

public final class ShopService: BaseService {
    public override static var baseURL: String {
        return super.baseURL
    }

    public static func getAllItems() -> APIRequest<ItemContainer> {
        return APIRequest<ItemContainer>(service: self, endpoint: "shop/", headers: headers, method: .GET)
    }
    
    public static func getCartItems() -> APIRequest<CartItemContainer> {
        return APIRequest<CartItemContainer>(service: self, endpoint: "shop/cart/", headers: headers, method: .GET)
    }
    
    public static func redeemPrize(itemId: String, itemInstance: String, userToken: String) -> APIRequest<RedeemItem> {
        let jsonBody: [String: Any] = [
            "itemId": itemId,
            "instance": itemInstance
        ]
        let headers: HTTPParameters = ["Authorization": userToken]

        return APIRequest<RedeemItem>(service: self, endpoint: "shop/item/buy/", body: jsonBody, headers: headers, method: .POST)
    }
    
    public static func addToCart(itemId: String, userToken: String) -> APIRequest<AddCartItem> {
        let headers: HTTPParameters = ["Authorization": userToken]

        return APIRequest<AddCartItem>(service: self, endpoint: "shop/cart/\(itemId)/", headers: headers, method: .POST)
    }
    
    public static func removeFromCart(itemId: String, userToken: String) -> APIRequest<AddCartItem> {
        let headers: HTTPParameters = ["Authorization": userToken]

        return APIRequest<AddCartItem>(service: self, endpoint: "shop/cart/\(itemId)/", headers: headers, method: .DELETE)
    }
    
    public static func redeemCart(userToken: String) -> APIRequest<AddCartItem> {
        let headers: HTTPParameters = ["Authorization": userToken]

        return APIRequest<AddCartItem>(service: self, endpoint: "shop/cart/redeem/", headers: headers, method: .POST)
    }
    
    public static func getQR(userToken: String) -> APIRequest<QRItem> {
        let headers: HTTPParameters = ["Authorization": userToken]

        return APIRequest<QRItem>(service: self, endpoint: "shop/cart/qr/", headers: headers, method: .GET)
    }
}
