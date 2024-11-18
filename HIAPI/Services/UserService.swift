//
//  UserService.swift
//  HackIllinois
//
//  Created by HackIllinois Team on 1/23/18.
//  Copyright © 2018 HackIllinois. All rights reserved.
//  This file is part of the Hackillinois iOS App.
//  The Hackillinois iOS App is open source software, released under the University of
//  Illinois/NCSA Open Source License. You should have received a copy of
//  this license in a file with the distribution.
//

import Foundation
import APIManager

public final class UserService: BaseService {
    public override static var baseURL: String {
        return super.baseURL + "user/"
    }

    public static func getUser() -> APIRequest<User> {
        return APIRequest<User>(service: self, endpoint: "", headers: headers, method: .GET)
    }

    public static func getQR(userToken: String) -> APIRequest<QRData> {
        var authorizationHeaders = HTTPHeaders()
        authorizationHeaders["Authorization"] = userToken
        return APIRequest<QRData>(service: self, endpoint: "qr/", headers: authorizationHeaders, method: .GET)
    }
    
    public static func favoriteEvent(userToken: String, eventID: String) -> APIRequest<FollowStatus> {
        var authorizationHeaders = HTTPHeaders()
        authorizationHeaders["Authorization"] = userToken
        let endpoint = "follow/\(eventID)/"
        return APIRequest<FollowStatus>(service: self, endpoint: endpoint, headers: authorizationHeaders, method: .PUT)
    }
    
    public static func unfavoriteEvent(userToken: String, eventID: String) -> APIRequest<FollowStatus> {
        var authorizationHeaders = HTTPHeaders()
        authorizationHeaders["Authorization"] = userToken
        let endpoint = "unfollow/\(eventID)/"
        return APIRequest<FollowStatus>(service: self, endpoint: endpoint, headers: authorizationHeaders, method: .DELETE)
    }
    
    public static func userScanEvent(userToken: String, eventID: String) -> APIRequest<UserCheckInStatus> {
        var authorizationHeaders = HTTPHeaders()
        authorizationHeaders["Authorization"] = userToken
        var body = HTTPBody()
        body["eventId"] = eventID
        return APIRequest<UserCheckInStatus>(service: self, endpoint: "scan-event/", body: body, headers: authorizationHeaders, method: .PUT)
    }
}
