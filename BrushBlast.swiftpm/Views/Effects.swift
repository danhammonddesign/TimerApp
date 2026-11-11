import SwiftUI
import UIKit

// MARK: - Drifting emoji background

/// Theme gradient with emoji floating up the screen. Pure math per frame, no stored state.
struct AnimatedBackground: View {
    let theme: Theme
    var count = 22
    var speedBoost: Double = 1

    var body: some View {
        ZStack {
            LinearGradient(colors: theme.colors, startPoint: .top, endPoint: .bottom)
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    let span = size.height + 120
                    for i in 0..<count {
                        let r = Rand(i)
                        let speed = (18 + r.a * 45) * speedBoost
                        let travel = (t * speed + r.b * 5000).truncatingRemainder(dividingBy: span)
                        let y = size.height + 60 - travel
                        let x = r.c * size.width + sin(t * (0.5 + r.d) + r.a * 10) * 24
                        let symbol = theme.floaters[i % theme.floaters.count]
                        context.opacity = 0.25 + 0.45 * r.d
                        var copy = context
                        copy.translateBy(x: x, y: y)
                        copy.rotate(by: .degrees(sin(t + r.b * 6) * 25))
                        copy.draw(Text(symbol).font(.system(size: 14 + r.e * 30)), at: .zero)
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

// MARK: - Spinning sunburst

struct Sunburst: View {
    var color: Color
    var rays = 16

    var body: some View {
        TimelineView(.animation) { timeline in
            let angle = timeline.date.timeIntervalSinceReferenceDate * 25
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
                    context.fill(p, with: .radialGradient(
                        Gradient(colors: [color.opacity(0.9), color.opacity(0)]),
                        center: c, startRadius: 0, endRadius: r * 0.6))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Confetti / fireworks (Core Animation particle emitter)

/// Fires a burst of confetti + emoji every time `trigger` changes.
struct ConfettiView: UIViewRepresentable {
    enum Style { case small, big, firework }

    var trigger: Int
    var emojis: [String]
    var colors: [UIColor] = [.systemPink, .systemYellow, .systemTeal, .systemPurple, .systemOrange, .systemGreen]
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
        // wait one runloop so the view has its final size
        let (emojis, colors, style, origin) = (self.emojis, self.colors, self.style, self.origin)
        Task { @MainActor in
            view.burst(emojis: emojis, colors: colors, style: style, origin: origin)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }
    final class Coordinator { var lastTrigger = 0 }
}

final class EmitterHostView: UIView {
    private static var imageCache: [String: CGImage] = [:]

    func burst(emojis: [String], colors: [UIColor], style: ConfettiView.Style, origin: CGPoint?) {
        let emitter = CAEmitterLayer()
        let o = origin ?? CGPoint(x: 0.5, y: 0.5)
        emitter.emitterPosition = CGPoint(x: bounds.width * o.x, y: bounds.height * o.y)
        emitter.emitterShape = .point
        emitter.emitterSize = CGSize(width: 10, height: 10)
        emitter.renderMode = .oldestLast

        let big = style != .small
        var cells: [CAEmitterCell] = []
        for color in colors {
            cells.append(cell(image: Self.rect(), color: color, big: big, style: style))
            cells.append(cell(image: Self.circle(), color: color, big: big, style: style))
        }
        for e in emojis {
            if let img = Self.emoji(e) {
                let c = cell(image: img, color: nil, big: big, style: style)
                c.scale = big ? 0.55 : 0.35
                c.scaleRange = 0.25
                c.birthRate = big ? 18 : 6
                cells.append(c)
            }
        }
        emitter.emitterCells = cells
        emitter.beginTime = CACurrentMediaTime()
        layer.addSublayer(emitter)

        let burstLength = style == .small ? 0.12 : 0.25
        DispatchQueue.main.asyncAfter(deadline: .now() + burstLength) { emitter.birthRate = 0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) { emitter.removeFromSuperlayer() }
    }

    private func cell(image: CGImage, color: UIColor?, big: Bool, style: ConfettiView.Style) -> CAEmitterCell {
        let c = CAEmitterCell()
        c.contents = image
        if let color { c.color = color.cgColor }
        c.birthRate = big ? 60 : 25
        c.lifetime = big ? 4.5 : 2.0
        c.velocity = big ? 520 : 260
        c.velocityRange = big ? 260 : 120
        c.emissionRange = .pi * 2
        c.yAcceleration = style == .firework ? 120 : 380
        c.spin = 3
        c.spinRange = 8
        c.scale = big ? 0.9 : 0.6
        c.scaleRange = 0.4
        c.alphaSpeed = big ? -0.2 : -0.45
        return c
    }

    // Particle images, drawn once and cached
    private static func rect() -> CGImage { shape("rect") { UIBezierPath(rect: CGRect(x: 0, y: 4, width: 14, height: 8)) } }
    private static func circle() -> CGImage { shape("circle") { UIBezierPath(ovalIn: CGRect(x: 2, y: 2, width: 10, height: 10)) } }

    private static func shape(_ key: String, _ path: () -> UIBezierPath) -> CGImage {
        if let img = imageCache[key] { return img }
        let img = UIGraphicsImageRenderer(size: CGSize(width: 14, height: 14)).image { _ in
            UIColor.white.setFill()
            path().fill()
        }.cgImage!
        imageCache[key] = img
        return img
    }

    private static func emoji(_ e: String) -> CGImage? {
        if let img = imageCache[e] { return img }
        let size = CGSize(width: 64, height: 64)
        let img = UIGraphicsImageRenderer(size: size).image { _ in
            (e as NSString).draw(in: CGRect(origin: .zero, size: size),
                                 withAttributes: [.font: UIFont.systemFont(ofSize: 52)])
        }.cgImage
        imageCache[e] = img
        return img
    }
}

// MARK: - Buttons

/// Chunky, squishy candy-style button.
struct BigButtonStyle: ButtonStyle {
    var color: Color
    var textColor: Color = .black

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 26, weight: .black, design: .rounded))
            .foregroundStyle(textColor)
            .padding(.horizontal, 32)
            .padding(.vertical, 18)
            .background(
                Capsule()
                    .fill(color)
                    .shadow(color: color.opacity(0.7), radius: configuration.isPressed ? 4 : 16)
                    .overlay(Capsule().stroke(.white.opacity(0.7), lineWidth: 3))
            )
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

extension View {
    /// Rounded heavy text with a little drop shadow, for that cartoon look.
    func cartoonText(_ size: CGFloat, color: Color = .white) -> some View {
        self.font(.system(size: size, weight: .black, design: .rounded))
            .foregroundStyle(color)
            .shadow(color: .black.opacity(0.35), radius: 0, x: 0, y: 3)
    }
}
