//
//  Array.swift
//  Fourier
//
//  Created by Jack Finnis on 07/03/2026.
//

import SwiftUI
import Vision
import SwiftSVG
import ComplexModule

extension Array where Element == CGPoint {
    var bounds: CGRect {
        let xs = map(\.x)
        let ys = map(\.y)
        let minX = xs.min() ?? 0
        let minY = ys.min() ?? 0
        return CGRect(x: minX, y: minY, width: (xs.max() ?? 0) - minX, height: (ys.max() ?? 0) - minY)
    }
}
