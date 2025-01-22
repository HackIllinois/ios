//
//  EventsFilterTimePopup.swift
//  HackIllinois
//
//  Created by Anushka Sankaran on 1/19/25.
//  Copyright © 2025 HackIllinois. All rights reserved.
//

import SwiftUI

func convertUnixTimeToCST(unixTime: TimeInterval) -> String {
    // Create a Date object from the Unix time
    let date = Date(timeIntervalSince1970: unixTime)
    
    // Set up the DateFormatter
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(identifier: "America/Chicago") // CST timezone
    dateFormatter.dateFormat = "h:mm a" // Hour and minute format
    
    // Convert the date to a formatted string
    let formattedTime = dateFormatter.string(from: date)
    return formattedTime
}

func parseCSTTime(unixTime: TimeInterval) -> (time: String, period: String) {
    // Convert the Unix time to a formatted CST time string
    let fullTime = convertUnixTimeToCST(unixTime: unixTime)
    
    // Split the string into the time and period (AM/PM) parts
    let components = fullTime.split(separator: " ")
    guard components.count == 2 else {
        return (time: "Invalid", period: "Time") // Return a fallback in case of formatting issues
    }
    
    let time = String(components[0]) // The 12-hour time part
    let period = String(components[1]) // The AM/PM part
    return (time: time, period: period)
}

struct EventsFilterTimePopup: View {
    @Binding var startTime: TimeInterval
    @Binding var endTime: TimeInterval
    @Binding var closePopup: Bool
    
    var body: some View {
        TimeFilter(startTime: $startTime, endTime: $endTime, closePopup: $closePopup)
    }
}

struct TimeFilter: View {
    @Binding var startTime: TimeInterval
    @Binding var endTime: TimeInterval
    @Binding var closePopup: Bool
    var body: some View {
            ZStack {
                // Image for the filter popup
                Image("FilterPopupTime")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width - 50) // Resize image width as needed
                    .clipped() // Ensure no overflow if image exceeds bounds
                // Close Button (TODO: Make transparent)
                ZStack {
                    Rectangle()
                        .frame(width: 50, height: 50)
                        .onTapGesture {
                            print("Closed popup")
                            closePopup = true
                        }
                }
                .frame(width: UIScreen.main.bounds.width - 50, height: (UIScreen.main.bounds.width - 50) * (227/309), alignment: .topLeading)
                // Save and clear buttons
                HStack {
                    // Clear button
                    Text("Clear Filter")
                        .font(Font(HIAppearance.Font.navigationSubtitle ?? .systemFont(ofSize: 20)))
                        .foregroundColor(Color(HIAppearance.metallicCopper))
                        .padding(.trailing, 5)
                        .onTapGesture {
                            print("Clear")
                        }
                    // Save button
                    HStack(spacing: 8) {
                        Text("SAVE")
                            .font(Font(HIAppearance.Font.timeText ?? .systemFont(ofSize: 20)))
                            .foregroundColor(Color(HIAppearance.metallicCopper))
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 13)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color(HIAppearance.yellowOrange))
                    )
                    .fixedSize(horizontal: true, vertical: true)
                    .onTapGesture {
                        print("Save")
                    }
                }
                .frame(width: UIScreen.main.bounds.width - 100, height: (UIScreen.main.bounds.width - 50) * (227/309) - 40, alignment: .bottomTrailing)
                HStack {
                    // Start of interval
                    let parsedStartTime = parseCSTTime(unixTime: startTime)
                    HStack {
                        HourPicker(hour: "\(parsedStartTime.time)")
                        PeriodIndicator(meridian: "\(parsedStartTime.period)")
                    }
                    Text("to")
                        .padding(.horizontal, 10)
                        .foregroundColor(Color(HIAppearance.metallicCopper))
                        .font(Font(HIAppearance.Font.navigationSubtitle ?? .systemFont(ofSize: 20)))
                    // End of interval
                    let parsedEndTime = parseCSTTime(unixTime: endTime)
                    HStack {
                        HourPicker(hour: "\(parsedEndTime.time)")
                        PeriodIndicator(meridian: "\(parsedEndTime.period)")
                    }
                    
                }
                .padding(.top, (UIScreen.main.bounds.width - 50) * (50/309))
            }
        }
}

struct PeriodIndicator: View {
    let meridian: String
    var body: some View {
        HStack {
            Text(meridian)
                .foregroundColor(Color(HIAppearance.metallicCopper))
                .padding(.trailing, -3)
            Image(systemName: "arrowtriangle.down.fill")
                .resizable()
                .frame(width: 10, height: 6)
                .foregroundColor(Color(HIAppearance.doveGray))
        }
        .font(Font(HIAppearance.Font.eventButtonText ?? .systemFont(ofSize: 20)))
        .overlay(
            Rectangle()
                .foregroundColor(Color(HIAppearance.doveGray))
                .frame(height: 1)
                .offset(y: 4), alignment: .bottom
        )
    }
}

struct HourPicker: View {
    let hour: String
    var body: some View {
        HStack {
            Text(hour)
                .foregroundColor(Color(HIAppearance.metallicCopper))
                .padding(.trailing, -3)
            Image(systemName: "arrowtriangle.down.fill")
                .resizable()
                .frame(width: 10, height: 6)
                .foregroundColor(Color(HIAppearance.doveGray))
        }
        .font(Font(HIAppearance.Font.eventButtonText ?? .systemFont(ofSize: 20)))
        .padding(4)
        .overlay(
            Rectangle()
                .stroke(Color(HIAppearance.doveGray))
        )
    }
}

#Preview {
    struct Preview: View {
        @State var startTime: TimeInterval = 1740856500
        @State var endTime: TimeInterval = 1740863700
        @State var closePopup = false
        var body: some View {
            EventsFilterTimePopup(startTime: $startTime, endTime: $endTime, closePopup: $closePopup)
        }
    }

    return Preview()
}
