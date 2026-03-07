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
    @State var showFileImporter = false

    var title: String {
        if model.path == nil || model.isDrawing {
            return "Fourier"
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
                        if model.isAnimating {
                            EpicycleView(model: model)
                        } else {
                            path.stroke(.accent, style: .init(lineWidth: 3, lineCap: .round, lineJoin: .round))
                        }
                    } else {
                        Image(systemName: "hand.draw.fill")
                            .font(.largeTitle)
                            .imageScale(.large)
                            .foregroundStyle(.secondary)
                    }
                }
                .ignoresSafeArea()
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .global)
                        .onChanged { value in
                            if value.location == value.startLocation {
                                model.isDrawing = true
                                model.isAnimating = false
                                model.points = []
                                model.epicycles = 2
                                model.path = Path()
                                model.path?.move(to: value.location)
                            } else {
                                model.path?.addLine(to: value.location)
                            }
                        }
                        .onEnded { _ in
                            model.isDrawing = false
                            guard let path = model.path else { return }
                            let points = path.cgPath.samplePoints()
                            model.transform(points: points, size: size)
                        }
                )
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(title)
                            .font(.headline)
                            .monospacedDigit()
                    }
                }
                .toolbarTitleMenu {
                    Link(destination: URL(string: "https://youtu.be/r6sGWTCMz2k")!) {
                        Text("But what is a Fourier series?")
                        Text("3Blue1Brown, YouTube")
                        Image(systemName: "play.rectangle.fill")
                    }
                    Section("Fourier") {
                        Button {
                            requestReview()
                        } label: {
                            Label("Rate Fourier", systemImage: "star")
                        }
                        Link(destination: URL(string: "https://apps.apple.com/app/id1582827502?action=write-review")!) {
                            Label("Write a Review", systemImage: "quote.bubble")
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
                                Section("Import SVG") {
                                    Button {
                                        showFileImporter = true
                                    } label: {
                                        Text("Choose File")
                                        Image(systemName: "folder")
                                    }
                                }
                                Section("Examples") {
                                    ForEach(ExampleFile.allCases, id: \.self) { file in
                                        Button {
                                            model.importSVG(url: file.url, size: size)
                                        } label: {
                                            Text(file.name)
                                        }
                                    }
                                }
                            } label: {
                                Label("Import", systemImage: "plus")
                            }
                            .menuOrder(.fixed)
                            .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.svg]) { result in
                                switch result {
                                case .success(let url):
                                    model.importSVG(url: url, size: size)
                                case .failure(let error):
                                    print(error)
                                }
                            }
                        }
                    } else if !model.isDrawing {
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
        .monospacedDigit()
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
