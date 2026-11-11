import SwiftUI

/// "Chompy", the tooth buddy. Built entirely from flat shapes so it can blink,
/// talk, look around, wave a toothbrush and wear a different costume per theme.
struct Mascot: View {
    enum Mood { case happy, wow, cheer }

    var costume: Costume
    var mood: Mood = .happy
    var talking = false
    var look: CGFloat = 0          // -1 left ... 1 right
    var brushing = false
    var size: CGFloat = 200        // width; height is size * 1.15

    private static let baseW: CGFloat = 200
    private static let baseH: CGFloat = 230
    private var baseW: CGFloat { Self.baseW }
    private var baseH: CGFloat { Self.baseH }
    private static let mane: [CGPoint] = [
        CGPoint(x: 72, y: 34), CGPoint(x: 50, y: 42), CGPoint(x: 34, y: 60), CGPoint(x: 26, y: 84), CGPoint(x: 24, y: 110),
    ]

    var body: some View {
        let k = size / baseW
        TimelineView(.animation) { tl in
            figure(t: tl.date.timeIntervalSinceReferenceDate)
        }
        .frame(width: baseW, height: baseH)
        .scaleEffect(k)
        .frame(width: baseW * k, height: baseH * k)
    }

    // Everything below is laid out on a fixed 200 x 230 canvas.
    private func figure(t: Double) -> some View {
        let bounce: CGFloat = mood == .cheer ? CGFloat(abs(sin(t * 6))) * 26 : CGFloat(sin(t * 2.2)) * 3
        let squash: CGFloat = mood == .cheer ? 1 + CGFloat(abs(cos(t * 6))) * 0.04 : 1
        return ZStack {
            // ground shadow
            Ellipse()
                .fill(Color.black.opacity(0.22))
                .frame(width: 120 - bounce, height: 14)
                .position(x: 100, y: 222)

            ZStack {
                costumeBack(t: t)
                leftArm(t: t)
                toothBody(t: t)
                face(t: t)
                costumeFront(t: t)
                rightArmWithBrush(t: t)
            }
            .scaleEffect(x: squash, y: 2 - squash, anchor: .bottom)
            .offset(y: -bounce)
        }
        .frame(width: baseW, height: baseH)
    }

    // MARK: Body

    private func toothBody(t: Double) -> some View {
        ZStack {
            ToothShape().fill(Palette.toothShade)
            ToothShape().fill(Color.white)
                .mask(alignment: .leading) { Rectangle().frame(width: 118) }
        }
        .frame(width: 160, height: 172)
        .position(x: 100, y: 124)
    }

    private func face(t: Double) -> some View {
        let blink = t.truncatingRemainder(dividingBy: 3.7) < 0.12 && mood != .wow
        let eyeScale: CGFloat = blink ? 0.1 : (mood == .wow ? 1.15 : 1)
        let pupilX = look * 6 + CGFloat(sin(t * 0.7)) * (look == 0 ? 2 : 0)
        return ZStack {
            // cheeks
            Circle().fill(Palette.cheek.opacity(0.75)).frame(width: 22, height: 22).position(x: 50, y: 138)
            Circle().fill(Palette.cheek.opacity(0.75)).frame(width: 22, height: 22).position(x: 150, y: 138)

            // eyes
            ForEach([72.0, 128.0], id: \.self) { x in
                ZStack {
                    Ellipse().fill(Color.white)
                        .overlay(Ellipse().stroke(Palette.toothShade, lineWidth: 3))
                        .frame(width: 36, height: 42)
                    Circle().fill(Palette.pupil)
                        .frame(width: 18, height: 18)
                        .overlay(Circle().fill(Color.white).frame(width: 6, height: 6).offset(x: 3, y: -4))
                        .offset(x: pupilX, y: mood == .cheer ? -4 : 3)
                }
                .scaleEffect(x: 1, y: eyeScale)
                .position(x: CGFloat(x), y: 108)
            }

            mouth(t: t).position(x: 100, y: 150)
        }
    }

    @ViewBuilder
    private func mouth(t: Double) -> some View {
        switch mood {
        case .wow:
            Ellipse().fill(Palette.mouth)
                .overlay(Ellipse().fill(Palette.tongue).frame(width: 16, height: 10).offset(y: 6))
                .frame(width: 28, height: 34)
        case .happy, .cheer:
            let open: CGFloat = talking ? 0.35 + 0.65 * CGFloat(abs(sin(t * 14))) : (mood == .cheer ? 1 : 0.55)
            MouthShape()
                .fill(Palette.mouth)
                .overlay(alignment: .bottomTrailing) {
                    Circle().fill(Palette.tongue).frame(width: 24, height: 24).offset(x: -6, y: 8)
                }
                .clipShape(MouthShape())
                .frame(width: 48, height: max(8, 34 * open))
                .frame(height: 34, alignment: .top)
        }
    }

    // MARK: Arms + toothbrush

    private func leftArm(t: Double) -> some View {
        let angle: Double = mood == .cheer ? 150 + sin(t * 12) * 12 : 25 + sin(t * 2) * 4
        return Capsule()
            .fill(Color.white)
            .overlay(Capsule().stroke(Palette.toothShade, lineWidth: 3))
            .frame(width: 20, height: 52)
            .offset(y: 22)
            .rotationEffect(.degrees(angle))
            .position(x: 30, y: 140)
    }

    private func rightArmWithBrush(t: Double) -> some View {
        let wiggle = brushing ? sin(t * 16) * 12 : sin(t * 2.4) * 5
        let angle: Double = mood == .cheer ? -160 + sin(t * 12) * 12 : -145 + wiggle
        return ZStack {
            Capsule()
                .fill(Color.white)
                .overlay(Capsule().stroke(Palette.toothShade, lineWidth: 3))
                .frame(width: 20, height: 52)
                .offset(y: 22)
            FlatToothbrush()
                .frame(width: 22, height: 84)
                .rotationEffect(.degrees(180))
                .offset(x: 0, y: 70)
        }
        .rotationEffect(.degrees(angle))
        .position(x: 166, y: 138)
    }

    // MARK: Costumes

    @ViewBuilder
    private func costumeBack(t: Double) -> some View {
        switch costume {
        case .dinoHood:
            // spikes along the top and a little tail
            ForEach(0..<4, id: \.self) { i in
                Triangle()
                    .fill(i % 2 == 0 ? Palette.green : Palette.greenLip)
                    .frame(width: 30, height: 34)
                    .rotationEffect(.degrees(Double(i - 2) * 14 + 7))
                    .position(x: 58 + CGFloat(i) * 28, y: 42 - (i == 1 || i == 2 ? 8 : 0))
            }
            Triangle()
                .fill(Palette.green)
                .frame(width: 40, height: 60)
                .rotationEffect(.degrees(-70 + sin(t * 3) * 8))
                .position(x: 18, y: 190)
        case .unicorn:
            // fluffy mane
            ForEach(0..<5, id: \.self) { i in
                Circle()
                    .fill(i % 2 == 0 ? Palette.pink : Palette.purple)
                    .frame(width: 38, height: 38)
                    .position(Self.mane[i])
            }
        case .snorkel:
            // strap around the head
            Capsule().fill(Palette.orange).frame(width: 176, height: 10).position(x: 100, y: 104)
        case .robot:
            // antenna
            Capsule().fill(Palette.border).frame(width: 7, height: 34).position(x: 100, y: 40)
            Circle()
                .fill(Palette.red)
                .frame(width: 20, height: 20)
                .overlay(Circle().fill(Color.white.opacity(0.5)).frame(width: 6, height: 6).offset(x: -3, y: -3))
                .opacity(0.6 + 0.4 * abs(sin(t * 3)))
                .position(x: 100, y: 22)
        case .helmet:
            EmptyView()
        }
    }

    @ViewBuilder
    private func costumeFront(t: Double) -> some View {
        switch costume {
        case .helmet:
            Circle()
                .fill(Color(hex: 0x9BE7FF).opacity(0.16))
                .overlay(Circle().stroke(Color.white.opacity(0.9), lineWidth: 6))
                .frame(width: 206, height: 206)
                .position(x: 100, y: 112)
            Capsule()
                .fill(Color.white.opacity(0.75))
                .frame(width: 12, height: 40)
                .rotationEffect(.degrees(35))
                .position(x: 44, y: 54)
            Capsule().fill(Palette.border).frame(width: 7, height: 26).position(x: 154, y: 8)
            Circle().fill(Palette.yellow).frame(width: 16, height: 16).position(x: 154, y: -2)
        case .snorkel:
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(hex: 0x9BE7FF).opacity(0.35))
                .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Palette.orange, lineWidth: 7))
                .frame(width: 118, height: 58)
                .position(x: 100, y: 108)
            Capsule().fill(Palette.yellow).frame(width: 13, height: 86).position(x: 176, y: 76)
            Capsule().fill(Palette.orange).frame(width: 17, height: 14).position(x: 176, y: 34)
        case .unicorn:
            ZStack {
                Triangle().fill(Palette.yellow)
                ForEach(0..<3, id: \.self) { i in
                    Capsule().fill(Palette.yellowLip)
                        .frame(width: 16 - CGFloat(i) * 4, height: 4)
                        .rotationEffect(.degrees(-18))
                        .offset(y: 14 - CGFloat(i) * 13)
                }
            }
            .frame(width: 30, height: 58)
            .position(x: 100, y: 22)
        case .dinoHood:
            EmptyView()
        case .robot:
            ForEach([14.0, 186.0], id: \.self) { x in
                RoundedRectangle(cornerRadius: 5)
                    .fill(Palette.border)
                    .overlay(Circle().fill(Palette.orange).frame(width: 7, height: 7))
                    .frame(width: 16, height: 30)
                    .position(x: CGFloat(x), y: 112)
            }
        }
    }
}

// MARK: - Shapes

/// A friendly molar: two bumps on top, two roots at the bottom.
struct ToothShape: Shape {
    func path(in r: CGRect) -> Path {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: r.minX + x * r.width, y: r.minY + y * r.height) }
        var path = Path()
        path.move(to: p(0.06, 0.30))
        path.addCurve(to: p(0.50, 0.10), control1: p(0.03, -0.02), control2: p(0.36, -0.02))
        path.addCurve(to: p(0.94, 0.30), control1: p(0.64, -0.02), control2: p(0.97, -0.02))
        path.addCurve(to: p(0.84, 0.80), control1: p(0.92, 0.55), control2: p(0.88, 0.66))
        path.addCurve(to: p(0.70, 1.00), control1: p(0.82, 0.92), control2: p(0.78, 1.00))
        path.addCurve(to: p(0.56, 0.82), control1: p(0.62, 1.00), control2: p(0.60, 0.86))
        path.addCurve(to: p(0.44, 0.82), control1: p(0.53, 0.77), control2: p(0.47, 0.77))
        path.addCurve(to: p(0.30, 1.00), control1: p(0.40, 0.86), control2: p(0.38, 1.00))
        path.addCurve(to: p(0.16, 0.80), control1: p(0.22, 1.00), control2: p(0.18, 0.92))
        path.addCurve(to: p(0.06, 0.30), control1: p(0.12, 0.66), control2: p(0.08, 0.55))
        path.closeSubpath()
        return path
    }
}

/// Flat top, round bottom — a big open "D" smile.
struct MouthShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let corner = min(r.height * 0.3, 8)
        p.move(to: CGPoint(x: r.minX + corner, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX - corner, y: r.minY))
        p.addQuadCurve(to: CGPoint(x: r.maxX, y: r.minY + corner), control: CGPoint(x: r.maxX, y: r.minY))
        p.addCurve(to: CGPoint(x: r.minX, y: r.minY + corner),
                   control1: CGPoint(x: r.maxX, y: r.maxY * 1.3),
                   control2: CGPoint(x: r.minX, y: r.maxY * 1.3))
        p.addQuadCurve(to: CGPoint(x: r.minX + corner, y: r.minY), control: CGPoint(x: r.minX, y: r.minY))
        p.closeSubpath()
        return p
    }
}

/// Toothbrush drawn with shapes (handle at the bottom, bristles at the top).
struct FlatToothbrush: View {
    var handle: Color = Palette.blue
    var body: some View {
        GeometryReader { g in
            let w = g.size.width, h = g.size.height
            ZStack(alignment: .top) {
                // bristles
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(hex: 0x9BE7FF))
                    .frame(width: w * 0.9, height: h * 0.16)
                    .offset(x: -w * 0.3)
                // head + handle
                Capsule()
                    .fill(handle)
                    .frame(width: w * 0.55, height: h * 0.95)
                    .offset(y: h * 0.05)
                Capsule()
                    .fill(Color.white.opacity(0.35))
                    .frame(width: w * 0.14, height: h * 0.55)
                    .offset(x: -w * 0.1, y: h * 0.3)
            }
            .frame(width: w, height: h)
        }
    }
}
