//
//  PathRenderer.swift
//  Fourier
//
//  Created by Jack Finnis on 06/03/2026.
//

import SwiftUI
import StoreKit

struct PathRenderer: View {
    let path: Path
    
    var body: some View {
        path.stroke(.accent, style: .init(lineWidth: 3, lineCap: .round, lineJoin: .round))
    }
}

#Preview {
    ContentView()
}
