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
    
    var title: String {
        if model.path == nil {
            return "Fourier Fun"
        } else if model.isDrawing {
            return ""
        } else {
            return Int(model.epicycles).formatted(singular: "Epicycle")
        }
    }
    
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
                        PathRenderer(path: path)
                            .ignoresSafeArea()
                    } else {
                        Image(systemName: "hand.draw.fill")
                            .font(.largeTitle)
                            .imageScale(.large)
                            .foregroundStyle(.secondary)
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .global)
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
                            model.transform(points: points, size: size)
                        }
                )
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarTitleMenu {
                    Link(destination: URL(string: "https://youtu.be/r6sGWTCMz2k")!) {
                        Label("But what is a Fourier series?", systemImage: "safari")
                    }
                    Divider()
                    Button {
                        requestReview()
                    } label: {
                        Label("Rate Fourier Fun", systemImage: "star")
                    }
                    Link(destination: URL(string: "mailto:jack@jackfinnis.com?subject=Fourier%20Fun%20Feedback")!) {
                        Label("Improve Fourier Fun", systemImage: "envelope")
                    }
                }
                .toolbar {
                    if model.path == nil {
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
                                            model.importSVG(result: .success(file.url), size: size)
                                        } label: {
                                            Label(file.name, systemImage: file.systemImage)
                                        }
                                    }
                                }
                            } label: {
                                Label("View Example", systemImage: "plus")
                            }
                            .menuOrder(.fixed)
                            .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.svg]) { result in
                                model.importSVG(result: result, size: size)
                            }
                        }
                    } else if !model.isDrawing {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                model.reset()
                            } label: {
                                Label("Reset", systemImage: "trash")
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            ShareLink(item: Constants.shareURL)
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
                .monospacedDigit()
            }
        }
    }
}

#Preview {
    ContentView()
}
