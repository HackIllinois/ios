//
//  EventService.swift
//  HackIllinois
//
//  Created by HackIllinois Team on 11/19/17.
//  Copyright © 2017 HackIllinois. All rights reserved.
//  This file is part of the Hackillinois iOS App.
//  The Hackillinois iOS App is open source software, released under the University of
//  Illinois/NCSA Open Source License. You should have received a copy of
//  this license in a file with the distribution.
//

import Foundation
import APIManager

public class EventService: BaseService {

    public override class var baseURL: String {
        // return super.baseURL + "event/"
        return super.baseURL
    }

    public static func getAllEvents() -> APIRequest<EventContainer> {
        return APIRequest<EventContainer>(service: self, endpoint: "event/", method: .GET)
    }

    public static func getStaffEvents() -> APIRequest<StaffEventContainer> {
        return APIRequest<StaffEventContainer>(service: self, endpoint: "event/staff/", method: .GET)
    }
    
    public static func checkIn(code: String) -> APIRequest<EventCheckInStatus> {
        var body = HTTPBody()
        body["code"] = code
        return APIRequest<EventCheckInStatus>(service: self, endpoint: "event/checkin/", body: body, method: .POST)
    }

    public static func staffCheckIn(userToken: String, eventId: String) -> APIRequest<EventCheckInStatus> {
        var body = HTTPBody()
        body["userToken"] = userToken
        body["eventId"] = eventId
        return APIRequest<EventCheckInStatus>(service: self, endpoint: "event/staff/checkin/", body: body, method: .POST)
    }
    public static func staffMeetingAttendanceCheckIn(userToken: String, eventId: String) -> APIRequest<Attendance> {
        var body = HTTPBody()
        body["eventId"] = eventId
        var headers = HTTPHeaders()
        headers["Authorization"] = userToken
        print(APIRequest<Attendance>(service: self, endpoint: "staff/attendance/", body: body, headers: headers, method: .POST))
        return APIRequest<Attendance>(service: self, endpoint: "staff/attendance/", body: body, headers: headers, method: .POST)
    }

    public static func getStaffCheckInEvents(authToken: String) -> APIRequest<EventContainer> {
        var header = HTTPHeaders()
        header["Authorization"] = authToken
        return APIRequest<EventContainer>(service: self, endpoint: "event/", headers: header, method: .GET)
    }

    public static func create(event: Event) -> APIRequest<EventContainer> {
        let eventDict = [String: Any]()
        assert(false)
        return APIRequest<EventContainer>(service: self, endpoint: "event/", body: eventDict, method: .POST)
    }

    public static func getAllFavorites() -> APIRequest<EventFavorites> {
        return APIRequest<EventFavorites>(service: self, endpoint: "event/favorite/", method: .GET)
    }

    public static func favoriteBy(id: String) -> APIRequest<EventFavorites> {
        var body = HTTPBody()
        body["eventId"] = id
        return APIRequest<EventFavorites>(service: self, endpoint: "event/favorite/", body: body, method: .POST)
    }

    public static func unfavoriteBy(id: String) -> APIRequest<EventFavorites> {
        var body = HTTPBody()
        body["eventId"] = id
        return APIRequest<EventFavorites>(service: self, endpoint: "event/favorite/", body: body, method: .DELETE)
    }

}
