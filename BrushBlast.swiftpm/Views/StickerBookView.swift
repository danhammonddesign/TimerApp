import SwiftUI

/// Every sticker in the game. Ones you haven't won yet are mystery silhouettes.
@MainActor
struct StickerBookView: View {
    var highlight: Sticker?

    @EnvironmentObject var rewards: RewardStore
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.adaptive(minimum: 96), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("You've found \(rewards.collectedCount) of \(rewards.totalStickers) stickers!")
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .padding(.horizontal)

                    ForEach(Theme.all) { theme in
                        VStack(alignment: .leading, spacing: 10) {
                            Text("\(theme.hero) \(theme.name)")
                                .font(.system(size: 24, weight: .black, design: .rounded))
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(theme.stickers) { sticker in
                                    StickerTile(sticker: sticker, count: rewards.count(of: sticker),
                                                theme: theme, highlighted: sticker == highlight)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(LinearGradient(colors: theme.colors.map { $0.opacity(0.85) },
                                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(hex: 0x15112B).ignoresSafeArea())
            .navigationTitle("📖 Sticker Book")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.font(.headline)
                }
            }
        }
    }
}

struct StickerTile: View {
    let sticker: Sticker
    let count: Int
    let theme: Theme
    let highlighted: Bool

    @State private var bounce = false

    var body: some View {
        let owned = count > 0
        VStack(spacing: 4) {
            ZStack(alignment: .topTrailing) {
                Text(sticker.emoji)
                    .font(.system(size: 48))
                    .brightness(owned ? 0 : -1)        // silhouette when not collected yet
                    .opacity(owned ? 1 : 0.35)
                    .frame(width: 80, height: 70)
                if count > 1 {
                    Text("x\(count)")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Capsule().fill(Color.white))
                }
            }
            Text(owned ? sticker.name : "???")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.black.opacity(0.25))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(owned ? sticker.rarity.color : .white.opacity(0.15), lineWidth: highlighted ? 4 : 2)
                )
        )
        .scaleEffect(bounce ? 1.12 : 1)
        .onAppear {
            guard highlighted else { return }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.3).repeatCount(3, autoreverses: true).delay(0.4)) {
                bounce = true
            }
        }
    }
}
