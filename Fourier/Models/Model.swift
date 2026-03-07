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
    var epicycleTerms: [(n: Int, cn: Complex<Double>)] = []
    var penPoints: [CGPoint] = []
    var speed = Speed.normal
    var isDrawing = false
    var isAnimating = false

    var nRange: ClosedRange<Double> {
        1...min(500, Double(max(points.count, 2)))
    }
    
    func reset() {
        epicycles = 10
        path = nil
        points = []
        epicycleTerms = []
        penPoints = []
        speed = .normal
        isAnimating = false
    }
    
    func importSVG(url: URL, size: CGSize, insets: EdgeInsets) {
        do {
            let svg = try SVG.make(from: url)
            guard let cgPath = SVGPathParser.cgPath(from: svg) else { return }
            let points = cgPath.samplePoints()
            let scaledPoints = scale(points: points, size: size, insets: insets)
            transform(points: scaledPoints, size: size)
        } catch {
            print(error)
        }
    }

    func scale(points: [CGPoint], size: CGSize, insets: EdgeInsets) -> [CGPoint] {
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
    
    func transform(points: [CGPoint], size: CGSize) {
        print(points.count)
        self.size = size
        reset()
        guard points.count > 1 else { return }
        self.points = points
        update()
    }
    
    func update() {
        UIImpactFeedbackGenerator().impactOccurred()
        epicycles = min(epicycles, Double(points.count))
        let transformed = Fourier.transform(N: Int(epicycles), points: points)
        path = Path { path in
            path.move(to: CGPoint(x: transformed[0].x, y: transformed[0].y))
            for i in 1..<transformed.count {
                path.addLine(to: CGPoint(x: transformed[i].x, y: transformed[i].y))
            }
            path.addLine(to: CGPoint(x: transformed[0].x, y: transformed[0].y))
            path.closeSubpath()
        }
        epicycleTerms = Fourier.sortedTerms(N: Int(epicycles), points: points)
        let resolution = points.count
        penPoints = (0..<resolution).compactMap { step in
            let t = Double(step) / Double(resolution)
            return Fourier.arrowPositions(terms: epicycleTerms, t: t).last
        }
    }
}

#Preview {
    ContentView()
}
