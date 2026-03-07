//
//  DrawingView.swift
//  Fourier
//
//  Created by Jack Finnis on 07/03/2026.
//

import SwiftUI
import StoreKit

struct DrawingView: View {
    @Bindable var model: Model
    let path: Path

    @State var showExport = false

    var body: some View {
        ZStack {
            if model.isAnimating {
                EpicycleView(model: model)
                    .ignoresSafeArea()
            } else {
                PathView(path: path)
                    .ignoresSafeArea()
            }
        }
        .toolbar {
            if !model.isDrawing {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        model.reset()
                    } label: {
                        Label("Reset", systemImage: "xmark")
                    }
                }
                ToolbarItemGroup(placement: .primaryAction) {
                    if model.isAnimating {
                        Button {
                            model.speed = model.speed.next
                        } label: {
                            Text(model.speed.label)
                                .monospacedDigit()
                        }
                    }
                    Button {
                        model.isAnimating.toggle()
                    } label: {
                        Label(model.isAnimating ? "Stop" : "Play", systemImage: model.isAnimating ? "stop.fill" : "play.fill")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        model.renderPNG()
                        model.renderGIF()
                        showExport = true
                    } label: {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                    .confirmationDialog("Export", isPresented: $showExport) {
                        ShareLink("Image", item: .sharePNG)
                        ShareLink("Video", item: .shareGIF)
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Slider(value: $model.epicycles, in: model.nRange, step: 1) { isSliding in
                        if !isSliding { model.update() }
                    }
                    .padding(.horizontal, 10)
                }
                ToolbarSpacer(placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    Stepper("Epicycles", value: $model.epicycles, in: model.nRange) { isStepping in
                        if !isStepping { model.update() }
                    }
                    .font(.headline)
                    .labelsHidden()
                    .padding(.horizontal, 5)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
