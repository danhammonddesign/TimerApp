import SwiftUI

/// Secret Picture timer: a grid of tiles hides a picture. Every few seconds one random
/// tile wobbles and flips away, and the whole cat or puppy is revealed when time runs out.
@MainActor
struct TileRevealTimer: View {
    @ObservedObject var session: BrushSession
    let theme: Theme
    let pet: Pet
    let seed: UInt64

    static let cols = 5
    static let rows = 6
    private static let flipLength = 0.45
    private static let wobbleLength = 0.8

    init(session: BrushSession, theme: Theme, pet: Pet, seed: UInt64) {
        self.session = session
        self.theme = theme
        self.pet = pet
        self.seed = seed
    }

    /// The moment each tile finishes flipping, indexed by tile position.
    private var flipEnds: [Double] {
        let n = Self.cols * Self.rows
        var order = Array(0..<n)
        var rng = SeededRandom(seed: seed)
        rng.shuffle(&order)
        var ends = [Double](repeating: 0, count: n)
        let finish = session.duration * 0.985
        for (rank, tile) in order.enumerated() {
            ends[tile] = Double(rank + 1) / Double(n) * finish
        }
        return ends
    }

    var body: some View {
        let ends = flipEnds
        GeometryReader { geo in
            let tile = min(geo.size.width / CGFloat(Self.cols), geo.size.height / CGFloat(Self.rows))
            let boardW = tile * CGFloat(Self.cols), boardH = tile * CGFloat(Self.rows)
            let shape = RoundedRectangle(cornerRadius: 22, style: .continuous)

            ZStack {
                shape.fill(Palette.border).offset(y: 5)
                PetPicture(pet: pet)
                    .clipShape(shape)

                TimelineView(.animation) { tl in
                    let e = session.elapsed(at: tl.date)
                    let t = tl.date.timeIntervalSinceReferenceDate
                    ZStack(alignment: .topLeading) {
                        ForEach(0..<(Self.cols * Self.rows), id: \.self) { i in
                            let f = (e - (ends[i] - Self.flipLength)) / Self.flipLength      // 0...1 while flipping
                            if f < 1 {
                                let wobbling = e > ends[i] - Self.flipLength - Self.wobbleLength && f < 0
                                TileCover(theme: theme, index: i)
                                    .frame(width: tile - 6, height: tile - 6)
                                    .rotationEffect(.degrees(wobbling ? sin(t * 30) * 6 : 0))
                                    .scaleEffect(wobbling ? 1.06 : 1)
                                    .rotation3DEffect(.degrees(max(f, 0) * 90), axis: (x: 0, y: 1, z: 0), perspective: 0.6)
                                    .opacity(f > 0.95 ? 0 : 1)
                                    .position(x: tile * (CGFloat(i % Self.cols) + 0.5),
                                              y: tile * (CGFloat(i / Self.cols) + 0.5))
                            }
                        }
                    }
                    .frame(width: boardW, height: boardH)
                }

                shape.stroke(Color.white.opacity(0.9), lineWidth: 5)
            }
            .frame(width: boardW, height: boardH)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
            .onChange(of: ends.filter { $0 <= session.elapsed }.count) {
                AudioManager.shared.play(.flip, volume: 0.6)
                Haptics.tap()
            }
        }
    }
}

/// Chunky tile with a question mark, waiting to be flipped.
struct TileCover: View {
    let theme: Theme
    let index: Int

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 12, style: .continuous)
        let alt = (index / TileRevealTimer.cols + index % TileRevealTimer.cols) % 2 == 0
        ZStack {
            shape.fill(theme.primaryLip).offset(y: 4)
            shape.fill(alt ? theme.primary : theme.primaryLight)
            Text("?")
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.9))
                .shadow(color: theme.primaryLip, radius: 0, y: 2)
        }
    }
}
