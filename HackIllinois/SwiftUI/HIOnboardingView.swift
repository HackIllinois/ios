//
//  HIOnboardingView.swift
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
import UIKit
import Lottie

struct HIOnboardingView: View {
    @StateObject private var viewModel = HIOnboardingViewModel()
    var body: some View {
        ZStack {
            Image(getBackgroundImageName())
                .resizable()
                .ignoresSafeArea()
                .zIndex(-1)
            if viewModel.shouldDisplayAnimationOnNextAppearance {
                VStack {
                    LottieView(shouldDisplayAnimationOnNextAppearance: $viewModel.shouldDisplayAnimationOnNextAppearance)
                }
            } else {
                VStack {
                    HICarouselSwiftUIView(carouselData: viewModel.data)
                    
                    Spacer()
                }
            }
        }
    }
    
    func getBackgroundImageName() -> String {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return "iPadLogin"
        } else {
            return "Login"
        }
    }
}

// MARK: - SwiftUI => LottieView
struct LottieView: UIViewRepresentable {
    @Binding var shouldDisplayAnimationOnNextAppearance: Bool
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView(name: "Hack_Mushroom_Loading")
        animationView.contentMode = .scaleAspectFit
        animationView.frame = view.frame
        animationView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(animationView)
        animationView.play { _ in
            withAnimation(.easeInOut(duration: 1)) {
                shouldDisplayAnimationOnNextAppearance.toggle()
            }
        }
        return view
    }
    func updateUIView(_ uiView: UIViewType, context: Context) { return }
}

struct HIOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        HIOnboardingView()
    }
}
