//
//  EpicycleFrame.swift
//  Fourier
//

import SwiftUI
import ComplexModule

struct EpicycleFrame: View {
    let model: Model
    let t: Double
    var firstCycleComplete = true

    var body: some View {
        let positions = Fourier.arrowPositions(terms: model.epicycleTerms, t: t)

        Canvas { context, _ in
            // Draw traced path with fade
            let totalPoints = model.penPoints.count
            if totalPoints > 1 {
                let penIdx = Int(t * Double(totalPoints)) % totalPoints
                let style = StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)

                for i in 0..<totalPoints {
                    let age = ((penIdx - i) % totalPoints + totalPoints) % totalPoints
                    let opacity = 1.0 - Double(age) / Double(totalPoints)

                    if !firstCycleComplete && age > penIdx { continue }
                    guard opacity > 0.01 else { continue }

                    var line = Path()
                    line.move(to: model.penPoints[i])
                    line.addLine(to: model.penPoints[(i + 1) % totalPoints])
                    context.stroke(line, with: .color(.accentColor.opacity(opacity)), style: style)
                }
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

#Preview {
    ContentView()
}
