//
//  FourierApp.swift
//  Fourier
//
//  Created by Jack Finnis on 24/08/2021.
//

import SwiftUI
import StoreKit

@main
struct FourierApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @Environment(\.requestReview) var requestReview
    @AppStorage("featuresUsed") var featuresUsed = 0
    @State var model = Model()
    @State var showFileImporter = false
    
    var title: String {
        if model.path == nil {
            return "Fourier"
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
                        Label("But what is a Fourier series?", systemImage: "play.rectangle.fill")
                    }
                    Section("Fourier") {
                        Button {
                            requestReview()
                        } label: {
                            Label("Rate This App", systemImage: "star")
                        }
                        Link(destination: URL(string: "https://apps.apple.com/app/id1582827502?action=write-review")!) {
                            Label("Leave a Review", systemImage: "quote.bubble")
                        }
                        Link(destination: URL(string: "mailto:jack@jackfinnis.com?subject=Fourier%20Feedback")!) {
                            Label("Send Feedback", systemImage: "envelope")
                        }
                        Link(destination: URL(string: "https://apps.apple.com/developer/1633101066")!) {
                            Label("More Apps by Jack", systemImage: "square.grid.2x2")
                        }
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

struct PathRenderer: View {
    let path: Path
    
    var body: some View {
        path.stroke(Color.accentColor, style: .init(lineWidth: 3, lineCap: .round, lineJoin: .round))
    }
}
