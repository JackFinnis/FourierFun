//
//  ViewModel.swift
//  Fourier
//
//  Created by Jack Finnis on 29/08/2021.
//

import SwiftUI
import Vision
import VectorPlus
import SwiftSVG
import ComplexModule
import ImageIO
import UniformTypeIdentifiers

@MainActor
@Observable
class Model {
    var path: SwiftUI.Path?
    var epicycles = 10.0
    var points = [CGPoint]()
    var size = CGSize()
    var epicycleTerms: [(n: Int, cn: Complex<Double>)] = []
    var penPoints: [CGPoint] = []
    var speed = Speed.normal

    var isDrawing = false
    var isAnimating = false

    var nRange: ClosedRange<Double> {
        1...max(2, min(500, Double(max(points.count, 1))))
    }
    
    func reset() {
        epicycles = 10.0
        path = nil
        points = []
        epicycleTerms = []
        penPoints = []
        speed = .normal
        isAnimating = false
    }
    
    func renderPNG() {
        guard let path else { return }
        let content = PathView(path: path).background(.background)
        let renderer = ImageRenderer(content: content)
        renderer.proposedSize = .init(size)
        renderer.scale = 3
        guard let uiImage = renderer.uiImage,
              let pngData = uiImage.pngData()
        else { return }
        try? pngData.write(to: .sharePNG)
    }

    func renderGIF() {
        let fps = 30.0
        let delayTime = 1.0 / fps
        let frameCount = Int(speed.duration * fps)

        guard let destination = CGImageDestinationCreateWithURL(
            URL.shareGIF as CFURL,
            UTType.gif.identifier as CFString,
            frameCount,
            nil
        ) else { return }

        CGImageDestinationSetProperties(destination, [
            kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: 0]
        ] as CFDictionary)

        let frameProperties = [
            kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: delayTime]
        ] as CFDictionary

        for frame in 0..<frameCount {
            let t = Double(frame) / Double(frameCount)
            let content = EpicycleFrame(model: self, t: t).background(.background)
            let renderer = ImageRenderer(content: content)
            renderer.proposedSize = .init(size)
            renderer.scale = 3
            guard let cgImage = renderer.cgImage else { continue }
            CGImageDestinationAddImage(destination, cgImage, frameProperties)
        }

        CGImageDestinationFinalize(destination)
    }
    
    func importSVG(url: URL, size: CGSize) {
        do {
            _ = url.startAccessingSecurityScopedResource()
            let svg = try SVG.make(from: url)
            url.stopAccessingSecurityScopedResource()
            
            let cgPath = svg.path(size: .init(size))
            let points = cgPath.copy(dashingWithPhase: 0, lengths: [2]).points
            let scaledPoints = scale(points: points, size: size)
            transform(points: scaledPoints, size: size)
        } catch {
            print(error)
        }
    }
    
    func scale(points: [CGPoint], size: CGSize) -> [CGPoint] {
        let xs = points.compactMap { $0.x }
        let ys = points.compactMap { $0.y }

        let minx = xs.min() ?? 0
        let miny = ys.min() ?? 0
        let maxx = xs.max() ?? 0
        let maxy = ys.max() ?? 0

        let transform = CGAffineTransform(translationX: -minx, y: -miny)
        let shifted = points.map { point in
            point.applying(transform)
        }

        let oldWidth = maxx - minx
        let oldHeight = maxy - miny

        let targetWidth = size.width
        var targetHeight = size.height

        let padding: CGFloat = 50
        let widthScale = (targetWidth - padding) / oldWidth
        let heightScale = (targetHeight - padding) / oldHeight
        let scale = widthScale < heightScale ? widthScale : heightScale

        let newWidth = oldWidth * scale
        let newHeight = oldHeight * scale
        let widthOffset = (targetWidth - newWidth)/2
        let heightOffset = (targetHeight - newHeight)/2

        return shifted.map { point in
            CGPointMake(point.x * scale + widthOffset, point.y * scale + heightOffset)
        }
    }
    
    func transform(points: [CGPoint], size: CGSize) {
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
        let resolution = 1000
        penPoints = (0..<resolution).compactMap { step in
            let t = Double(step) / Double(resolution)
            return Fourier.arrowPositions(terms: epicycleTerms, t: t).last
        }
        renderPNG()
    }
}

#Preview {
    ContentView()
}
