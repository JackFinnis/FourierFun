//
//  EpicycleFrame.swift
//  Fourier
//

import SwiftUI
import ComplexModule

struct EpicycleFrame: View {
    let model: Model
    let t: Double

    var body: some View {
        let positions = Fourier.arrowPositions(terms: model.epicycleTerms, t: t)
        let traceCount = Int(t * Double(model.penPoints.count))

        Canvas { context, _ in
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
            if model.showEpicycles {
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
                        context.stroke(circle, with: .color(.primary.opacity(0.2)), lineWidth: 0.5)
                    }

                    var arrow = Path()
                    arrow.move(to: from)
                    arrow.addLine(to: to)
                    context.stroke(
                        arrow,
                        with: .color(.primary.opacity(0.4)),
                        style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
                    )
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
