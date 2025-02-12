//
//  HICarouselSwiftUIView.swift
//  HackIllinois
//
//  Created by HackIllinois Team on 10/29/22.
//  Copyright © 2022 HackIllinois. All rights reserved.
//  This file is part of the Hackillinois iOS App.
//  The Hackillinois iOS App is open source software, released under the University of
//  Illinois/NCSA Open Source License. You should have received a copy of
//  this license in a file with the distribution.
//

import Foundation
import SwiftUI

struct CarouselData: Hashable {
    let image: UIImage?
    let titleText: String
    let descriptionText: String
}

struct HICarouselSwiftUIView: View {
    var carouselData: [CarouselData]
    @State private var currentIndex = 0
    var body: some View {
        VStack {
            Spacer()
            TabView(selection: $currentIndex) {
                ForEach(0..<carouselData.count, id: \.self) { index in
                    VStack {
                        Spacer()
                        Image(uiImage: carouselData[index].image!)
                            .resizable()
                            .scaledToFit()
                            .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 600: 475)
                        HILableSUI(text: carouselData[index].titleText, style: .onboardingTitle)
                            .frame(width: 20, height: 20)
                            .padding(.top, 10)
                        Text(carouselData[index].descriptionText)
                            .bold()
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 10)
                    }
                    .tag(index)
                    .padding(.horizontal, horizontalCarouselPadding)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            HITabIndicator(count: carouselData.count, current: $currentIndex)
        }
        .frame(width: UIScreen.main.bounds.width)
        .padding(.horizontal, -horizontalCarouselPadding)
        .ignoresSafeArea()
    }
    
    var horizontalCarouselPadding: CGFloat {
        let maxWidth = UIScreen.main.bounds.width
        let carouselWidth = min(800, maxWidth)
        let padding = maxWidth - carouselWidth
        return max(
            CGFloat(padding / 3.0),
            60
        )
    }
}

struct HITabIndicator: View {
    var count: Int
    @Binding var current: Int
    var body: some View {
        HStack {
            ForEach(0 ..< count, id: \.self) {index in
                ZStack {
                    if current == index {
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                            .background(Circle().fill(.white))
                    } else {
                        Circle()
                            .fill(Color.clear)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                            )
                    }
                }.frame(width: 10, height: 10)
            }
        }
    }
}

// MARK: - SwiftUI => HILabel
struct HILableSUI: UIViewRepresentable {
    var text: String
    var style: HILabel.Style?
    func makeUIView(context: Context) -> UILabel {
        let label = HILabel(style: style)
        label.text = text
        return label
    }
    func updateUIView(_ uiView: UILabel, context: Context) {
        return
    }
}

struct CarouselSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        HIOnboardingView()
    }
}
