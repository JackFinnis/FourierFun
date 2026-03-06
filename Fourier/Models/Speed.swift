//
//  Speed.swift
//  Fourier
//
//  Created by Jack Finnis on 06/03/2026.
//

import SwiftUI

enum Speed: CaseIterable {
    case slow
    case normal
    case fast

    var duration: Double {
        switch self {
        case .slow:     20
        case .normal:   10
        case .fast:     5
        }
    }

    var label: String {
        switch self {
        case .slow:     "0.5x"
        case .normal:   "1x"
        case .fast:     "2x"
        }
    }

    var next: Speed {
        switch self {
        case .slow:     .normal
        case .normal:   .fast
        case .fast:     .slow
        }
    }
}
