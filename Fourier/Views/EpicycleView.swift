//
//  EpicycleView.swift
//  Fourier
//
//  Created by Jack Finnis on 06/03/2026.
//

import SwiftUI

struct EpicycleView: View {
    let model: Model

    @State var startDate = Date.now

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startDate)
            let t = fmod(elapsed / 30, 1.0)
            EpicycleFrame(model: model, t: t)
        }
        .onAppear {
            startDate = .now
        }
    }
}

#Preview {
    ContentView()
}
