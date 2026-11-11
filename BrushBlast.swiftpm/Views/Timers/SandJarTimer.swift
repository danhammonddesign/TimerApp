import SwiftUI

/// Sand Art timer: rainbow sand pours into a pet-shaped jar. Each brushing zone adds
/// a new color layer, and the jar is exactly full when time runs out.
@MainActor
struct SandJarTimer: View {
    @ObservedObject var session: BrushSession
    let theme: Theme
    let pet: Pet

    @State private var store = SandJarStore()

    init(session: BrushSession, theme: Theme, pet: Pet) {
        self.session = session
        self.theme = theme
        self.pet = pet
    }

    static let rainbow: [Color] = [
        Palette.red, Palette.orange, Palette.yellow, Palette.green,
        Color(hex: 0x2EC4B6), Palette.blue, Palette.purple, Palette.pink,
    ]

    var body: some View {
        GeometryReader { geo in
            let jarRect = jarFrame(in: geo.size)
            let model = store.model(pet: pet, size: jarRect.size)
            let jar = PetJarShape(pet: pet)

            ZStack {
                // glass back + chunky edge
                jar.fill(Color.black.opacity(0.25))
                    .frame(width: jarRect.width, height: jarRect.height)
                    .offset(y: 5)
                    .position(x: jarRect.midX, y: jarRect.midY)
                jar.fill(Color.white.opacity(0.1))
                    .frame(width: jarRect.width, height: jarRect.height)
                    .position(x: jarRect.midX, y: jarRect.midY)

                TimelineView(.animation) { tl in
                    let e = session.elapsed(at: tl.date)
                    let t = tl.date.timeIntervalSinceReferenceDate
                    Canvas { context, size in
                        draw(&context, size: size, jarRect: jarRect, model: model, e: e, t: t)
                    }
                }

                // glass outline and shine
                jar.stroke(Color.white.opacity(0.9), style: StrokeStyle(lineWidth: 6, lineJoin: .round))
                    .frame(width: jarRect.width, height: jarRect.height)
                    .position(x: jarRect.midX, y: jarRect.midY)
                Capsule().fill(Color.white.opacity(0.4))
                    .frame(width: 9, height: jarRect.height * 0.22)
                    .rotationEffect(.degrees(12))
                    .position(x: jarRect.minX + jarRect.width * 0.2, y: jarRect.minY + jarRect.height * 0.62)
                PetJarFace(pet: pet)
                    .frame(width: jarRect.width, height: jarRect.height)
                    .position(x: jarRect.midX, y: jarRect.midY)
            }
        }
    }

    /// Keep the jar's proportions and leave room above it for the falling sand.
    private func jarFrame(in size: CGSize) -> CGRect {
        let aspect: CGFloat = pet == .shark ? 1.35 : (pet == .crab ? 1.3 : 0.85)
        let top: CGFloat = 26
        let availH = size.height - top - 6
        var w = min(size.width, availH * aspect)
        var h = w / aspect
        if h > availH { h = availH; w = h * aspect }
        return CGRect(x: (size.width - w) / 2, y: top, width: w, height: h)
    }

    private func draw(_ ctx: inout GraphicsContext, size: CGSize, jarRect: CGRect,
                      model: SandJarModel, e: Double, t: Double) {
        let progress = min(max(e / session.duration, 0), 1)
        let zones = Double(Self.rainbow.count)
        let current = min(Int(progress * zones), Self.rainbow.count - 1)
        let level = jarRect.minY + model.level(for: progress)
        let pouring = progress < 1 && !session.isPaused
        let streamX = jarRect.minX + jarRect.width * (model.mouthX + 0.1 * CGFloat(sin(t * 0.5)))

        var inside = ctx
        inside.clip(to: PetJarShape(pet: pet).path(in: jarRect))

        if progress > 0 {
            // topmost layer first, then each lower layer on top of it
            for k in stride(from: current, through: 0, by: -1) {
                let top = k == current ? level : jarRect.minY + model.level(for: Double(k + 1) / zones)
                let surface = wave(from: jarRect.minX, to: jarRect.maxX, y: top, phase: Double(k) * 1.7,
                                   mound: k == current && pouring ? streamX : nil)
                var region = surface
                region.addLine(to: CGPoint(x: jarRect.maxX, y: jarRect.maxY + 10))
                region.addLine(to: CGPoint(x: jarRect.minX, y: jarRect.maxY + 10))
                region.closeSubpath()
                inside.fill(region, with: .color(Self.rainbow[k]))
                inside.stroke(surface, with: .color(Color.white.opacity(0.35)), lineWidth: 3)
            }
        }

        // the falling stream of sand
        if pouring {
            let color = Self.rainbow[current]
            ctx.fill(Path(roundedRect: CGRect(x: streamX - 3, y: 0, width: 6, height: max(level - 4, 0)), cornerRadius: 3),
                     with: .color(color))
            for g in 0..<10 {
                let span = max(Double(level), 1)
                let gy = (t * 260 + Double(g) * span / 10).truncatingRemainder(dividingBy: span)
                let gx = Double(streamX) + sin(Double(g) * 2.3 + t * 3) * 5
                ctx.fill(Circle().path(in: CGRect(x: gx - 2, y: gy - 2, width: 4, height: 4)), with: .color(color))
            }
        }
    }

    /// Gently wavy sand surface, with a little pile where the stream lands.
    private func wave(from x0: CGFloat, to x1: CGFloat, y: CGFloat, phase: Double, mound: CGFloat?) -> Path {
        var p = Path()
        var x = x0
        var first = true
        while x <= x1 + 6 {
            var yy = Double(y) + sin(Double(x) / 22 + phase) * 4
            if let m = mound {
                let dx = Double(x - m) / 22
                yy -= 9 * exp(-dx * dx)
            }
            let pt = CGPoint(x: x, y: yy)
            if first { p.move(to: pt); first = false } else { p.addLine(to: pt) }
            x += 6
        }
        return p
    }
}

/// Caches how full the jar is at each height (worked out once per jar and size).
final class SandJarStore {
    private var key = ""
    private var cached: SandJarModel?

    func model(pet: Pet, size: CGSize) -> SandJarModel {
        let k = "\(pet)-\(Int(size.width))x\(Int(size.height))"
        if k == key, let m = cached { return m }
        let m = SandJarModel(pet: pet, size: size)
        key = k
        cached = m
        return m
    }
}

struct SandJarModel {
    /// filled[i] = fraction of the jar's area below row i (rows counted from the top).
    private let rowsFromBottom: [Double]
    private let rowHeight: CGFloat
    private let height: CGFloat
    let mouthX: CGFloat   // 0...1, where sand pours in

    init(pet: Pet, size: CGSize) {
        let path = PetJarShape(pet: pet).path(in: CGRect(origin: .zero, size: size))
        let rows = 160, cols = 90
        var counts = [Double](repeating: 0, count: rows)
        for r in 0..<rows {
            let y = (CGFloat(r) + 0.5) / CGFloat(rows) * size.height
            var n = 0
            for c in 0..<cols {
                let x = (CGFloat(c) + 0.5) / CGFloat(cols) * size.width
                if path.contains(CGPoint(x: x, y: y)) { n += 1 }
            }
            counts[r] = Double(n)
        }
        let total = max(counts.reduce(0, +), 1)
        // cumulative from the bottom row upward
        var cum: [Double] = []
        var acc = 0.0
        for r in stride(from: rows - 1, through: 0, by: -1) {
            acc += counts[r]
            cum.append(acc / total)
        }
        rowsFromBottom = cum
        rowHeight = size.height / CGFloat(rows)
        height = size.height
        mouthX = pet == .shark ? 0.42 : 0.5
    }

    /// Height (from the top of the jar) of the sand surface when `fraction` of the jar is full.
    func level(for fraction: Double) -> CGFloat {
        guard fraction > 0 else { return height }
        guard fraction < 1 else { return 0 }
        var i = 0
        while i < rowsFromBottom.count - 1 && rowsFromBottom[i] < fraction { i += 1 }
        let prev = i == 0 ? 0 : rowsFromBottom[i - 1]
        let span = max(rowsFromBottom[i] - prev, 0.0001)
        let within = CGFloat((fraction - prev) / span)
        return height - (CGFloat(i) + within) * rowHeight
    }
}
