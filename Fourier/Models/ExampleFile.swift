//
//  ExampleFile.swift
//  Fourier
//
//  Created by Jack Finnis on 22/07/2024.
//

import Foundation

enum ExampleFile: String, CaseIterable {
    case fourier
    case heart
    case pi
    case quaver
    case sigma
    case star
    case trebleClef = "treble-clef"
    case uk

    var name: String {
        switch self {
        case .fourier:		"Joseph Fourier"
        case .heart:		"Heart"
        case .pi:			"Pi"
        case .quaver:		"Quaver"
        case .sigma:		"Sigma"
        case .star:			"Star"
        case .trebleClef:	"Treble Clef"
        case .uk:			"UK"
        }
    }
    
    var url: URL {
        Bundle.main.url(forResource: rawValue, withExtension: "svg")!
    }
}
