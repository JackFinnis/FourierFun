//
//  Path.swift
//  Fourier
//
//  Created by Jack Finnis on 01/12/2022.
//

import SwiftUI

extension CGPath {
    var points: [CGPoint] {
        var points = [CGPoint]()
        applyWithBlock { pointer in
            points.append(pointer.pointee.points.pointee)
        }
        return points
    }

    func samplePoints(target: Int = 1000) -> [CGPoint] {
        let initial = copy(dashingWithPhase: 0, lengths: [1]).points
        let dashLength = max(1, Double(initial.count) / Double(target))
        return copy(dashingWithPhase: 0, lengths: [dashLength]).points
    }

    var largestSubpath: CGPath {
        var subpaths = [CGMutablePath]()
        var current: CGMutablePath?

        applyWithBlock { pointer in
            let element = pointer.pointee
            switch element.type {
            case .moveToPoint:
                if let path = current {
                    subpaths.append(path)
                }
                current = CGMutablePath()
                current?.move(to: element.points[0])
            case .addLineToPoint:
                current?.addLine(to: element.points[0])
            case .addQuadCurveToPoint:
                current?.addQuadCurve(to: element.points[1], control: element.points[0])
            case .addCurveToPoint:
                current?.addCurve(to: element.points[2], control1: element.points[0], control2: element.points[1])
            case .closeSubpath:
                current?.closeSubpath()
            @unknown default:
                break
            }
        }
        if let path = current {
            subpaths.append(path)
        }

        return subpaths.max {
            $0.boundingBox.width * $0.boundingBox.height < $1.boundingBox.width * $1.boundingBox.height
        } ?? CGMutablePath()
    }
}

#Preview {
    ContentView()
}
