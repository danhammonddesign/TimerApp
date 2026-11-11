import SwiftUI

@MainActor
struct HomeView: View {
    var onStart: () -> Void

    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var rewards: RewardStore
    @ObservedObject private var audio = AudioManager.shared
    @State private var showBook = false

    init(onStart: @escaping () -> Void) {
        self.onStart = onStart
    }

    private static let durations: [Double] = [60, 120, 180]

    var body: some View {
        let theme = settings.theme
        ZStack {
            FlatBackground(theme: theme)
                .animation(.easeInOut(duration: 0.4), value: theme)

            VStack(spacing: 16) {
                statsBar
                Spacer(minLength: 0)

                VStack(spacing: 2) {
                    SpeechBubble(text: theme.tagline, accent: theme.primary, size: 20)
                        .id(theme.id)
                        .transition(.scale(scale: 0.5, anchor: .bottom).combined(with: .opacity))
                    Mascot(costume: theme.costume, talking: audio.isSpeaking, size: 170)
                        .id("mascot-\(theme.id)")
                        .transition(.scale(scale: 0.6).combined(with: .opacity))
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: theme)

                Spacer(minLength: 0)
                themePicker
                durationPicker
                Button("Start brushing") {
                    AudioManager.shared.stopVoice()
                    AudioManager.shared.play(.sparkle)
                    Haptics.bump()
                    onStart()
                }
                .buttonStyle(ChunkyButtonStyle(fill: theme.primary, lip: theme.primaryLip, text: theme.buttonText))
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            }
        }
        .sheet(isPresented: $showBook) { StickerBookView(highlight: nil).environmentObject(rewards) }
    }

    // MARK: Pieces

    private var statsBar: some View {
        HStack(spacing: 18) {
            HStack(spacing: 6) {
                Image(systemName: "flame.fill").foregroundStyle(Palette.orange)
                Text("\(rewards.streak)").foregroundStyle(Palette.orange)
            }
            Button {
                AudioManager.shared.play(.tap)
                showBook = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "book.fill").foregroundStyle(Palette.blue)
                    Text("\(rewards.collectedCount)/\(rewards.totalStickers)").foregroundStyle(Palette.blue)
                }
            }
            Spacer()
            toggle(on: settings.musicOn, symbol: "music.note") { settings.musicOn.toggle() }
            toggle(on: settings.voiceOn, symbol: settings.voiceOn ? "speaker.wave.2.fill" : "speaker.slash.fill") {
                settings.voiceOn.toggle()
            }
        }
        .font(.system(size: 20, weight: .heavy, design: .rounded))
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private func toggle(on: Bool, symbol: String, action: @escaping () -> Void) -> some View {
        Button {
            AudioManager.shared.play(.tap)
            action()
        } label: {
            Image(systemName: symbol)
                .foregroundStyle(on ? Color.white : Palette.muted.opacity(0.6))
                .frame(width: 30, height: 30)
        }
    }

    private var themePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Theme.all) { theme in
                    ThemeTile(theme: theme, selected: theme == settings.theme)
                        .onTapGesture { select(theme) }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
    }

    private func select(_ theme: Theme) {
        guard theme != settings.theme else { return }
        AudioManager.shared.play(.tap)
        Haptics.tap()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { settings.theme = theme }
        AudioManager.shared.voiceEnabled = settings.voiceOn
        AudioManager.shared.sayNow(theme: theme.id, line: "intro")   // hear the narrator!
    }

    private var durationPicker: some View {
        HStack(spacing: 10) {
            ForEach(Self.durations, id: \.self) { seconds in
                let selected = settings.duration == seconds
                Button("\(Int(seconds / 60)) min") {
                    AudioManager.shared.play(.tap)
                    settings.duration = seconds
                }
                .buttonStyle(SelectableChipStyle(selected: selected, theme: settings.theme))
            }
        }
        .padding(.horizontal, 20)
    }
}

/// Small pill that is outlined when off and filled with the theme color when on.
struct SelectableChipStyle: ButtonStyle {
    var selected: Bool
    var theme: Theme

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        let shape = RoundedRectangle(cornerRadius: 14, style: .continuous)
        return configuration.label
            .font(.system(size: 18, weight: .heavy, design: .rounded))
            .foregroundStyle(selected ? theme.buttonText : Palette.muted)
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(
                shape.fill(selected ? theme.primary : Palette.card)
                    .overlay(shape.stroke(selected ? Color.clear : Palette.border, lineWidth: 2.5))
            )
            .offset(y: pressed ? 4 : 0)
            .background(shape.fill(selected ? theme.primaryLip : Palette.border).offset(y: 4))
            .padding(.bottom, 4)
    }
}

/// Theme choice: the mascot in that theme's costume on a chunky tile.
struct ThemeTile: View {
    let theme: Theme
    let selected: Bool

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 20, style: .continuous)
        VStack(spacing: 6) {
            Mascot(costume: theme.costume, size: 70)
                .frame(height: 84)
            Text(theme.name)
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 10)
        .frame(width: 118)
        .background(
            shape.fill(LinearGradient(colors: [theme.bgTop, theme.bgBottom], startPoint: .top, endPoint: .bottom))
                .overlay(shape.stroke(selected ? theme.primary : Palette.border, lineWidth: selected ? 4 : 2.5))
        )
        .background(shape.fill(selected ? theme.primaryLip : Palette.border).offset(y: 5))
        .offset(y: selected ? -4 : 0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selected)
    }
}
