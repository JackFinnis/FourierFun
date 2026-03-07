//
//  ViewModel.swift
//  Fourier
//
//  Created by Jack Finnis on 29/08/2021.
//

import SwiftUI
import Vision
import SwiftSVG
import ComplexModule

@MainActor
@Observable
class Model {
    var path: SwiftUI.Path?
    var epicycles: Double = 10
    var points = [CGPoint]()
    var size = CGSize()
    var allCoefficients: [Int: Complex<Double>] = [:]

    var allPenPoints: [[CGPoint]] = []
    var epicycleTerms: [(n: Int, cn: Complex<Double>)] = []
    var penPoints: [CGPoint] = []
    var isDrawing = false
    var isAnimating = false
    var isProgressive = false
    var progressiveDirection = 1

    var nRange: ClosedRange<Double> {
        1...min(300, Double(max(points.count, 2)))
    }

    func reset() {
        epicycles = 10
        path = nil
        points = []
        allCoefficients = [:]

        allPenPoints = []
        epicycleTerms = []
        penPoints = []
        isAnimating = false
        isProgressive = false
        progressiveDirection = 1
    }

    func importSVG(url: URL, size: CGSize, insets: EdgeInsets) {
        do {
            let svg = try SVG.make(from: url)
            guard let cgPath = SVGPathParser.cgPath(from: svg) else { return }
            let points = cgPath.samplePoints()
            let scaledPoints = scaleToFit(points: points, size: size, insets: insets)
            analyze(points: scaledPoints, size: size)
        } catch {
            print(error)
        }
    }

    func scaleToFit(points: [CGPoint], size: CGSize, insets: EdgeInsets) -> [CGPoint] {
        let bounds = points.bounds
        let padding: CGFloat = 20
        let safe = CGRect(
            x: insets.leading + padding,
            y: insets.top + padding,
            width: size.width - insets.leading - insets.trailing - padding * 2,
            height: size.height - insets.top - insets.bottom - padding * 2
        )
        let scale = min(safe.width / bounds.width, safe.height / bounds.height)
        let dx = safe.midX - bounds.midX * scale
        let dy = safe.midY - bounds.midY * scale
        return points.map { CGPoint(x: $0.x * scale + dx, y: $0.y * scale + dy) }
    }

    func analyze(points: [CGPoint], size: CGSize) {
        self.size = size
        reset()
        guard points.count > 1 else { return }
        self.points = points
        let complexPath = points.map { Complex(Double($0.x), Double($0.y)) }
        allCoefficients = Fourier.coefficients(path: complexPath)
        allPenPoints = Fourier.penPoints(coefficients: allCoefficients, count: points.count, resolution: points.count)
        updatePath()
    }

    func updatePath() {
        epicycles = min(epicycles, Double(points.count))
        let n = min(Int(epicycles), allPenPoints.count - 1)
        guard n >= 0 else { return }
        penPoints = allPenPoints[n]
        let terms = Fourier.nRange(N: Int(epicycles)).compactMap { n in
            allCoefficients[n].map { (n: n, cn: $0) }
        }
        epicycleTerms = terms.sorted { $0.cn.length > $1.cn.length }
        path = Path { path in
            guard let first = penPoints.first else { return }
            path.move(to: first)
            for point in penPoints.dropFirst() {
                path.addLine(to: point)
            }
            path.closeSubpath()
        }
    }
}

#Preview {
    ContentView()
}
