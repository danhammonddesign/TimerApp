import SwiftUI

/// The payoff! Explosion → mystery gift → tap to open → sticker reveal.
@MainActor
struct FinaleView: View {
    let theme: Theme
    let sticker: Sticker
    var onDone: () -> Void

    enum Phase { case boom, gift, opening, reveal }

    @EnvironmentObject var rewards: RewardStore
    @State private var phase: Phase = .boom
    @State private var flash = 1.0
    @State private var shake: CGFloat = 0
    @State private var goalScale: CGFloat = 1
    @State private var goalOpacity = 1.0
    @State private var titleIn = false
    @State private var bigBurst = 0
    @State private var fireworks = 0
    @State private var stickerBurst = 0
    @State private var giftWobble = false
    @State private var giftShake: CGFloat = 0
    @State private var stickerIn = false
    @State private var showBook = false
    @State private var isNew = false

    var body: some View {
        ZStack {
            AnimatedBackground(theme: theme, count: 30, speedBoost: 3)

            if phase == .reveal {
                Sunburst(color: sticker.rarity.color)
                    .ignoresSafeArea()
                    .opacity(0.55)
                    .transition(.opacity)
            }

            VStack(spacing: 18) {
                Text(theme.finaleTitle)
                    .cartoonText(44, color: theme.accent)
                    .multilineTextAlignment(.center)
                    .scaleEffect(titleIn ? 1 : 4)
                    .opacity(titleIn ? 1 : 0)
                    .rotationEffect(.degrees(titleIn ? -3 : 20))
                    .padding(.top, 40)

                Spacer()

                ZStack {
                    // 1. the goal (planet / volcano / rainbow...) blows up
                    Text(theme.goal)
                        .font(.system(size: 160))
                        .scaleEffect(goalScale)
                        .opacity(goalOpacity)

                    // 2. a mystery gift drops in
                    if phase == .gift || phase == .opening {
                        giftView
                            .transition(.asymmetric(insertion: .move(edge: .top).combined(with: .scale),
                                                    removal: .scale(scale: 3).combined(with: .opacity)))
                    }

                    // 3. the sticker!
                    if phase == .reveal {
                        stickerView
                    }
                }
                .frame(height: 300)

                Spacer()

                if phase == .reveal {
                    revealFooter
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding()

            ConfettiView(trigger: bigBurst, emojis: theme.floaters + [theme.goal], style: .big)
                .ignoresSafeArea()
            ConfettiView(trigger: fireworks, emojis: ["✨", "⭐️"], style: .firework, origin: CGPoint(x: 0.2, y: 0.3))
                .ignoresSafeArea()
            ConfettiView(trigger: fireworks, emojis: ["✨", "💥"], style: .firework, origin: CGPoint(x: 0.8, y: 0.25))
                .ignoresSafeArea()
            ConfettiView(trigger: stickerBurst, emojis: [sticker.emoji, "⭐️", "✨"], style: .big,
                         origin: CGPoint(x: 0.5, y: 0.45))
                .ignoresSafeArea()

            // white flash
            Color.white
                .opacity(flash)
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
        .modifier(Shake(amount: 14, shakesPerUnit: 8, animatableData: shake))
        .sheet(isPresented: $showBook) { StickerBookView(highlight: sticker).environmentObject(rewards) }
        .onAppear(perform: runBoom)
    }

    // MARK: Gift

    private var giftView: some View {
        VStack(spacing: 16) {
            Text("🎁")
                .font(.system(size: 170))
                .rotationEffect(.degrees(giftWobble ? 8 : -8))
                .scaleEffect(giftWobble ? 1.06 : 0.96)
                .modifier(Shake(amount: 18, shakesPerUnit: 10, animatableData: giftShake))
                .shadow(color: theme.accent, radius: 30)
                .animation(.easeInOut(duration: 0.35).repeatForever(autoreverses: true), value: giftWobble)
            Text(phase == .opening ? "Opening..." : "Tap to open!")
                .cartoonText(30)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: openGift)
    }

    // MARK: Sticker

    private var stickerView: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(RadialGradient(colors: [sticker.rarity.color, sticker.rarity.color.opacity(0)],
                                         center: .center, startRadius: 10, endRadius: 140))
                    .frame(width: 280, height: 280)
                Text(sticker.emoji)
                    .font(.system(size: 150))
                    .shadow(color: .black.opacity(0.4), radius: 8, y: 6)
            }
            .scaleEffect(stickerIn ? 1 : 0.01)
            .rotationEffect(.degrees(stickerIn ? 0 : -540))

            if isNew {
                Text("NEW!")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 14).padding(.vertical, 4)
                    .background(Capsule().fill(Color.yellow))
                    .rotationEffect(.degrees(-6))
                    .scaleEffect(stickerIn ? 1 : 0)
            }
        }
    }

    private var revealFooter: some View {
        VStack(spacing: 12) {
            Text(sticker.rarity.label).cartoonText(26, color: sticker.rarity.color)
            Text(sticker.name).cartoonText(36)
            if rewards.streak > 1 {
                Text("🔥 \(rewards.streak) day streak!").cartoonText(22, color: .orange)
            }
            HStack(spacing: 14) {
                Button("📖 Stickers") {
                    AudioManager.shared.play(.tap)
                    showBook = true
                }
                .buttonStyle(BigButtonStyle(color: .white.opacity(0.9)))
                Button("Done!") {
                    AudioManager.shared.play(.tap)
                    AudioManager.shared.stopAll()
                    onDone()
                }
                .buttonStyle(BigButtonStyle(color: theme.accent))
            }
            .padding(.top, 8)
        }
        .padding(.bottom, 20)
    }

    // MARK: Timeline

    private func runBoom() {
        let audio = AudioManager.shared
        isNew = rewards.lastWasNew
        audio.play(.boom)
        Haptics.boom()
        bigBurst += 1

        withAnimation(.easeOut(duration: 0.7)) { flash = 0 }
        withAnimation(.linear(duration: 0.6)) { shake = 1 }
        withAnimation(.easeIn(duration: 0.5)) { goalScale = 3.5; goalOpacity = 0 }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.45).delay(0.2)) { titleIn = true }

        after(0.6) {
            audio.play(.fanfare, volume: 0.8)
            audio.sayNow(theme: theme.id, line: "finale")
            fireworks += 1
        }
        after(1.4) { fireworks += 1; audio.play(.sparkle) }
        after(2.4) {
            audio.play(.whoosh)
            withAnimation(.spring(response: 0.6, dampingFraction: 0.55)) { phase = .gift }
            after(0.1) { giftWobble = true }
        }
        // if nobody taps, open it anyway
        after(9) { if phase == .gift { openGift() } }
    }

    private func openGift() {
        guard phase == .gift else { return }
        let audio = AudioManager.shared
        phase = .opening
        audio.play(.rattle)
        Haptics.bump()
        withAnimation(.linear(duration: 0.9)) { giftShake = 3 }
        after(0.45) { audio.play(.rattle); Haptics.bump() }
        after(0.9) {
            audio.play(.pop)
            audio.play(.sparkle)
            audio.play(.fanfare, volume: 0.6)
            Haptics.boom()
            flash = 0.9
            after(0.05) { withAnimation(.easeOut(duration: 0.5)) { flash = 0 } }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { phase = .reveal }
            withAnimation(.spring(response: 0.8, dampingFraction: 0.55)) { stickerIn = true }
            stickerBurst += 1
        }
        after(1.6) { fireworks += 1 }
    }

    private func after(_ seconds: Double, _ work: @escaping @MainActor () -> Void) {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            work()
        }
    }
}
