//
//  URL.swift
//  Fourier
//
//  Created by Jack Finnis on 06/03/2026.
//

import Foundation

extension URL {
    static let sharePNG = URL.temporaryDirectory.appending(path: "Fourier.png")
    static let shareGIF = URL.temporaryDirectory.appending(path: "Fourier.gif")
}
