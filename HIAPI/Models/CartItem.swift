//
//  CartItem.swift
//  HackIllinois
//
//  Created by Anushka Sankaran on 2/14/25.
//  Copyright © 2025 HackIllinois. All rights reserved.
//

import Foundation
import APIManager

public struct CartItemContainer: Decodable, APIReturnable {
    public let items: [String: Int]
    public let userId: String

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.items = try container.decode([String: Int].self, forKey: .items)
        self.userId = try container.decode(String.self, forKey: .userId)
    }
    
    private enum CodingKeys: String, CodingKey {
        case items, userId
    }
}

public struct AddCartItem: Codable, APIReturnable {
    public let items: [String: Int]? // Return itemName upon success
    public let userId: String?
    public let error: String?
    public let message: String?
}
