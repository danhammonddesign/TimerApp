import SwiftUI

@MainActor
struct HomeView: View {
    var onStart: () -> Void

    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var rewards: RewardStore
    @State private var pulse = false
    @State private var showBook = false

    private let durations: [Double] = [60, 120, 180]

    var body: some View {
        ZStack {
            AnimatedBackground(theme: settings.theme)
                .animation(.easeInOut(duration: 0.5), value: settings.theme)

            VStack(spacing: 18) {
                header
                statsRow
                themePicker
                durationPicker
                Spacer(minLength: 0)
                startButton
                Spacer(minLength: 0)
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showBook) { StickerBookView(highlight: nil).environmentObject(rewards) }
        .onAppear { pulse = true }
    }

    private var header: some View {
        HStack {
            Spacer()
            TimelineView(.animation) { tl in
                let t = tl.date.timeIntervalSinceReferenceDate
                HStack(spacing: 6) {
                    Text("🪥").font(.system(size: 44)).rotationEffect(.degrees(sin(t * 6) * 15))
                    Text("Brush Blast!")
                        .cartoonText(42)
                        .scaleEffect(1 + 0.03 * sin(t * 3))
                }
            }
            Spacer()
        }
        .overlay(alignment: .trailing) {
            HStack(spacing: 6) {
                toggle(on: settings.musicOn, icon: "music.note") { settings.musicOn.toggle() }
                toggle(on: settings.voiceOn, icon: "mouth.fill") { settings.voiceOn.toggle() }
            }
            .padding(.trailing)
            .offset(y: 52)
        }
    }

    private func toggle(on: Bool, icon: String, action: @escaping () -> Void) -> some View {
        Button {
            AudioManager.shared.play(.tap)
            action()
        } label: {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(on ? Color.white : Color.white.opacity(0.35))
                .frame(width: 38, height: 38)
                .background(Circle().fill(.black.opacity(on ? 0.3 : 0.15)))
                .overlay { if !on { Rectangle().fill(.white.opacity(0.6)).frame(width: 2, height: 30).rotationEffect(.degrees(45)) } }
        }
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            chip("🔥 \(rewards.streak) day\(rewards.streak == 1 ? "" : "s")")
            Button {
                AudioManager.shared.play(.tap)
                showBook = true
            } label: {
                chip("📖 \(rewards.collectedCount)/\(rewards.totalStickers)")
            }
            Spacer()
        }
        .padding(.horizontal)
    }

    private func chip(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 18, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(Capsule().fill(.black.opacity(0.3)))
    }

    private var themePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pick your adventure")
                .cartoonText(22)
                .padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(Theme.all) { theme in
                        ThemeCard(theme: theme, selected: theme == settings.theme)
                            .onTapGesture { select(theme) }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 14)
            }
        }
    }

    private func select(_ theme: Theme) {
        guard theme != settings.theme else { return }
        AudioManager.shared.play(.whoosh, volume: 0.6)
        Haptics.tap()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { settings.theme = theme }
        AudioManager.shared.voiceEnabled = settings.voiceOn
        AudioManager.shared.sayNow(theme: theme.id, line: "intro")   // hear the narrator!
    }

    private var durationPicker: some View {
        HStack(spacing: 10) {
            ForEach(durations, id: \.self) { seconds in
                let selected = settings.duration == seconds
                Button {
                    AudioManager.shared.play(.tap)
                    withAnimation(.spring()) { settings.duration = seconds }
                } label: {
                    Text("\(Int(seconds / 60)) min")
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .foregroundStyle(selected ? Color.black : Color.white)
                        .padding(.horizontal, 20).padding(.vertical, 10)
                        .background(Capsule().fill(selected ? settings.theme.accent : Color.black.opacity(0.3)))
                        .scaleEffect(selected ? 1.1 : 1)
                }
            }
        }
    }

    private var startButton: some View {
        Button {
            AudioManager.shared.stopVoice()
            AudioManager.shared.play(.sparkle)
            Haptics.bump()
            onStart()
        } label: {
            HStack(spacing: 10) {
                Text(settings.theme.hero).font(.system(size: 40))
                Text("START!")
            }
        }
        .buttonStyle(BigButtonStyle(color: settings.theme.accent))
        .scaleEffect(pulse ? 1.08 : 0.96)
        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulse)
    }
}

struct ThemeCard: View {
    let theme: Theme
    let selected: Bool

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 2) {
                Text(theme.hero).font(.system(size: 56))
                Text(theme.goal).font(.system(size: 34))
            }
            Text(theme.name)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            Text(theme.tagline)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 34)
        }
        .padding(14)
        .frame(width: 170, height: 190)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(LinearGradient(colors: theme.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(selected ? theme.accent : .white.opacity(0.3), lineWidth: selected ? 5 : 2)
        )
        .shadow(color: selected ? theme.accent.opacity(0.8) : .black.opacity(0.3), radius: selected ? 16 : 6)
        .scaleEffect(selected ? 1.06 : 0.94)
        .animation(.spring(response: 0.35, dampingFraction: 0.55), value: selected)
    }
}
