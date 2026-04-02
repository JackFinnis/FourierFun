//
//  FourierApp.swift
//  Fourier
//
//  Created by Jack Finnis on 24/08/2021.
//

import SwiftUI
import StoreKit
import TelemetryDeck

@main
struct FourierApp: App {
    init() {
        let config = TelemetryDeck.Config(appID: "6F4FEDFE-E332-4E39-8867-1603A68DB870")
        TelemetryDeck.initialize(config: config)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

#Preview {
    ContentView()
}

// meh
// more svgs: repeating patterns, skyline
