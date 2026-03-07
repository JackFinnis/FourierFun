//
//  ContentView.swift
//  Fourier
//
//  Created by Jack Finnis on 07/03/2026.
//

import SwiftUI
import StoreKit

struct ContentView: View {
    @Environment(\.requestReview) var requestReview
    @AppStorage("featuresUsed") var featuresUsed = 0
    @State var model = Model()

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let size = CGSize(
                    width: geo.size.width + geo.safeAreaInsets.leading + geo.safeAreaInsets.trailing,
                    height: geo.size.height + geo.safeAreaInsets.top + geo.safeAreaInsets.bottom
                )

                ZStack {
                    Rectangle()
                        .fill(.background)

                    if let path = model.path {
                        DrawingView(model: model, path: path)
                    } else {
                        WelcomeView(model: model, size: size)
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .global)
                        .onChanged { value in
                            if value.location == value.startLocation {
                                model.isDrawing = true
                                model.isAnimating = false
                                model.path = Path()
                                model.path?.move(to: value.location)
                            } else {
                                model.path?.addLine(to: value.location)
                            }
                        }
                        .onEnded { _ in
                            model.isDrawing = false
                            guard let path = model.path else { return }
                            let points = path.cgPath.copy(dashingWithPhase: 0, lengths: [10]).points
                            model.transform(points: points, size: size)
                        }
                )
            }
        }
        .onChange(of: model.path) { _, _ in
            if model.path == nil {
                featuresUsed += 1
            }
        }
        .onChange(of: featuresUsed) { _, _ in
            if featuresUsed.isMultiple(of: 10) {
                requestReview()
            }
        }
    }
}

#Preview {
    ContentView()
}
