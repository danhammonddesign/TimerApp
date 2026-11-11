import SwiftUI

/// Marble Drop timer: marbles fall from the top, bounce off pegs and stack up.
/// They're scheduled so the board is exactly full when the time runs out.
@MainActor
struct PlinkoBoard: View {
    @ObservedObject var session: BrushSession
    let theme: Theme

    @State private var store = PlinkoStore()

    init(session: BrushSession, theme: Theme) {
        self.session = session
        self.theme = theme
    }

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 24, style: .continuous)
        GeometryReader { geo in
            let inner = CGSize(width: geo.size.width - 20, height: geo.size.height - 20)
            let model = store.model(size: inner, duration: session.duration)

            ZStack {
                shape.fill(Palette.border).offset(y: 5)
                shape.fill(Palette.card)
                shape.stroke(Palette.border, lineWidth: 4)

                TimelineView(.animation) { tl in
                    let e = session.elapsed(at: tl.date)
                    Canvas { context, _ in
                        // pegs
                        for p in model.pegs {
                            let r = model.d * 0.17
                            context.fill(Circle().path(in: CGRect(x: p.x - r, y: p.y - r + 2, width: r * 2, height: r * 2)),
                                         with: .color(Palette.border))
                            context.fill(Circle().path(in: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2)),
                                         with: .color(Color.white.opacity(0.85)))
                        }
                        // marbles
                        for m in model.marbles where m.start <= e {
                            let p = m.position(at: e, d: model.d)
                            Marbles.draw(&context, at: p, radius: model.d / 2, colorIndex: m.color)
                        }
                    }
                }
                .frame(width: inner.width, height: inner.height)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .onChange(of: model.landed(at: session.elapsed)) {
                AudioManager.shared.playQuiet(.clack, volume: 0.06)
            }
        }
    }
}

/// Flat glossy marbles.
enum Marbles {
    static let colors: [(Color, Color)] = [
        (Palette.blue, Palette.blueLip), (Palette.yellow, Palette.yellowLip), (Palette.green, Palette.greenLip),
        (Palette.pink, Palette.pinkLip), (Palette.orange, Palette.orangeLip), (Palette.purple, Palette.purpleLip),
        (Palette.red, Palette.redLip),
    ]

    static func draw(_ ctx: inout GraphicsContext, at p: CGPoint, radius r: CGFloat, colorIndex: Int) {
        let (main, lip) = colors[colorIndex % colors.count]
        ctx.fill(Circle().path(in: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2)), with: .color(lip))
        let r2 = r * 0.86
        ctx.fill(Circle().path(in: CGRect(x: p.x - r2, y: p.y - r2 - r * 0.12, width: r2 * 2, height: r2 * 2)), with: .color(main))
        let g = r * 0.24
        ctx.fill(Circle().path(in: CGRect(x: p.x - r * 0.38 - g, y: p.y - r * 0.45 - g, width: g * 2, height: g * 2)),
                 with: .color(Color.white.opacity(0.75)))
    }
}

/// Caches the board layout so it's only worked out once per size.
final class PlinkoStore {
    private var key = ""
    private var cached: PlinkoModel?

    func model(size: CGSize, duration: Double) -> PlinkoModel {
        let k = "\(Int(size.width))x\(Int(size.height))-\(Int(duration))"
        if k == key, let m = cached { return m }
        let m = PlinkoModel(size: size, duration: duration)
        key = k
        cached = m
        return m
    }
}

struct PlinkoModel {
    struct Marble {
        let slot: CGPoint
        let color: Int
        let points: [CGPoint]     // drop-in point, a stop on top of each peg, then the final slot
        let cumulative: [Double]  // time (from start) at which each point is reached
        let start: Double
        let land: Double

        func position(at e: Double, d: CGFloat) -> CGPoint {
            if e >= land { return slot }
            let u = e - start
            var k = 0
            while k < cumulative.count - 2 && u >= cumulative[k + 1] { k += 1 }
            let span = max(cumulative[k + 1] - cumulative[k], 0.0001)
            let f = min(max((u - cumulative[k]) / span, 0), 1)
            let a = points[k], b = points[k + 1]
            let x = a.x + (b.x - a.x) * f
            if k == 0 {
                return CGPoint(x: x, y: a.y + (b.y - a.y) * f * f)      // falling in: speeds up
            }
            let hop = sin(.pi * f) * d * 0.45                          // little bounce off each peg
            return CGPoint(x: x, y: a.y + (b.y - a.y) * f - hop)
        }
    }

    let d: CGFloat
    let pegs: [CGPoint]
    let marbles: [Marble]
    let finishTime: Double

    init(size: CGSize, duration: Double) {
        let w = size.width, h = size.height
        let d = max(14, min(w / 16, h / 15))
        self.d = d
        var rng = SeededRandom(seed: 42)

        // Marble resting spots: hexagonal packing, bottom row first, each row in a random order.
        let rowH = d * 0.866
        let cols = Int(w / d)
        let x0 = (w - CGFloat(cols) * d) / 2 + d / 2
        var slots: [CGPoint] = []
        var y = h - d / 2
        var row = 0
        while y > d * 0.4 {
            let n = row % 2 == 0 ? cols : cols - 1
            let startX = row % 2 == 0 ? x0 : x0 + d / 2
            var rowSlots = (0..<n).map { CGPoint(x: startX + CGFloat($0) * d, y: y) }
            rng.shuffle(&rowSlots)
            slots += rowSlots
            y -= rowH
            row += 1
        }

        // Pegs: staggered rows; neighbouring rows are offset by one marble width.
        let mx = (w - CGFloat(Int(w / d)) * d) / 2
        let maxM = Int((w - mx) / d)
        var pegRows: [(y: CGFloat, ms: [Int])] = []
        var pegs: [CGPoint] = []
        var py = d * 1.8
        var pr = 0
        while py < h - d * 1.2 {
            let ms = (1..<maxM).filter { $0 % 2 == (pr % 2 == 0 ? 1 : 0) }
            pegRows.append((py, ms))
            pegs += ms.map { CGPoint(x: mx + CGFloat($0) * d, y: py) }
            py += d * 1.6
            pr += 1
        }
        self.pegs = pegs

        // A path and timing for each marble.
        let finish = duration * 0.985
        finishTime = finish
        let count = slots.count
        var marbles: [Marble] = []
        marbles.reserveCapacity(count)
        for (i, slot) in slots.enumerated() {
            let rowsAbove = pegRows.filter { $0.y < slot.y - d * 0.9 }
            var points: [CGPoint] = []
            if rowsAbove.isEmpty {
                points = [CGPoint(x: slot.x, y: -d), slot]
            } else {
                // work backwards from the peg just above the slot, wandering left/right on the way up
                var ms: [Int] = Array(repeating: 0, count: rowsAbove.count)
                let last = rowsAbove.count - 1
                ms[last] = rowsAbove[last].ms.min { abs(mx + CGFloat($0) * d - slot.x) < abs(mx + CGFloat($1) * d - slot.x) } ?? 1
                if last > 0 {
                    for k in stride(from: last - 1, through: 0, by: -1) {
                        let options = rowsAbove[k].ms.filter { abs($0 - ms[k + 1]) == 1 }
                        ms[k] = options.isEmpty ? (rowsAbove[k].ms.first ?? 1) : options[Int(rng.next() * Double(options.count)) % options.count]
                    }
                }
                let firstX = mx + CGFloat(ms[0]) * d
                points.append(CGPoint(x: firstX, y: -d))
                for k in 0...last {
                    points.append(CGPoint(x: mx + CGFloat(ms[k]) * d, y: rowsAbove[k].y - d * 0.55))
                }
                points.append(slot)
            }
            var cumulative: [Double] = [0]
            for k in 1..<points.count {
                let dist = Double(hypot(points[k].x - points[k - 1].x, points[k].y - points[k - 1].y) / d)
                let step: Double
                if k == 1 { step = 0.2 + dist * 0.035 }
                else if k == points.count - 1 { step = 0.1 + dist * 0.05 }
                else { step = 0.13 }
                cumulative.append(cumulative[k - 1] + step)
            }
            let land = Double(i + 1) / Double(count) * finish
            var fall = cumulative[cumulative.count - 1]
            if fall > land {    // the very first marbles have to hurry
                let scale = land / fall
                cumulative = cumulative.map { $0 * scale }
                fall = land
            }
            marbles.append(Marble(slot: slot, color: Int(rng.next() * 7), points: points,
                                  cumulative: cumulative, start: land - fall, land: land))
        }
        self.marbles = marbles
    }

    func landed(at e: Double) -> Int {
        Int(min(max(e / finishTime, 0), 1) * Double(marbles.count))
    }
}

/// Small repeatable random number generator, so layouts are the same every frame.
struct SeededRandom {
    private var state: UInt64
    init(seed: UInt64) { state = seed &* 6364136223846793005 &+ 1442695040888963407 }

    mutating func next() -> Double {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return Double(state >> 11) / Double(1 << 53)
    }

    mutating func shuffle<T>(_ a: inout [T]) {
        guard a.count > 1 else { return }
        for i in stride(from: a.count - 1, to: 0, by: -1) {
            let j = Int(next() * Double(i + 1)) % (i + 1)
            a.swapAt(i, j)
        }
    }
}
