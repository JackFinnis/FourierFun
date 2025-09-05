//
//  RootView.swift
//  Fourier
//
//  Created by Jack Finnis on 22/07/2024.
//

import SwiftUI
import StoreKit

struct ContentView: View {
    @Environment(\.requestReview) var requestReview
    @State var model = Model()
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                Color(.systemGray6)
                    .ignoresSafeArea()
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if value.location == value.startLocation {
                                    model.isDrawing = true
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
                                model.transform(points: points, size: geo.size)
                            }
                    )
                    .overlay {
                        if let path = model.path {
                            PathRenderer(path: path)
                        } else {
                            Image(systemName: "hand.draw")
                                .font(.largeTitle)
                                .imageScale(.large)
                                .foregroundStyle(.secondary)
                                .padding(.bottom, 50)
                                .allowsHitTesting(false)
                        }
                    }
                    .overlay(alignment: .bottom) {
#if os(iOS)
                        ActionBar(model: model, geo: geo)
                            .frame(height: Constants.actionBarHeight)
                            .frame(maxWidth: .infinity)
                            .background(.bar)
                            .overlay(alignment: .top) {
                                Divider()
                            }
#endif
                    }
            }
#if os(visionOS)
            .ornament(attachmentAnchor: .scene(.bottom)) {
                ActionBar(model: model, geo: geo)
                    .frame(width: 500, height: 115)
                    .glassBackgroundEffect(in: RoundedRectangle(cornerRadius: 30))
            }
#endif
            .navigationTitle("FourierFun")
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarTitleMenu {
                Button {
                    requestReview()
                } label: {
                    Label("Rate FourierFun", systemImage: "star")
                }
                Link(destination: URL(string: "mailto:jack@jackfinnis.com?subject=FourierFun%20Feedback")!) {
                    Label("Improve FourierFun", systemImage: "envelope")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
