//
//  SVGPathParser.swift
//  Fourier
//
//  Parses SVG path data into a CGPath, correctly handling
//  implicit command repetition and relative coordinates.
//

import CoreGraphics
import VectorPlus
import SwiftSVG

struct SVGPathParser {
    static func cgPath(from svg: SVG) -> CGPath? {
        guard let data = firstPathData(in: svg) else { return nil }
        return parse(data).largestSubpath
    }

    private static func firstPathData(in container: any Container) -> String? {
        if let data = container.paths?.first(where: { !$0.data.isEmpty })?.data {
            return data
        }
        for group in container.groups ?? [] {
            if let data = firstPathData(in: group) {
                return data
            }
        }
        return nil
    }

    static func parse(_ data: String) -> CGPath {
        let path = CGMutablePath()
        let tokens = tokenize(data)
        var i = 0

        var cx: CGFloat = 0
        var cy: CGFloat = 0
        var sx: CGFloat = 0 // subpath start
        var sy: CGFloat = 0
        var lastCmd: Character = " "
        var lastCx2: CGFloat = 0 // last cubic control point
        var lastCy2: CGFloat = 0

        func num() -> CGFloat {
            guard i < tokens.count, case .number(let v) = tokens[i] else { return 0 }
            i += 1
            return CGFloat(v)
        }

        while i < tokens.count {
            let cmd: Character
            if case .command(let c) = tokens[i] {
                cmd = c
                i += 1
            } else {
                // Implicit repetition
                cmd = (lastCmd == "M") ? "L" : (lastCmd == "m") ? "l" : lastCmd
            }

            switch cmd {
            case "M":
                cx = num(); cy = num()
                path.move(to: CGPoint(x: cx, y: cy))
                sx = cx; sy = cy
            case "m":
                cx += num(); cy += num()
                path.move(to: CGPoint(x: cx, y: cy))
                sx = cx; sy = cy
            case "L":
                cx = num(); cy = num()
                path.addLine(to: CGPoint(x: cx, y: cy))
            case "l":
                cx += num(); cy += num()
                path.addLine(to: CGPoint(x: cx, y: cy))
            case "H":
                cx = num()
                path.addLine(to: CGPoint(x: cx, y: cy))
            case "h":
                cx += num()
                path.addLine(to: CGPoint(x: cx, y: cy))
            case "V":
                cy = num()
                path.addLine(to: CGPoint(x: cx, y: cy))
            case "v":
                cy += num()
                path.addLine(to: CGPoint(x: cx, y: cy))
            case "C":
                let x1 = num(), y1 = num()
                let x2 = num(), y2 = num()
                cx = num(); cy = num()
                path.addCurve(to: CGPoint(x: cx, y: cy),
                              control1: CGPoint(x: x1, y: y1),
                              control2: CGPoint(x: x2, y: y2))
                lastCx2 = x2; lastCy2 = y2
            case "c":
                let x1 = cx + num(), y1 = cy + num()
                let x2 = cx + num(), y2 = cy + num()
                cx += num(); cy += num()
                path.addCurve(to: CGPoint(x: cx, y: cy),
                              control1: CGPoint(x: x1, y: y1),
                              control2: CGPoint(x: x2, y: y2))
                lastCx2 = x2; lastCy2 = y2
            case "S":
                let x1 = 2 * cx - lastCx2, y1 = 2 * cy - lastCy2
                let x2 = num(), y2 = num()
                cx = num(); cy = num()
                path.addCurve(to: CGPoint(x: cx, y: cy),
                              control1: CGPoint(x: x1, y: y1),
                              control2: CGPoint(x: x2, y: y2))
                lastCx2 = x2; lastCy2 = y2
            case "s":
                let x1 = 2 * cx - lastCx2, y1 = 2 * cy - lastCy2
                let x2 = cx + num(), y2 = cy + num()
                cx += num(); cy += num()
                path.addCurve(to: CGPoint(x: cx, y: cy),
                              control1: CGPoint(x: x1, y: y1),
                              control2: CGPoint(x: x2, y: y2))
                lastCx2 = x2; lastCy2 = y2
            case "Q":
                let x1 = num(), y1 = num()
                cx = num(); cy = num()
                path.addQuadCurve(to: CGPoint(x: cx, y: cy),
                                  control: CGPoint(x: x1, y: y1))
            case "q":
                let x1 = cx + num(), y1 = cy + num()
                cx += num(); cy += num()
                path.addQuadCurve(to: CGPoint(x: cx, y: cy),
                                  control: CGPoint(x: x1, y: y1))
            case "Z", "z":
                path.closeSubpath()
                cx = sx; cy = sy
            default:
                break
            }

            if cmd != "C" && cmd != "c" && cmd != "S" && cmd != "s" {
                lastCx2 = cx; lastCy2 = cy
            }
            lastCmd = cmd
        }

        return path
    }

    private enum Token {
        case command(Character)
        case number(Double)
    }

    private static func tokenize(_ data: String) -> [Token] {
        var tokens = [Token]()
        var block = ""

        func flushBlock() {
            if !block.isEmpty {
                if let v = Double(block) {
                    tokens.append(.number(v))
                }
                block = ""
            }
        }

        let scalars = data.unicodeScalars
        for scalar in scalars {
            let ch = Character(scalar)

            if ch == "e" || ch == "E" {
                // Exponential notation
                block.append(ch)
                continue
            }

            if ch.isLetter {
                flushBlock()
                tokens.append(.command(ch))
                continue
            }

            if ch == " " || ch == "," || ch == "\t" || ch == "\n" || ch == "\r" {
                flushBlock()
                continue
            }

            if ch == "-" || ch == "+" {
                if !block.isEmpty && block.last != "e" && block.last != "E" {
                    flushBlock()
                }
                block.append(ch)
                continue
            }

            if ch == "." {
                if block.contains(".") {
                    flushBlock()
                }
                block.append(ch)
                continue
            }

            if ch.isNumber {
                block.append(ch)
                continue
            }
        }

        flushBlock()
        return tokens
    }
}
