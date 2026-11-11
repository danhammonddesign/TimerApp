import SwiftUI

/// The little picture on each theme tile: a snapshot of that theme's timer
/// (a board of marbles, a half-full sand jar, a half-flipped picture) or Chompy for ring timers.
struct ThemeIcon: View {
    let theme: Theme

    var body: some View {
        switch theme.timer {
        case .ring:
            Mascot(costume: theme.costume, size: 70)
        case .plinko:
            MarbleGridIcon()
        case .sandJar:
            JarIcon(pet: theme.jarPets.contains(.shark) ? .shark : (theme.jarPets.first ?? .cat), fill: 0.5)
        case .tiles:
            TileIcon(theme: theme)
        }
    }
}

/// A small board packed with marbles.
struct MarbleGridIcon: View {
    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 14, style: .continuous)
        Canvas { context, size in
            let cols = 6
            let d = size.width / CGFloat(cols)
            var rng = SeededRandom(seed: 11)
            var row = 0
            var y = size.height - d / 2
            while y > -d / 2 {
                let n = row % 2 == 0 ? cols : cols + 1
                let x0 = row % 2 == 0 ? d / 2 : 0
                for c in 0..<n {
                    Marbles.draw(&context, at: CGPoint(x: x0 + CGFloat(c) * d, y: y), radius: d / 2,
                                 colorIndex: Int(rng.next() * 7))
                }
                y -= d * 0.866
                row += 1
            }
        }
        .background(Palette.card)
        .clipShape(shape)
        .overlay(shape.stroke(Palette.border, lineWidth: 3))
        .aspectRatio(1, contentMode: .fit)
    }
}

/// A pet-shaped jar partly filled with rainbow sand layers.
struct JarIcon: View {
    let pet: Pet
    var fill: CGFloat = 0.5

    var body: some View {
        let jar = PetJarShape(pet: pet)
        let aspect: CGFloat = pet == .shark ? 1.35 : (pet == .crab ? 1.3 : 0.85)
        ZStack {
            jar.fill(Color.white.opacity(0.12))
            // sand: stacked color bands from the bottom up to the fill line
            GeometryReader { g in
                let layers = 4
                let band = g.size.height * fill / CGFloat(layers)
                ZStack(alignment: .bottom) {
                    Color.clear
                    VStack(spacing: 0) {
                        ForEach((0..<layers).reversed(), id: \.self) { k in
                            SandJarTimer.rainbow[k].frame(height: band)
                        }
                    }
                }
            }
            .clipShape(jar)
            jar.stroke(Color.white.opacity(0.9), style: StrokeStyle(lineWidth: 3.5, lineJoin: .round))
            PetJarFace(pet: pet)
        }
        .aspectRatio(aspect, contentMode: .fit)
    }
}

/// A small tile board, half flipped, with part of the hidden cat showing.
struct TileIcon: View {
    let theme: Theme

    private static let cols = 3
    private static let rows = 3
    /// which spots are already flipped in the little preview
    private static let revealed: Set<Int> = [1, 3, 4, 8]

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 14, style: .continuous)
        GeometryReader { g in
            let tile = g.size.width / CGFloat(Self.cols)
            ZStack(alignment: .topLeading) {
                Palette.card
                PetPicture(pet: .cat)
                    .mask {
                        Canvas { context, _ in
                            for i in Self.revealed {
                                context.fill(Path(CGRect(x: tile * CGFloat(i % Self.cols), y: tile * CGFloat(i / Self.cols),
                                                         width: tile, height: tile)), with: .color(.black))
                            }
                        }
                    }
                ForEach(0..<(Self.cols * Self.rows), id: \.self) { i in
                    if !Self.revealed.contains(i) {
                        TileCover(theme: theme, index: i, fontSize: 15, corner: 7, lipOffset: 2.5)
                            .frame(width: tile - 4, height: tile - 4)
                            .position(x: tile * (CGFloat(i % Self.cols) + 0.5), y: tile * (CGFloat(i / Self.cols) + 0.5))
                    }
                }
            }
        }
        .clipShape(shape)
        .overlay(shape.stroke(Color.white.opacity(0.9), lineWidth: 3))
        .aspectRatio(1, contentMode: .fit)
    }
}
