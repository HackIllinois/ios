//
//  EventFilterPopup.swift
//  HackIllinois
//
//  Created by Anushka Sankaran on 1/18/25.
//  Copyright © 2025 HackIllinois. All rights reserved.
//

import SwiftUI

struct EventFilterPopup: View {
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
        CategoryFilter(allOptions: $allOptions, currentlySelected: $currentlySelected, tempSelected: $tempSelected, closePopup: $closePopup)
    }
}

struct CategoryFilter: View {
    @Binding var allOptions: [String]
    @Binding var currentlySelected: [String]
    @Binding var tempSelected: [String]
    @Binding var closePopup: Bool
    var body: some View {
            ZStack {
                // Image for the filter popup
                Image("FilterPopupCategory")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width - 50) // Resize image width as needed
                    .clipped() // Ensure no overflow if image exceeds bounds
                // Close Button
                ZStack {
                    Rectangle()
                        .frame(width: 50, height: 50)
                        .onTapGesture {
                            print("Closed popup")
                            closePopup = true
                        }
                }
                .frame(width: UIScreen.main.bounds.width - 50, height: (UIScreen.main.bounds.width - 50) * (251/309), alignment: .topLeading)
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
                .frame(width: UIScreen.main.bounds.width - 100, height: (UIScreen.main.bounds.width - 50) * (251/309) - 40, alignment: .bottomTrailing)
                //
                // ScrollView that sits on top of the image and spans its height
                OptionsScroll(allOptions: $allOptions, tempSelected: $tempSelected)
                .padding(.top, (UIScreen.main.bounds.width - 50) * (251/309)/14)
                .frame(width: UIScreen.main.bounds.width - 125, height: (UIScreen.main.bounds.width - 50) * (251/309)/1.9)
            }
        }
}

struct OptionsScroll: View {
    @Binding var allOptions: [String]
    @Binding var tempSelected: [String]
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 16) {
                // Example company items
                ForEach(allOptions, id: \.self) { option in
                    HStack(spacing: 8) {
                        Image(systemName: tempSelected.contains(option) ? "checkmark.square" : "square") // Empty checkbox
                            .resizable()
                            .frame(width: 16, height: 16)
                            .symbolRenderingMode(.hierarchical)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(HIAppearance.elephant))
                        Text(option)
                            .font(Font(HIAppearance.Font.navigationSubtitle ?? .systemFont(ofSize: 20)))
                            .foregroundColor(Color(HIAppearance.elephant))
                            .lineLimit(1)
                    }
                    .onTapGesture {
                        print("Tapped: ", option)
                        if tempSelected.contains(option) {
                            tempSelected.removeAll { $0 == option } // Deselect
                        } else {
                            tempSelected.append(option)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

#Preview {
    struct Preview: View {
        @State var allOptions = ["a", "b", "c"]
        @State var currentlySelected = ["a"]
        @State var closePopup = false
        var body: some View {
            EventFilterPopup(allOptions: $allOptions, currentlySelected: $currentlySelected, closePopup: $closePopup)
        }
    }

    return Preview()
}
