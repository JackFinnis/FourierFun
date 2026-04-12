//
//  EpicycleFrame.swift
//  Fourier
//

import SwiftUI
import ComplexModule

struct EpicycleFrame: View {
    @Environment(\.colorScheme) var colorScheme
    let model: Model
    let t: Double

    var body: some View {
        let positions = Fourier.arrowPositions(terms: model.epicycleTerms, t: t)

        Canvas { context, _ in
            // Draw traced path with fade
            let totalPoints = model.penPoints.count
            if totalPoints > 1 {
                let penIdx = Int(t * Double(totalPoints)) % totalPoints
                let style = StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)

                let accent = Color.accentColor
                let bg: Color = colorScheme == .dark ? .black : .white

                // Draw oldest segments first so newest appear on top
                for age in stride(from: totalPoints - 1, through: 1, by: -1) {
                    let i = (penIdx - age + totalPoints) % totalPoints
                    let fraction = 1.0 - Double(age) / Double(totalPoints)

                    guard fraction > 0.01 else { continue }

                    var line = Path()
                    line.move(to: model.penPoints[i])
                    line.addLine(to: model.penPoints[(i + 1) % totalPoints])
                    let color: Color = {
                        if #available(iOS 18.0, *) {
                            return bg.mix(with: accent, by: fraction, in: .perceptual)
                        } else {
                            var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
                            var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
                            UIColor(bg).getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
                            UIColor(accent).getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
                            let f = CGFloat(fraction)
                            return Color(red: r1 + (r2 - r1) * f, green: g1 + (g2 - g1) * f, blue: b1 + (b2 - b1) * f)
                        }
                    }()
                    context.stroke(line, with: .color(color), style: style)
                }

                // Draw segment from last discrete pen point to current epicycle tip
                if let tip = positions.last {
                    var line = Path()
                    line.move(to: model.penPoints[penIdx])
                    line.addLine(to: tip)
                    context.stroke(line, with: .color(accent), style: style)
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
