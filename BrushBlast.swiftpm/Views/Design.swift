import SwiftUI
import UIKit

// MARK: - Text

extension View {
    /// Heavy rounded text with a flat, solid drop "lip" (no blur) for the chunky cartoon look.
    func chunkyText(_ size: CGFloat, color: Color = .white, lip: Color? = nil) -> some View {
        self.font(.system(size: size, weight: .heavy, design: .rounded))
            .foregroundStyle(color)
            .shadow(color: lip ?? .clear, radius: 0, x: 0, y: lip == nil ? 0 : max(2, size / 14))
    }
}

// MARK: - Buttons

/// Solid button with a darker edge underneath; it squishes down onto the edge when pressed.
struct ChunkyButtonStyle: ButtonStyle {
    var fill: Color
    var lip: Color
    var text: Color = .white
    var height: CGFloat = 58
    var fullWidth = true

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        return configuration.label
            .font(.system(size: 19, weight: .heavy, design: .rounded))
            .textCase(.uppercase)
            .tracking(0.8)
            .foregroundStyle(text)
            .padding(.horizontal, 24)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .frame(height: height)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(fill))
            .offset(y: pressed ? 5 : 0)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(lip).offset(y: 5))
            .padding(.bottom, 5)
            .animation(.easeOut(duration: 0.08), value: pressed)
    }
}

/// Dark outlined button (secondary actions).
struct OutlineButtonStyle: ButtonStyle {
    var text: Color = Palette.muted
    var height: CGFloat = 58
    var fullWidth = true

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        return configuration.label
            .font(.system(size: 19, weight: .heavy, design: .rounded))
            .textCase(.uppercase)
            .tracking(0.8)
            .foregroundStyle(text)
            .padding(.horizontal, 20)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .frame(height: height)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Palette.card)
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Palette.border, lineWidth: 2.5))
            )
            .offset(y: pressed ? 4 : 0)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Palette.border).offset(y: 4))
            .padding(.bottom, 4)
            .animation(.easeOut(duration: 0.08), value: pressed)
    }
}

/// Round icon button used in top bars.
struct IconButton: View {
    var symbol: String
    var color: Color = Palette.muted
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 22, weight: .heavy))
                .foregroundStyle(color)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
    }
}

// MARK: - Progress bar

struct ChunkyProgressBar: View {
    var progress: Double
    var color: Color
    var light: Color
    var height: CGFloat = 18

    var body: some View {
        GeometryReader { g in
            ZStack(alignment: .leading) {
                Capsule().fill(Palette.border)
                Capsule()
                    .fill(LinearGradient(colors: [light, color], startPoint: .leading, endPoint: .trailing))
                    .frame(width: max(height, g.size.width * min(max(progress, 0), 1)))
                    .overlay(alignment: .top) {
                        Capsule()
                            .fill(Color.white.opacity(0.4))
                            .frame(height: height * 0.22)
                            .padding(.horizontal, height * 0.5)
                            .padding(.top, height * 0.2)
                    }
            }
        }
        .frame(height: height)
    }
}

// MARK: - Speech bubble

struct SpeechBubble: View {
    var text: String
    var symbol: String? = nil
    var accent: Color = Palette.blue
    var size: CGFloat = 24

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                if let symbol {
                    Image(systemName: symbol)
                        .font(.system(size: size, weight: .black))
                        .foregroundStyle(accent)
                }
                Text(text)
                    .font(.system(size: size, weight: .heavy, design: .rounded))
                    .foregroundStyle(Palette.ink)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.6)
                    .lineLimit(2)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Palette.bubbleBorder, lineWidth: 3))
            )
            .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Palette.bubbleBorder).offset(y: 4))
            // little tail pointing down at the mascot
            Triangle()
                .fill(Color.white)
                .frame(width: 26, height: 14)
                .rotationEffect(.degrees(180))
                .offset(y: 2)
        }
    }
}

// MARK: - Shapes

struct Triangle: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.midX, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
        p.addLine(to: CGPoint(x: r.minX, y: r.maxY))
        p.closeSubpath()
        return p
    }
}

/// Four-pointed twinkle star.
struct Sparkle: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let c = CGPoint(x: r.midX, y: r.midY)
        p.move(to: CGPoint(x: r.midX, y: r.minY))
        p.addQuadCurve(to: CGPoint(x: r.maxX, y: r.midY), control: c)
        p.addQuadCurve(to: CGPoint(x: r.midX, y: r.maxY), control: c)
        p.addQuadCurve(to: CGPoint(x: r.minX, y: r.midY), control: c)
        p.addQuadCurve(to: CGPoint(x: r.midX, y: r.minY), control: c)
        p.closeSubpath()
        return p
    }
}

// MARK: - Background

/// Flat theme background with simple geometric shapes drifting upward.
struct FlatBackground: View {
    let theme: Theme
    var count = 18
    var speed: Double = 1

    var body: some View {
        ZStack {
            LinearGradient(colors: [theme.bgTop, theme.bgBottom], startPoint: .top, endPoint: .bottom)
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    let span = Double(size.height) + 120
                    for i in 0..<count {
                        let r = Rand(i)
                        let v = (14 + r.a * 30) * speed
                        let travel = (t * v + r.b * 5000).truncatingRemainder(dividingBy: span)
                        let y = Double(size.height) + 60 - travel
                        let x = r.c * Double(size.width) + sin(t * (0.4 + r.d * 0.6) + r.a * 10) * 18
                        let s = 10 + r.e * 26
                        let rect = CGRect(x: -s / 2, y: -s / 2, width: s, height: s)
                        let color = theme.shapeColors[i % theme.shapeColors.count]
                        var ctx = context
                        ctx.opacity = 0.12 + 0.22 * r.d
                        ctx.translateBy(x: x, y: y)
                        ctx.rotate(by: .degrees(t * 20 * (r.a - 0.5)))
                        let path: Path
                        switch i % 3 {
                        case 0: path = Circle().path(in: rect)
                        case 1: path = Sparkle().path(in: rect.insetBy(dx: -s * 0.2, dy: -s * 0.2))
                        default: path = RoundedRectangle(cornerRadius: s * 0.25).path(in: rect)
                        }
                        ctx.fill(path, with: .color(color))
                    }
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

/// Cheap deterministic pseudo-random numbers from an index.
struct Rand {
    let a, b, c, d, e: Double
    init(_ i: Int) {
        func h(_ n: Double) -> Double { let v = sin(n) * 43758.5453; return v - floor(v) }
        let s = Double(i) + 1
        a = h(s * 12.9898); b = h(s * 78.233); c = h(s * 37.719); d = h(s * 93.989); e = h(s * 51.123)
    }
}

// MARK: - Shake

struct Shake: GeometryEffect {
    var amount: CGFloat = 12
    var shakesPerUnit: CGFloat = 4
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let x = amount * sin(animatableData * .pi * shakesPerUnit)
        let y = amount * 0.4 * cos(animatableData * .pi * shakesPerUnit * 1.3)
        return ProjectionTransform(CGAffineTransform(translationX: x, y: y))
    }
}

// MARK: - Spinning flat sunburst

struct FlatSunburst: View {
    var color: Color
    var rays = 14

    var body: some View {
        TimelineView(.animation) { timeline in
            let angle = timeline.date.timeIntervalSinceReferenceDate * 20
            Canvas { context, size in
                let c = CGPoint(x: size.width / 2, y: size.height / 2)
                let r = max(size.width, size.height)
                for i in 0..<rays {
                    let a0 = Angle.degrees(Double(i) * 360 / Double(rays) + angle)
                    let a1 = Angle.degrees(a0.degrees + 360 / Double(rays) / 2)
                    var p = Path()
                    p.move(to: c)
                    p.addArc(center: c, radius: r, startAngle: a0, endAngle: a1, clockwise: false)
                    p.closeSubpath()
                    context.fill(p, with: .color(color.opacity(0.22)))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Confetti (Core Animation particle emitter)

/// Fires a burst of flat confetti (rectangles, dots, stars) each time `trigger` changes.
struct ConfettiView: UIViewRepresentable {
    enum Style { case small, big, firework }

    var trigger: Int
    var colors: [Color] = [Palette.blue, Palette.yellow, Palette.green, Palette.pink, Palette.orange, Palette.purple]
    var style: Style = .big
    /// 0...1 position of the burst; nil = center
    var origin: CGPoint? = nil

    func makeUIView(context: Context) -> EmitterHostView {
        let v = EmitterHostView()
        v.isUserInteractionEnabled = false
        v.backgroundColor = .clear
        return v
    }

    func updateUIView(_ view: EmitterHostView, context: Context) {
        guard trigger != context.coordinator.lastTrigger else { return }
        context.coordinator.lastTrigger = trigger
        guard trigger > 0 else { return }
        let uiColors = colors.map { UIColor($0) }
        let (style, origin) = (self.style, self.origin)
        // wait one runloop so the view has its final size
        Task { @MainActor in
            view.burst(colors: uiColors, style: style, origin: origin)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }
    final class Coordinator { var lastTrigger = 0 }
}

final class EmitterHostView: UIView {
    private static var imageCache: [String: CGImage] = [:]

    func burst(colors: [UIColor], style: ConfettiView.Style, origin: CGPoint?) {
        let emitter = CAEmitterLayer()
        let o = origin ?? CGPoint(x: 0.5, y: 0.5)
        emitter.emitterPosition = CGPoint(x: bounds.width * o.x, y: bounds.height * o.y)
        emitter.emitterShape = .point
        emitter.emitterSize = CGSize(width: 10, height: 10)

        let big = style != .small
        var cells: [CAEmitterCell] = []
        for color in colors {
            for image in [Self.rect(), Self.circle(), Self.star()] {
                cells.append(cell(image: image, color: color, big: big, style: style))
            }
        }
        emitter.emitterCells = cells
        emitter.beginTime = CACurrentMediaTime()
        layer.addSublayer(emitter)

        let burstLength = style == .small ? 0.1 : 0.22
        DispatchQueue.main.asyncAfter(deadline: .now() + burstLength) { emitter.birthRate = 0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) { emitter.removeFromSuperlayer() }
    }

    private func cell(image: CGImage, color: UIColor, big: Bool, style: ConfettiView.Style) -> CAEmitterCell {
        let c = CAEmitterCell()
        c.contents = image
        c.color = color.cgColor
        c.birthRate = big ? 30 : 10
        c.lifetime = big ? 4.5 : 2.0
        c.velocity = big ? 520 : 240
        c.velocityRange = big ? 260 : 110
        c.emissionRange = .pi * 2
        c.yAcceleration = style == .firework ? 140 : 400
        c.spin = 3
        c.spinRange = 8
        c.scale = big ? 1.0 : 0.7
        c.scaleRange = 0.4
        c.alphaSpeed = big ? -0.2 : -0.45
        return c
    }

    // Particle images, drawn once and cached
    private static func rect() -> CGImage { shape("rect") { UIBezierPath(roundedRect: CGRect(x: 0, y: 5, width: 16, height: 8), cornerRadius: 2) } }
    private static func circle() -> CGImage { shape("circle") { UIBezierPath(ovalIn: CGRect(x: 2, y: 2, width: 12, height: 12)) } }
    private static func star() -> CGImage {
        shape("star") {
            let p = UIBezierPath()
            let c = CGPoint(x: 8, y: 8)
            p.move(to: CGPoint(x: 8, y: 0))
            p.addQuadCurve(to: CGPoint(x: 16, y: 8), controlPoint: c)
            p.addQuadCurve(to: CGPoint(x: 8, y: 16), controlPoint: c)
            p.addQuadCurve(to: CGPoint(x: 0, y: 8), controlPoint: c)
            p.addQuadCurve(to: CGPoint(x: 8, y: 0), controlPoint: c)
            p.close()
            return p
        }
    }

    private static func shape(_ key: String, _ path: () -> UIBezierPath) -> CGImage {
        if let img = imageCache[key] { return img }
        let img = UIGraphicsImageRenderer(size: CGSize(width: 16, height: 16)).image { _ in
            UIColor.white.setFill()
            path().fill()
        }.cgImage!
        imageCache[key] = img
        return img
    }
}
