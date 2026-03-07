//
//  WelcomeView.swift
//  Fourier
//
//  Created by Jack Finnis on 07/03/2026.
//

import SwiftUI
import StoreKit

struct WelcomeView: View {
    let model: Model
    let size: CGSize

    @Environment(\.requestReview) var requestReview
    @State var showFileImporter = false

    var body: some View {
        Image(systemName: "hand.draw.fill")
            .font(.largeTitle)
            .imageScale(.large)
            .foregroundStyle(.secondary)
            .navigationTitle("Fourier")
            .navigationBarTitleDisplayMode(.inline)
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
                                    Label(file.name, systemImage: file.systemImage)
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
            }
    }
}

#Preview {
    ContentView()
}
