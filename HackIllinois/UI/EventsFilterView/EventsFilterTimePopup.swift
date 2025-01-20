//
//  EventsFilterTimePopup.swift
//  HackIllinois
//
//  Created by Anushka Sankaran on 1/19/25.
//  Copyright © 2025 HackIllinois. All rights reserved.
//

import SwiftUI

struct EventsFilterTimePopup: View {
    @Binding var allOptions: [String]
    @Binding var currentlySelected: [String]
    @Binding var closePopup: Bool
    
    @State private var tempSelected: [String]
        
    init(allOptions: Binding<[String]>, currentlySelected: Binding<[String]>, closePopup: Binding<Bool>) {
        // Initialize the tempSelected state variable with the current selected options
        _allOptions = allOptions
        _currentlySelected = currentlySelected
        _closePopup = closePopup
        _tempSelected = State(initialValue: currentlySelected.wrappedValue)
    }
    
    var body: some View {
        TimeFilter(allOptions: $allOptions, currentlySelected: $currentlySelected, tempSelected: $tempSelected, closePopup: $closePopup)
    }
}

struct TimeFilter: View {
    @Binding var allOptions: [String]
    @Binding var currentlySelected: [String]
    @Binding var tempSelected: [String]
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
                        .foregroundColor(Color(HIAppearance.elephant))
                        .padding(.trailing, 5)
                        .onTapGesture {
                            tempSelected = []
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
                        currentlySelected = tempSelected
                        closePopup = true
                    }
                }
                .frame(width: UIScreen.main.bounds.width - 100, height: (UIScreen.main.bounds.width - 50) * (227/309) - 40, alignment: .bottomTrailing)
                // Start of interval
                HStack {
                    HourPicker()
                    PeriodIndicator()
                }
                .padding(.top, 55)
                .padding(.trailing, 165)
                // End of interval
                HStack {
                    HourPicker()
                    PeriodIndicator()
                }
                .padding(.top, 55)
                .padding(.leading, 165)
            }
        }
}

struct PeriodIndicator: View {
    var body: some View {
        HStack {
            Text("AM")
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
    var body: some View {
        HStack {
            Text("00:00")
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
        @State var allOptions = ["a", "b", "c"]
        @State var currentlySelected = ["a"]
        @State var closePopup = false
        var body: some View {
            EventsFilterTimePopup(allOptions: $allOptions, currentlySelected: $currentlySelected, closePopup: $closePopup)
        }
    }

    return Preview()
}
