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
        case .fast:     4
        }
    }

    var label: String {
        switch self {
        case .slow:     "1x"
        case .normal:   "2x"
        case .fast:     "5x"
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

#Preview {
    ContentView()
}
