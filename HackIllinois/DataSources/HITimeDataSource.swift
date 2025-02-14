//
//  HITimeDataSource.swift
//  HackIllinois
//
//  Created by HackIllinois Team on 12/18/19.
//  Copyright © 2019 HackIllinois. All rights reserved.
//  This file is part of the Hackillinois iOS App.
//  The Hackillinois iOS App is open source software, released under the University of
//  Illinois/NCSA Open Source License. You should have received a copy of
//  this license in a file with the distribution.
//

import Foundation
import HIAPI
import os

final class HITimeDataSource {
    static var shared = HITimeDataSource()

    public static let defaultTimes = EventTimes(
        checkInStart: Date(timeIntervalSince1970: 1740774600), // Friday, February 28, 2025 2:30:00 PM CST
        checkInEnd: Date(timeIntervalSince1970: 1740783600), // Friday, February 28, 2025 5:00:00 PM CST
        scavengerHuntStart: Date(timeIntervalSince1970: 1740776400), // Friday, February 28, 2024 3:00:00 PM CST
        scavengerHuntEnd: Date(timeIntervalSince1970: 1740783600), // Friday, February 28, 2025 5:00:00 PM CST
        openingCeremonyStart: Date(timeIntervalSince1970: 1740783600), // Friday, February 28, 2025 5:00:00 PM CST
        openingCeremonyEnd: Date(timeIntervalSince1970: 1740787200), // Friday, February 28, 2025 6:00:00 PM CST
        projectShowcaseStart: Date(timeIntervalSince1970: 1740927600), // Sunday, March 2, 2025 9:00:00 AM CST
        projectShowcaseEnd: Date(timeIntervalSince1970: 1740942000), // Sunday, March 2, 2025 1:00:00 PM CST
        closingCeremonyStart: Date(timeIntervalSince1970: 1740949200), // Sunday, March 2, 2025 3:00:00 PM CST
        closingCeremonyEnd: Date(timeIntervalSince1970: 1740952800), // Sunday, March 2, 2025 4:00:00 PM CST
               
        eventStart: Date(timeIntervalSince1970: 1740774600), // Friday, February 28, 2025 2:30:00 PM CST
        eventEnd: Date(timeIntervalSince1970: 1740952800), // Sunday, March 2, 2025 4:00:00 PM CST
        hackStart: Date(timeIntervalSince1970: 1740787200), // Friday, February 28, 2025 6:00:00 PM CST
        hackEnd: Date(timeIntervalSince1970: 1740920400), // Sunday, March 2, 2025 7:00:00 AM CST
        // TODO: Need to get events + times for everything above
        fridayStart: Date(timeIntervalSince1970: 1740722400), // Friday, February 28, 2025 12:00:00 AM CST
        fridayEnd: Date(timeIntervalSince1970: 1740808799), // Friday, February 28, 2025 11:59:59 PM CST
        saturdayStart: Date(timeIntervalSince1970: 1740808800), // Saturday, March 1, 2025 12:00:00 AM CST
        saturdayEnd: Date(timeIntervalSince1970: 1740895199), // Saturday, March 1, 2025 11:59:59 PM CST
        sundayStart: Date(timeIntervalSince1970: 1740895200), // Sunday, March 2, 2025 12:00:00 AM CST
        sundayEnd: Date(timeIntervalSince1970: 1740981599) // Sunday, March 2, 2025 11:59:59 PM CST
    )

    var eventTimes = HITimeDataSource.defaultTimes

    private init() {
        self.updateTimes()
    }

    ///Returns whether times have been updated or not with synchronous api call to get times
    func updateTimes() {
        let semaphore = DispatchSemaphore(value: 0)

        // Update the times of event
        TimeService.getTimes()
            .onCompletion { result in
                do {
                    let (timeContainer, _) = try result.get()
                    self.eventTimes = timeContainer.eventTimes
                } catch {
                    os_log(
                        "Unable to update event times, setting default HackIllinois 2021 times: %s",
                        log: Logger.api,
                        type: .error,
                        String(describing: error)
                    )
                }
                semaphore.signal()
            }
            .launch()

        //Synchronous API call to get times
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }
}
