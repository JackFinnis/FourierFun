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
            let t = fmod(elapsed / model.speed.duration, 1.0)
            EpicycleFrame(model: model, t: t)
        }
        .onAppear {
            startDate = .now
        }
        .onChange(of: model.speed) { oldSpeed, newSpeed in
            let elapsed = Date.now.timeIntervalSince(startDate)
            let t = fmod(elapsed / oldSpeed.duration, 1.0)
            startDate = Date.now.addingTimeInterval(-t * newSpeed.duration)
        }
    }
}

#Preview {
    ContentView()
}
