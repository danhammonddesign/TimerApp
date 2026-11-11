import SwiftUI

enum Pet: CaseIterable { case cat, dog, shark, crab }

/// Flat, cute pet faces used by the Secret Picture and Sand Art timers.
struct PetPicture: View {
    let pet: Pet     // .cat or .dog

    var body: some View {
        GeometryReader { g in
            let s = min(g.size.width, g.size.height)
            ZStack {
                (pet == .cat ? Color(hex: 0xFFE8A3) : Color(hex: 0xBDE8FF))
                // a few flat hearts and sparkles in the background
                ForEach(0..<8, id: \.self) { i in
                    let r = Rand(i + 40)
                    Group {
                        if i % 2 == 0 {
                            Image(systemName: "heart.fill").foregroundStyle(Palette.pink.opacity(0.55))
                        } else {
                            Sparkle().fill(Color.white.opacity(0.8)).frame(width: 22, height: 22)
                        }
                    }
                    .font(.system(size: 14 + r.a * 18))
                    .position(x: g.size.width * r.b, y: g.size.height * r.c)
                }
                PetFace(pet: pet)
                    .frame(width: s * 0.9, height: s * 0.9)
                    .position(x: g.size.width / 2, y: g.size.height * 0.56)
            }
        }
    }
}

/// Big cat or puppy face drawn from shapes, in a square frame.
struct PetFace: View {
    let pet: Pet

    var body: some View {
        GeometryReader { g in
            let s = min(g.size.width, g.size.height)
            ZStack {
                if pet == .cat { cat(s) } else { dog(s) }
            }
            .frame(width: s, height: s)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func at(_ x: CGFloat, _ y: CGFloat, _ s: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }

    @ViewBuilder
    private func cat(_ s: CGFloat) -> some View {
        let fur = Color(hex: 0xFFA94D), furLip = Color(hex: 0xE88A2E), inner = Color(hex: 0xFFB3C3)
        // ears
        ForEach([0.24, 0.76], id: \.self) { x in
            Triangle().fill(fur).frame(width: s * 0.3, height: s * 0.32)
                .rotationEffect(.degrees(x < 0.5 ? -14 : 14))
                .position(at(CGFloat(x), 0.22, s))
            Triangle().fill(inner).frame(width: s * 0.15, height: s * 0.17)
                .rotationEffect(.degrees(x < 0.5 ? -14 : 14))
                .position(at(CGFloat(x), 0.26, s))
        }
        // head with darker edge
        Ellipse().fill(furLip).frame(width: s * 0.84, height: s * 0.68).position(at(0.5, 0.6, s)).offset(y: s * 0.02)
        Ellipse().fill(fur).frame(width: s * 0.84, height: s * 0.68).position(at(0.5, 0.6, s))
        // stripes
        ForEach([-1.0, 0.0, 1.0], id: \.self) { k in
            Capsule().fill(furLip).frame(width: s * 0.05, height: s * 0.12)
                .rotationEffect(.degrees(k * 18))
                .position(at(0.5 + CGFloat(k) * 0.08, 0.32, s))
        }
        // muzzle
        Ellipse().fill(Color(hex: 0xFFF1DE)).frame(width: s * 0.34, height: s * 0.22).position(at(0.5, 0.72, s))
        eyes(s, y: 0.56, spread: 0.15)
        cheeks(s, y: 0.68)
        Triangle().fill(Palette.pink).frame(width: s * 0.08, height: s * 0.06).rotationEffect(.degrees(180)).position(at(0.5, 0.66, s))
        // little "w" mouth
        ForEach([-1.0, 1.0], id: \.self) { k in
            Circle().trim(from: 0, to: 0.5).stroke(Palette.ink, style: StrokeStyle(lineWidth: s * 0.014, lineCap: .round))
                .frame(width: s * 0.07, height: s * 0.07)
                .position(at(0.5 + CGFloat(k) * 0.035, 0.7, s))
        }
        // whiskers
        ForEach([-1.0, 1.0], id: \.self) { side in
            ForEach([-8.0, 6.0], id: \.self) { tilt in
                Capsule().fill(Color.white.opacity(0.9)).frame(width: s * 0.2, height: s * 0.012)
                    .rotationEffect(.degrees(side * tilt))
                    .position(at(0.5 + CGFloat(side) * 0.3, 0.7, s))
            }
        }
    }

    @ViewBuilder
    private func dog(_ s: CGFloat) -> some View {
        let fur = Color(hex: 0xE8B07A), furLip = Color(hex: 0xC98E55), ear = Color(hex: 0x8B5A2B)
        Ellipse().fill(furLip).frame(width: s * 0.74, height: s * 0.7).position(at(0.5, 0.56, s)).offset(y: s * 0.02)
        Ellipse().fill(fur).frame(width: s * 0.74, height: s * 0.7).position(at(0.5, 0.56, s))
        // patch over one eye
        Ellipse().fill(ear.opacity(0.55)).frame(width: s * 0.2, height: s * 0.22).position(at(0.66, 0.48, s))
        // floppy ears
        ForEach([0.16, 0.84], id: \.self) { x in
            Ellipse().fill(ear).frame(width: s * 0.22, height: s * 0.44)
                .rotationEffect(.degrees(x < 0.5 ? 18 : -18))
                .position(at(CGFloat(x), 0.48, s))
        }
        Ellipse().fill(Color.white).frame(width: s * 0.38, height: s * 0.28).position(at(0.5, 0.7, s))
        eyes(s, y: 0.5, spread: 0.14)
        cheeks(s, y: 0.66)
        // tongue + nose
        Capsule().fill(Palette.tongue).frame(width: s * 0.1, height: s * 0.14).position(at(0.5, 0.8, s))
        Capsule().fill(Color(hex: 0xD63F52)).frame(width: s * 0.012, height: s * 0.06).position(at(0.5, 0.79, s))
        Ellipse().fill(Palette.ink).frame(width: s * 0.13, height: s * 0.09).position(at(0.5, 0.64, s))
        Ellipse().fill(Color.white.opacity(0.5)).frame(width: s * 0.04, height: s * 0.02).position(at(0.48, 0.625, s))
    }

    @ViewBuilder
    private func eyes(_ s: CGFloat, y: CGFloat, spread: CGFloat) -> some View {
        ForEach([-1.0, 1.0], id: \.self) { k in
            Ellipse().fill(Palette.ink).frame(width: s * 0.11, height: s * 0.14)
                .overlay(Circle().fill(Color.white).frame(width: s * 0.04, height: s * 0.04).offset(x: s * 0.015, y: -s * 0.03))
                .position(at(0.5 + CGFloat(k) * spread, y, s))
        }
    }

    @ViewBuilder
    private func cheeks(_ s: CGFloat, y: CGFloat) -> some View {
        ForEach([-1.0, 1.0], id: \.self) { k in
            Ellipse().fill(Palette.pink.opacity(0.6)).frame(width: s * 0.1, height: s * 0.06)
                .position(at(0.5 + CGFloat(k) * 0.25, y, s))
        }
    }
}

// MARK: - Jar shapes for the sand timer

/// A glass jar shaped like a cat, puppy or shark.
struct PetJarShape: Shape {
    let pet: Pet

    func path(in r: CGRect) -> Path {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: r.minX + x * r.width, y: r.minY + y * r.height) }
        func ellipse(_ x0: CGFloat, _ y0: CGFloat, _ x1: CGFloat, _ y1: CGFloat) -> Path {
            Path(ellipseIn: CGRect(origin: p(x0, y0), size: CGSize(width: (x1 - x0) * r.width, height: (y1 - y0) * r.height)))
        }
        func poly(_ pts: [(CGFloat, CGFloat)]) -> Path {
            var path = Path()
            path.addLines(pts.map { p($0.0, $0.1) })
            path.closeSubpath()
            return path
        }

        switch pet {
        case .cat:
            return ellipse(0.08, 0.36, 0.92, 1.0)
                .union(ellipse(0.14, 0.08, 0.86, 0.62))
                .union(poly([(0.18, 0.26), (0.2, 0.0), (0.4, 0.12)]))
                .union(poly([(0.82, 0.26), (0.8, 0.0), (0.6, 0.12)]))
        case .dog:
            return ellipse(0.12, 0.44, 0.88, 1.0)
                .union(ellipse(0.2, 0.06, 0.8, 0.58))
                .union(ellipse(0.04, 0.1, 0.3, 0.5))
                .union(ellipse(0.7, 0.1, 0.96, 0.5))
        case .crab:
            // round body, two big claws (each with a pincer notch), eye stalks and little legs
            let leftClaw = ellipse(0.01, 0.06, 0.27, 0.44).subtracting(poly([(0.14, 0.26), (0.09, 0.0), (0.2, 0.0)]))
            let rightClaw = ellipse(0.73, 0.06, 0.99, 0.44).subtracting(poly([(0.86, 0.26), (0.8, 0.0), (0.91, 0.0)]))
            return ellipse(0.2, 0.4, 0.8, 1.0)
                .union(leftClaw).union(rightClaw)
                .union(poly([(0.26, 0.66), (0.1, 0.42), (0.2, 0.36), (0.34, 0.54)]))
                .union(poly([(0.74, 0.66), (0.9, 0.42), (0.8, 0.36), (0.66, 0.54)]))
                .union(ellipse(0.37, 0.22, 0.47, 0.52)).union(ellipse(0.53, 0.22, 0.63, 0.52))
                .union(ellipse(0.07, 0.68, 0.27, 0.78)).union(ellipse(0.73, 0.68, 0.93, 0.78))
                .union(ellipse(0.1, 0.82, 0.3, 0.92)).union(ellipse(0.7, 0.82, 0.9, 0.92))
        case .shark:
            return ellipse(0.02, 0.3, 0.8, 0.88)
                .union(poly([(0.34, 0.36), (0.5, 0.02), (0.6, 0.36)]))
                .union(poly([(0.72, 0.58), (0.98, 0.22), (0.9, 0.58), (0.98, 0.94)]))
                .union(poly([(0.32, 0.8), (0.28, 0.99), (0.5, 0.82)]))
        }
    }
}

/// Eyes, nose and smile drawn on the front of the jar.
struct PetJarFace: View {
    let pet: Pet

    var body: some View {
        GeometryReader { g in
            let w = g.size.width, h = g.size.height
            let eye = min(w, h) * 0.07
            ZStack {
                switch pet {
                case .cat, .dog:
                    ForEach([0.38, 0.62], id: \.self) { x in
                        eyeView(eye).position(x: w * CGFloat(x), y: h * 0.3)
                    }
                    Ellipse().fill(pet == .cat ? Palette.pink : Palette.ink)
                        .frame(width: eye * 1.1, height: eye * 0.75)
                        .position(x: w * 0.5, y: h * 0.39)
                    Circle().trim(from: 0, to: 0.5)
                        .stroke(Palette.ink, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: eye * 1.4, height: eye * 1.4)
                        .position(x: w * 0.5, y: h * 0.42)
                case .crab:
                    ForEach([0.42, 0.58], id: \.self) { x in
                        eyeView(eye * 0.8).position(x: w * CGFloat(x), y: h * 0.31)
                    }
                    Circle().trim(from: 0, to: 0.5)
                        .stroke(Palette.ink, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: eye * 2.2, height: eye * 2.2)
                        .position(x: w * 0.5, y: h * 0.64)
                    ForEach([0.36, 0.64], id: \.self) { x in
                        Ellipse().fill(Palette.pink.opacity(0.7))
                            .frame(width: eye * 1.2, height: eye * 0.7)
                            .position(x: w * CGFloat(x), y: h * 0.68)
                    }
                case .shark:
                    eyeView(eye).position(x: w * 0.18, y: h * 0.5)
                    Circle().trim(from: 0.05, to: 0.45)
                        .stroke(Palette.ink, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: eye * 3, height: eye * 3)
                        .position(x: w * 0.16, y: h * 0.56)
                    ForEach(0..<3, id: \.self) { i in
                        Capsule().fill(Palette.ink.opacity(0.5))
                            .frame(width: 3, height: h * 0.1)
                            .position(x: w * (0.32 + CGFloat(i) * 0.035), y: h * 0.55)
                    }
                }
            }
        }
    }

    private func eyeView(_ s: CGFloat) -> some View {
        Circle().fill(Color.white).frame(width: s * 1.5, height: s * 1.5)
            .overlay(Circle().fill(Palette.pupil).frame(width: s, height: s))
            .overlay(Circle().fill(Color.white).frame(width: s * 0.35, height: s * 0.35).offset(x: s * 0.15, y: -s * 0.2))
    }
}
