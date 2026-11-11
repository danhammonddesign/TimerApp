import SwiftUI

/// The payoff! Explosion → mystery gift → tap to open → sticker reveal.
@MainActor
struct FinaleView: View {
    let theme: Theme
    let sticker: Sticker
    var onDone: () -> Void

    enum Phase { case boom, gift, opening, reveal }

    @EnvironmentObject var rewards: RewardStore
    @ObservedObject private var audio = AudioManager.shared
    @State private var phase: Phase = .boom
    @State private var flash = 1.0
    @State private var shake: CGFloat = 0
    @State private var titleIn = false
    @State private var mascotIn = false
    @State private var bigBurst = 0
    @State private var fireworks = 0
    @State private var stickerBurst = 0
    @State private var giftWobble = false
    @State private var giftShake: CGFloat = 0
    @State private var lidOff = false
    @State private var stickerIn = false
    @State private var showBook = false
    @State private var isNew = false

    init(theme: Theme, sticker: Sticker, onDone: @escaping () -> Void) {
        self.theme = theme
        self.sticker = sticker
        self.onDone = onDone
    }

    var body: some View {
        ZStack {
            FlatBackground(theme: theme, count: 26, speed: 3)

            if phase == .reveal {
                FlatSunburst(color: sticker.rarity.color)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }

            VStack(spacing: 16) {
                Text(phase == .reveal ? "New sticker!" : theme.finaleTitle)
                    .chunkyText(40, color: theme.primary, lip: theme.primaryLip)
                    .multilineTextAlignment(.center)
                    .scaleEffect(titleIn ? 1 : 3)
                    .opacity(titleIn ? 1 : 0)
                    .padding(.top, 30)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: phase)

                Spacer()

                ZStack {
                    switch phase {
                    case .boom:
                        Mascot(costume: theme.costume, mood: .cheer, talking: audio.isSpeaking, size: 220)
                            .scaleEffect(mascotIn ? 1 : 0.2)
                            .opacity(mascotIn ? 1 : 0)
                    case .gift, .opening:
                        FlatGift(color: theme.primary, lip: theme.primaryLip, lidOff: lidOff)
                            .frame(width: 190, height: 190)
                            .rotationEffect(.degrees(giftWobble ? 6 : -6))
                            .scaleEffect(giftWobble ? 1.05 : 0.97)
                            .animation(.easeInOut(duration: 0.35).repeatForever(autoreverses: true), value: giftWobble)
                            .modifier(Shake(amount: 16, shakesPerUnit: 10, animatableData: giftShake))
                            .onTapGesture { openGift() }
                            .transition(.asymmetric(insertion: .move(edge: .top).combined(with: .opacity),
                                                    removal: .scale(scale: 1.6).combined(with: .opacity)))
                    case .reveal:
                        StickerBadge(sticker: sticker, size: 200)
                            .scaleEffect(stickerIn ? 1 : 0.01)
                            .rotationEffect(.degrees(stickerIn ? 0 : -360))
                            .overlay(alignment: .topTrailing) {
                                if isNew {
                                    Text("NEW")
                                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                                        .foregroundStyle(Color(hex: 0x5A3D00))
                                        .padding(.horizontal, 12).padding(.vertical, 5)
                                        .background(Capsule().fill(Palette.yellow))
                                        .background(Capsule().fill(Palette.yellowLip).offset(y: 3))
                                        .rotationEffect(.degrees(12))
                                        .scaleEffect(stickerIn ? 1 : 0)
                                }
                            }
                    }
                }
                .frame(height: 280)

                Spacer()

                footer
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)

            ConfettiView(trigger: bigBurst, colors: theme.shapeColors + [theme.primary, Palette.pink, Palette.green], style: .big)
                .ignoresSafeArea()
            ConfettiView(trigger: fireworks, colors: [Palette.yellow, .white], style: .firework, origin: CGPoint(x: 0.18, y: 0.28))
                .ignoresSafeArea()
            ConfettiView(trigger: fireworks, colors: [theme.primary, .white], style: .firework, origin: CGPoint(x: 0.82, y: 0.22))
                .ignoresSafeArea()
            ConfettiView(trigger: stickerBurst, colors: [sticker.rarity.color, .white, theme.primary], style: .big,
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
        .onAppear { runBoom() }
    }

    // MARK: Footer

    @ViewBuilder
    private var footer: some View {
        switch phase {
        case .boom:
            Color.clear.frame(height: 63)
        case .gift, .opening:
            Button(phase == .opening ? "Opening..." : "Open it!") { openGift() }
                .buttonStyle(ChunkyButtonStyle(fill: theme.primary, lip: theme.primaryLip, text: theme.buttonText))
                .disabled(phase == .opening)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        case .reveal:
            VStack(spacing: 14) {
                HStack(spacing: 12) {
                    Mascot(costume: theme.costume, mood: .happy, talking: audio.isSpeaking, size: 80)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(sticker.rarity.label.uppercased())
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .tracking(1)
                            .foregroundStyle(sticker.rarity.color)
                        Text(sticker.name).chunkyText(28)
                        if rewards.streak > 0 {
                            Label("\(rewards.streak) day streak", systemImage: "flame.fill")
                                .font(.system(size: 16, weight: .heavy, design: .rounded))
                                .foregroundStyle(Palette.orange)
                        }
                    }
                    Spacer(minLength: 0)
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Palette.card.opacity(0.9)))

                Button("Continue") {
                    AudioManager.shared.play(.tap)
                    AudioManager.shared.stopAll()
                    onDone()
                }
                .buttonStyle(ChunkyButtonStyle(fill: theme.primary, lip: theme.primaryLip, text: theme.buttonText))
                Button("Sticker book") {
                    AudioManager.shared.play(.tap)
                    showBook = true
                }
                .buttonStyle(OutlineButtonStyle())
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    // MARK: Timeline

    private func runBoom() {
        isNew = rewards.lastWasNew
        audio.play(.boom)
        Haptics.boom()
        bigBurst += 1

        withAnimation(.easeOut(duration: 0.7)) { flash = 0 }
        withAnimation(.linear(duration: 0.6)) { shake = 1 }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.5).delay(0.15)) { titleIn = true; mascotIn = true }

        after(0.6) {
            audio.play(.fanfare, volume: 0.8)
            audio.sayNow(theme: theme.id, line: "finale")
            fireworks += 1
        }
        after(1.4) { fireworks += 1; audio.play(.sparkle) }
        after(4.2) {
            audio.play(.whoosh)
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) { phase = .gift }
            after(0.1) { giftWobble = true }
        }
        // if nobody taps, open it anyway
        after(12) { if phase == .gift { openGift() } }
    }

    private func openGift() {
        guard phase == .gift else { return }
        phase = .opening
        audio.play(.rattle)
        Haptics.bump()
        withAnimation(.linear(duration: 0.9)) { giftShake = 3 }
        after(0.45) { audio.play(.rattle); Haptics.bump() }
        after(0.9) {
            withAnimation(.easeOut(duration: 0.25)) { lidOff = true }
            audio.play(.pop)
        }
        after(1.1) {
            audio.play(.sparkle)
            audio.play(.fanfare, volume: 0.6)
            Haptics.boom()
            flash = 0.9
            after(0.05) { withAnimation(.easeOut(duration: 0.5)) { flash = 0 } }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { phase = .reveal }
            withAnimation(.spring(response: 0.8, dampingFraction: 0.55)) { stickerIn = true }
            stickerBurst += 1
        }
        after(1.8) { fireworks += 1 }
    }

    private func after(_ seconds: Double, _ work: @escaping @MainActor () -> Void) {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            work()
        }
    }
}

/// Flat gift box. The lid pops off when `lidOff` becomes true.
struct FlatGift: View {
    var color: Color
    var lip: Color
    var lidOff: Bool

    var body: some View {
        GeometryReader { g in
            let w = g.size.width, h = g.size.height
            ZStack {
                // box
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(lip)
                    .frame(width: w * 0.78, height: h * 0.55)
                    .position(x: w / 2, y: h * 0.71)
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(color)
                    .frame(width: w * 0.78, height: h * 0.5)
                    .position(x: w / 2, y: h * 0.69)
                Rectangle().fill(Palette.yellow)
                    .frame(width: w * 0.14, height: h * 0.55)
                    .position(x: w / 2, y: h * 0.71)

                // lid + bow
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(lip)
                        .frame(width: w * 0.9, height: h * 0.2)
                        .offset(y: 5)
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(color)
                        .frame(width: w * 0.9, height: h * 0.2)
                    Rectangle().fill(Palette.yellow).frame(width: w * 0.14, height: h * 0.2)
                    Ellipse().fill(Palette.yellow)
                        .frame(width: w * 0.26, height: h * 0.17)
                        .rotationEffect(.degrees(-30))
                        .offset(x: -w * 0.13, y: -h * 0.15)
                    Ellipse().fill(Palette.yellow)
                        .frame(width: w * 0.26, height: h * 0.17)
                        .rotationEffect(.degrees(30))
                        .offset(x: w * 0.13, y: -h * 0.15)
                    Circle().fill(Palette.yellowLip)
                        .frame(width: w * 0.12, height: w * 0.12)
                        .offset(y: -h * 0.11)
                }
                .position(x: w / 2, y: h * 0.38)
                .offset(x: lidOff ? w * 0.4 : 0, y: lidOff ? -h * 0.8 : 0)
                .rotationEffect(.degrees(lidOff ? 35 : 0))
                .opacity(lidOff ? 0 : 1)
            }
        }
    }
}

/// A sticker in a chunky round badge.
struct StickerBadge: View {
    let sticker: Sticker
    var size: CGFloat = 80
    var owned = true

    var body: some View {
        ZStack {
            Circle().fill(owned ? sticker.rarity.lip : Palette.border).offset(y: size * 0.05)
            Circle().fill(owned ? sticker.rarity.color : Palette.card)
            Circle()
                .stroke(Color.white.opacity(owned ? 0.85 : 0.1), lineWidth: size * 0.04)
                .padding(size * 0.07)
            if owned {
                Text(sticker.emoji).font(.system(size: size * 0.5))
            } else {
                Image(systemName: "questionmark")
                    .font(.system(size: size * 0.38, weight: .black))
                    .foregroundStyle(Palette.border)
            }
        }
        .frame(width: size, height: size)
    }
}
