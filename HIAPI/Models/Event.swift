//
//  Event.swift
//  HackIllinois
//
//  Created by HackIllinois Team on 4/16/17.
//  Copyright © 2017 HackIllinois. All rights reserved.
//  This file is part of the Hackillinois iOS App.
//  The Hackillinois iOS App is open source software, released under the University of
//  Illinois/NCSA Open Source License. You should have received a copy of
//  this license in a file with the distribution.
//

import Foundation
import APIManager

public struct EventContainer: Decodable, APIReturnable {
    public let events: [Event]

    public init(from data: Data) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        self = try decoder.decode(EventContainer.self, from: data)
    }
}

public struct StaffEventContainer: Decodable, APIReturnable {
    public let events: [StaffEvent]

    public init(from data: Data) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        self = try decoder.decode(StaffEventContainer.self, from: data)
    }
}

public struct StaffEvent: Codable {
    internal enum CodingKeys: String, CodingKey {
        case id = "eventId"
        case endTime
        case eventType
        case info = "description"
        case locations
        case name
        case sponsor
        case startTime
        case points
        case isAsync
        case isPrivate
        case displayOnStaffCheckin
        case isStaff
        case mapImageUrl
    }

    public var id: String
    public let endTime: Date
    public let eventType: String
    public let info: String
    public let locations: [Location]
    public let name: String
    public let sponsor: String?
    public let startTime: Date
    public let points: Int?
    public let isAsync: Bool
    public let isPrivate: Bool?
    public let displayOnStaffCheckin: Bool?
    public let isStaff: Bool
    public let mapImageUrl: String?
}


public struct Event: Codable {
    internal enum CodingKeys: String, CodingKey {
        case id = "eventId"
        case endTime
        case eventType
        case info = "description"
        case locations
        case name
        case sponsor
        case startTime
        case points
        case isAsync
        case mapImageUrl
        case displayOnStaffCheckIn
        case isPro
    }

    public let id: String
    public let endTime: Date
    // Could be made into an enum with some coredata work
    public let eventType: String
    public let info: String
    public let locations: [Location]
    public let name: String
    public let sponsor: String?
    public let startTime: Date
    public let points: Int
    public let isAsync: Bool
    public let mapImageUrl: String?
    public let displayOnStaffCheckIn: Bool?
    public let isPro: Bool?
}

public struct Location: Codable {
    internal enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case name = "description"
    }

    public let latitude: Double
    public let longitude: Double
    public let name: String
}

public struct EventFavorites: Codable, APIReturnable {
    public let events: Set<String>
    public let id: String
}

public struct EventCheckInStatus: Codable, APIReturnable {
    public let newPoints: Int
    public let totalPoints: Int
    public let status: String
}

public struct EventTracker: Codable {
    public let eventId: String
    public let users: [String]
}

public struct Attendance: Codable, APIReturnable {
    public let success: Bool? // Present in success responses
    public let error: String? // Present in error responses
    public let message: String? // Present in error responses
}
