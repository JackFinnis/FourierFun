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
    
    @State var showFileImporter = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                Rectangle()
                    .fill(.background)
                    .overlay {
                        if let path = model.path {
                            PathRenderer(path: path)
                        } else {
                            Image(systemName: "hand.draw.fill")
                                .font(.largeTitle)
                                .imageScale(.large)
                                .foregroundStyle(.secondary)
                        }
                    }
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
                    .navigationTitle("FourierFun")
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
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Menu {
                                Button {
                                    showFileImporter = true
                                } label: {
                                    Label("Import SVG", systemImage: "square.and.arrow.down")
                                }
                                Section("View Example") {
                                    ForEach(ExampleFile.allCases, id: \.self) { file in
                                        Button {
                                            model.importSVG(result: .success(file.url), size: geo.size)
                                        } label: {
                                            Label(file.name, systemImage: file.systemImage)
                                        }
                                    }
                                }
                            } label: {
                                Label("View Example", systemImage: "plus")
                            }
                            .menuOrder(.fixed)
                        }
                    }
                    .sheet(isPresented: .constant(true)) {
                        NavigationStack {
                            if model.path != nil && !model.isDrawing {
                                Slider(value: $model.epicycles, in: model.nRange, step: 1) { isSliding in
                                    if !isSliding { model.update() }
                                }
                                .padding(20)
                                .navigationBarTitleDisplayMode(.inline)
                                .toolbar {
                                    ToolbarItem(placement: .cancellationAction) {
                                        Button {
                                            model.reset()
                                        } label: {
                                            Label("Reset", systemImage: "xmark")
                                        }
                                    }
                                    ToolbarItem(placement: .principal) {
                                        Stepper(Int(model.epicycles).formatted(singular: "Epicycle"), value: $model.epicycles, in: model.nRange) { isStepping in
                                            if !isStepping { model.update() }
                                        }
                                        .font(.headline)
                                    }
                                    ToolbarItem(placement: .topBarTrailing) {
                                        ShareLink(item: Constants.shareURL)
                                    }
                                }
                            }
                        }
                        .interactiveDismissDisabled()
                        .presentationBackgroundInteraction(.enabled)
                        .presentationDetents([PresentationDetent.height(Constants.actionBarHeight)])
                    }
                    .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.svg]) { result in
                        model.importSVG(result: result, size: geo.size)
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}
