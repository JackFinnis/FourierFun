//
//  Fourier.swift
//  Fourier
//
//  Created by Jack Finnis on 29/08/2021.
//

import Foundation
import ComplexModule
import SwiftUI

struct Fourier {
    static func coefficients(path: [Complex<Double>]) -> [Int: Complex<Double>] {
        var cs: [Int: Complex<Double>] = [:]
        for n in nRange(N: path.count) {
            var integral: Complex<Double> = 0
            for t in 0..<path.count {
                let e = Complex.exp(Complex(Double(n)) * Complex(imaginary: -2) * Complex(Double.pi) * Complex(Double(t) / Double(path.count)))
                integral += e * path[t] * Complex(1 / Double(path.count))
            }
            cs[n] = integral
        }
        return cs
    }

    static func nRange(N: Int) -> Range<Int> {
        Int((Double(-N) / 2).rounded(.up))..<Int((Double(N) / 2).rounded(.up))
    }

    static func penPoints(coefficients: [Int: Complex<Double>], count: Int, resolution: Int) -> [[CGPoint]] {
        let maxN = min(300, count)
        var running = Array(repeating: CGPoint.zero, count: resolution)
        var result = [running]
        var prevRange: Range<Int> = 0..<0
        for n in 1...maxN {
            let newRange = nRange(N: n)
            for i in newRange where !prevRange.contains(i) {
                if let cn = coefficients[i] {
                    for j in 0..<resolution {
                        let t = Double(j) / Double(resolution)
                        let v = vector(cn: cn, t: t, n: i)
                        running[j].x += v.real
                        running[j].y += v.imaginary
                    }
                }
            }
            result.append(running)
            prevRange = newRange
        }
        return result
    }

    static func arrowPositions(terms: [(n: Int, cn: Complex<Double>)], t: Double) -> [CGPoint] {
        var positions = [CGPoint]()
        var current: Complex<Double> = 0
        positions.append(CGPoint(x: current.real, y: current.imaginary))
        for (n, cn) in terms {
            current += vector(cn: cn, t: t, n: n)
            positions.append(CGPoint(x: current.real, y: current.imaginary))
        }
        return positions
    }

    private static func vector(cn: Complex<Double>, t: Double, n: Int) -> Complex<Double> {
        cn * Complex.exp(Complex(Double(n)) * Complex(imaginary: 2) * Complex(Double.pi) * Complex(t))
    }
}
