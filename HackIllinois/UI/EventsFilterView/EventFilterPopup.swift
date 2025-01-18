//
//  EventFilterPopup.swift
//  HackIllinois
//
//  Created by Anushka Sankaran on 1/18/25.
//  Copyright © 2025 HackIllinois. All rights reserved.
//

import SwiftUI

struct EventFilterPopup: View {
    var body: some View {
        CategoryFilter()
    }
}

struct CategoryFilter: View {
    var body: some View {
            ZStack {
                // Image for the filter popup
                Image("FilterPopupCategory")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width - 50) // Resize image width as needed
                    .clipped() // Ensure no overflow if image exceeds bounds

                // ScrollView that sits on top of the image and spans its height
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 16) {
                        // Example company items
                        ForEach(1..<11, id: \.self) { index in
                            HStack(spacing: 8) {
                                Image(systemName: "square") // Empty checkbox
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .symbolRenderingMode(.hierarchical)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(HIAppearance.elephant))
                                Text("Option")
                                    .font(Font(HIAppearance.Font.navigationSubtitle ?? .systemFont(ofSize: 20)))
                                    .foregroundColor(Color(HIAppearance.elephant))
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(.top, (UIScreen.main.bounds.width - 50) * (251/309)/14)
                .frame(width: UIScreen.main.bounds.width - 125, height: (UIScreen.main.bounds.width - 50) * (251/309)/1.9)
                //
                // Save and clear buttons
                HStack {
                    // Clear button
                    Text("Clear Filter")
                        .font(Font(HIAppearance.Font.navigationSubtitle ?? .systemFont(ofSize: 20)))
                        .foregroundColor(Color(HIAppearance.elephant))
                        .padding(.trailing, 5)
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
                }
                .frame(width: UIScreen.main.bounds.width - 100, height: (UIScreen.main.bounds.width - 50) * (251/309) - 40, alignment: .bottomTrailing)
            }
        }
}

#Preview {
    EventFilterPopup()
}
