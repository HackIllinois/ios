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
    public let items: [CartItem]
    public let userId: String

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let itemsDict = try container.decode([String: Int].self, forKey: .items)
        self.userId = try container.decode(String.self, forKey: .userId)

        self.items = itemsDict.map { key, value in
            CartItem(additionalProperties: [key: value])
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case items, userId
    }
}

public struct CartItem: Codable, Hashable {
    public let additionalProperties: [String: Int]
}
