import SwiftUI

/// Every sticker in the game. Ones you haven't won yet are mystery badges.
@MainActor
struct StickerBookView: View {
    var highlight: Sticker?

    @EnvironmentObject var rewards: RewardStore
    @Environment(\.dismiss) private var dismiss

    init(highlight: Sticker?) {
        self.highlight = highlight
    }

    private static let columns = [GridItem(.adaptive(minimum: 92), spacing: 14)]

    var body: some View {
        ZStack {
            Palette.dark.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Text("Sticker book").chunkyText(28)
                    Spacer()
                    IconButton(symbol: "xmark") { dismiss() }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                ChunkyProgressBar(progress: Double(rewards.collectedCount) / Double(max(rewards.totalStickers, 1)),
                                  color: Palette.yellow, light: Color(hex: 0xFFE46B))
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                Text("\(rewards.collectedCount) of \(rewards.totalStickers) found")
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(Palette.muted)
                    .padding(.top, 6)

                ScrollView {
                    VStack(spacing: 18) {
                        ForEach(Theme.all) { theme in
                            section(theme)
                        }
                    }
                    .padding(20)
                }
            }
        }
    }

    private func section(_ theme: Theme) -> some View {
        let shape = RoundedRectangle(cornerRadius: 22, style: .continuous)
        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Mascot(costume: theme.costume, size: 40)
                Text(theme.name).chunkyText(22)
            }
            LazyVGrid(columns: Self.columns, spacing: 16) {
                ForEach(theme.stickers) { sticker in
                    StickerTile(sticker: sticker, count: rewards.count(of: sticker), highlighted: sticker == highlight)
                }
            }
        }
        .padding(16)
        .background(shape.fill(Palette.card).overlay(shape.stroke(Palette.border, lineWidth: 2.5)))
        .background(shape.fill(Palette.border).offset(y: 4))
    }
}

struct StickerTile: View {
    let sticker: Sticker
    let count: Int
    let highlighted: Bool

    @State private var bounce = false

    init(sticker: Sticker, count: Int, highlighted: Bool) {
        self.sticker = sticker
        self.count = count
        self.highlighted = highlighted
    }

    var body: some View {
        let owned = count > 0
        VStack(spacing: 6) {
            StickerBadge(sticker: sticker, size: 72, owned: owned)
                .overlay(alignment: .topTrailing) {
                    if count > 1 {
                        Text("x\(count)")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundStyle(Palette.ink)
                            .padding(.horizontal, 7).padding(.vertical, 2)
                            .background(Capsule().fill(Color.white))
                            .offset(x: 6, y: -4)
                    }
                }
            Text(owned ? sticker.name : "???")
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundStyle(owned ? Color.white : Palette.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .scaleEffect(bounce ? 1.15 : 1)
        .onAppear {
            guard highlighted else { return }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.3).repeatCount(3, autoreverses: true).delay(0.4)) {
                bounce = true
            }
        }
    }
}
