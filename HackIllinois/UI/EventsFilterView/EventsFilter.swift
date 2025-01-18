//
//  EventsFilter.swift
//  HackIllinois
//
//  Created by Anushka Sankaran on 1/18/25.
//  Copyright © 2025 HackIllinois. All rights reserved.
//

import SwiftUI

struct EventsFilter: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                RoundedRectangleView(label: "Company")
                RoundedRectangleView(label: "Time")
                RoundedRectangleView(label: "Event")
            }
            .padding()
        }
    }
}

struct RoundedRectangleView: View {
    let label: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "square") // Empty checkbox
                .resizable()
                .frame(width: 16, height: 16)
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: 16, weight: .bold))
            Text(label)
                .font(Font(HIAppearance.Font.timeText ?? .systemFont(ofSize: 20)))
                .lineLimit(1)
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 8)
        .background(
            Group {
                if label == "Company" {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color(HIAppearance.rawSienna))
                } else if label == "Time" {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color(HIAppearance.neptune))
                } else {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color(HIAppearance.lightningYellow))
                }
            }            
        )
        .fixedSize(horizontal: true, vertical: true)
    }
}

#Preview {
    EventsFilter()
}
