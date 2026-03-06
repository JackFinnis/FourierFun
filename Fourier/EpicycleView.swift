//
//  EpicycleView.swift
//  Fourier
//
//  Created by Jack Finnis on 06/03/2026.
//

import SwiftUI
import ComplexModule

struct EpicycleView: View {
    let model: Model

    @State var startDate = Date.now

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startDate)
            let t = fmod(elapsed / model.speed.duration, 1.0)
            let positions = Fourier.arrowPositions(terms: model.epicycleTerms, t: t)
            let traceCount = Int(t * Double(model.penPoints.count))

            Canvas { context, size in
                // Draw traced path
                if traceCount > 1 {
                    var tracedPath = Path()
                    tracedPath.move(to: model.penPoints[0])
                    for i in 1..<traceCount {
                        tracedPath.addLine(to: model.penPoints[i])
                    }
                    context.stroke(
                        tracedPath,
                        with: .color(.accentColor),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                    )
                }

                // Draw circles and arrows
                for i in 0..<max(0, positions.count - 1) {
                    if model.epicycleTerms[i].n == 0 { continue }

                    let from = positions[i]
                    let to = positions[i + 1]
                    let radius = hypot(to.x - from.x, to.y - from.y)

                    if radius > 1 {
                        let circle = Path(ellipseIn: CGRect(
                            x: from.x - radius, y: from.y - radius,
                            width: radius * 2, height: radius * 2
                        ))
                        context.stroke(circle, with: .color(.primary.opacity(0.1)), lineWidth: 0.5)
                    }

                    var arrow = Path()
                    arrow.move(to: from)
                    arrow.addLine(to: to)
                    context.stroke(
                        arrow,
                        with: .color(.primary.opacity(0.5)),
                        style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
                    )
                }
            }
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
