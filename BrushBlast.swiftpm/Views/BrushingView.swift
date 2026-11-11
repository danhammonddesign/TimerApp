import SwiftUI

@MainActor
struct BrushingView: View {
    let theme: Theme
    var onFinish: () -> Void
    var onQuit: () -> Void

    @EnvironmentObject var settings: AppSettings
    @StateObject private var session: BrushSession
    @State private var showPause = false

    init(theme: Theme, duration: TimeInterval, onFinish: @escaping () -> Void, onQuit: @escaping () -> Void) {
        self.theme = theme
        self.onFinish = onFinish
        self.onQuit = onQuit
        _session = StateObject(wrappedValue: BrushSession(theme: theme, duration: duration))
    }

    var body: some View {
        ZStack {
            AnimatedBackground(theme: theme, speedBoost: 1.4)
            // the screen glows brighter as you get closer to the end
            RadialGradient(colors: [theme.accent.opacity(0.35 * session.progress), .clear],
                           center: .center, startRadius: 10, endRadius: 420)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 14) {
                topBar
                zoneBanner
                Spacer(minLength: 0)
                ProgressRing(session: session, theme: theme)
                    .frame(width: 270, height: 270)
                Spacer(minLength: 0)
                MouthMap(zone: session.zone, theme: theme)
                    .frame(height: 170)
                    .padding(.horizontal, 24)
                ZoneStars(current: session.zone, theme: theme)
                    .padding(.bottom, 8)
            }
            .padding(.horizontal)

            // little celebration every time a zone is finished
            ConfettiView(trigger: session.zoneCelebration, emojis: [theme.floaters[0], "⭐️"], style: .small,
                         origin: CGPoint(x: 0.5, y: 0.45))
                .ignoresSafeArea()
                .allowsHitTesting(false)

            if let n = session.countdown {
                Text("\(n)")
                    .cartoonText(220, color: theme.accent)
                    .id(n)
                    .transition(.asymmetric(insertion: .scale(scale: 2.5).combined(with: .opacity),
                                            removal: .scale(scale: 0.3).combined(with: .opacity)))
                    .allowsHitTesting(false)
            }

            if showPause { pauseOverlay }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.55), value: session.countdown)
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true      // keep the screen on while brushing
            AudioManager.shared.voiceEnabled = settings.voiceOn
            AudioManager.shared.musicEnabled = settings.musicOn
            session.onFinish = {
                UIApplication.shared.isIdleTimerDisabled = false
                onFinish()
            }
            session.start()
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            if !session.isFinished { session.stop() }
        }
    }

    // MARK: Pieces

    private var topBar: some View {
        HStack {
            Button {
                AudioManager.shared.play(.tap)
                session.pause()
                withAnimation(.spring()) { showPause = true }
            } label: {
                Image(systemName: "pause.fill")
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(Circle().fill(.white.opacity(0.2)))
            }
            Spacer()
            Text(theme.name)
                .cartoonText(22)
                // grown-ups: long-press the title to jump to the end and test the finale
                .onLongPressGesture(minimumDuration: 1.5) { session.skipToEnd() }
            Spacer()
            Text(theme.goal)
                .font(.system(size: 34))
                .frame(width: 52, height: 52)
        }
    }

    private var zoneBanner: some View {
        ZStack {
            zoneBannerContent
                .id(session.zone)
                .transition(.asymmetric(insertion: .scale(scale: 0.2).combined(with: .opacity),
                                        removal: .move(edge: .top).combined(with: .opacity)))
        }
        .frame(height: 64)
        .animation(.spring(response: 0.45, dampingFraction: 0.5), value: session.zone)
    }

    private var zoneBannerContent: some View {
        HStack(spacing: 10) {
            Text(session.zone.arrow).font(.system(size: 36))
            Text(session.zone.title)
                .cartoonText(30)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 12)
        .background(Capsule().fill(.black.opacity(0.25)))
        .overlay(Capsule().stroke(theme.accent, lineWidth: 3))
    }

    private var pauseOverlay: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            VStack(spacing: 24) {
                Text("⏸️").font(.system(size: 80))
                Text("Paused").cartoonText(44)
                Button("Keep Brushing!") {
                    AudioManager.shared.play(.tap)
                    withAnimation(.spring()) { showPause = false }
                    session.resume()
                }
                .buttonStyle(BigButtonStyle(color: theme.accent))
                Button("Stop") {
                    AudioManager.shared.play(.tap)
                    session.stop()
                    onQuit()
                }
                .buttonStyle(BigButtonStyle(color: .white.opacity(0.85)))
            }
        }
        .transition(.opacity)
    }
}

// MARK: - Timer ring with the hero travelling to its goal

struct ProgressRing: View {
    @ObservedObject var session: BrushSession
    let theme: Theme

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let radius = size / 2 - 22
            let angle = Angle.degrees(-90 + session.progress * 360)

            ZStack {
                Circle()
                    .fill(.black.opacity(0.25))
                    .padding(22)
                Circle()
                    .stroke(.white.opacity(0.18), style: StrokeStyle(lineWidth: 26, lineCap: .round))
                    .padding(22)
                Circle()
                    .trim(from: 0, to: session.progress)
                    .stroke(AngularGradient(colors: [theme.accent.opacity(0.6), theme.accent, .white],
                                            center: .center),
                            style: StrokeStyle(lineWidth: 26, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .shadow(color: theme.accent, radius: 12)
                    .padding(22)

                // goal at the top of the ring, waiting
                TimelineView(.animation) { tl in
                    let t = tl.date.timeIntervalSinceReferenceDate
                    Text(theme.goal)
                        .font(.system(size: 44))
                        .scaleEffect(1 + 0.08 * sin(t * 4))
                }
                .offset(y: -radius)

                // hero zooming around the ring
                TimelineView(.animation) { tl in
                    let t = tl.date.timeIntervalSinceReferenceDate
                    Text(theme.hero)
                        .font(.system(size: 50))
                        .rotationEffect(.degrees(sin(t * 8) * 10))
                        .scaleEffect(1 + 0.06 * sin(t * 10))
                        .shadow(color: theme.accent, radius: 10)
                }
                .offset(x: cos(angle.radians) * radius, y: sin(angle.radians) * radius)

                VStack(spacing: 0) {
                    Text(timeString)
                        .cartoonText(64)
                        .monospacedDigit()
                        .contentTransition(.numericText(countsDown: true))
                        .animation(.default, value: Int(session.remaining))
                    Text("\(Int(session.progress * 100))%")
                        .cartoonText(20, color: theme.accent)
                }
            }
            .frame(width: size, height: size)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
    }

    private var timeString: String {
        let s = Int(ceil(session.remaining))
        return String(format: "%d:%02d", s / 60, s % 60)
    }
}

// MARK: - Mouth map showing where to brush

struct MouthMap: View {
    let zone: BrushZone
    let theme: Theme

    private let teethPerArch = 10

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            let rx = w * 0.42, ry = h * 0.36
            let topCenter = CGPoint(x: w / 2, y: h * 0.47)
            let bottomCenter = CGPoint(x: w / 2, y: h * 0.53)

            ZStack {
                // lips / mouth
                Capsule()
                    .fill(Color(hex: 0x7A1F3D).opacity(0.85))
                    .overlay(Capsule().stroke(Color(hex: 0xFF8FAB), lineWidth: 6))

                if zone == .bottomInside {
                    Text("👅").font(.system(size: 46)).position(x: w / 2, y: h * 0.62)
                }

                ForEach(0..<teethPerArch, id: \.self) { i in
                    tooth(isTop: true, index: i)
                        .position(point(i, center: topCenter, rx: rx, ry: ry, top: true))
                    tooth(isTop: false, index: i)
                        .position(point(i, center: bottomCenter, rx: rx, ry: ry, top: false))
                }

                // the toothbrush scrubs back and forth over the active spot
                TimelineView(.animation) { tl in
                    let t = tl.date.timeIntervalSinceReferenceDate
                    Text("🪥")
                        .font(.system(size: 52))
                        .rotationEffect(.degrees(zone.isTop ? 200 : -20))
                        .offset(x: sin(t * 14) * 14, y: cos(t * 7) * 3)
                }
                .position(brushPoint(w: w, h: h, topCenter: topCenter, bottomCenter: bottomCenter, rx: rx, ry: ry))
                .animation(.spring(response: 0.6, dampingFraction: 0.6), value: zone)
            }
        }
    }

    private func isActive(top: Bool, index: Int) -> Bool {
        guard zone.isTop == top else { return false }
        guard let section = zone.section else { return true }   // inside: whole arch
        switch section {
        case .left: return index <= 2
        case .front: return (3...6).contains(index)
        case .right: return index >= 7
        }
    }

    @ViewBuilder
    private func tooth(isTop: Bool, index: Int) -> some View {
        let active = isActive(top: isTop, index: index)
        let inside = active && zone.section == nil
        TimelineView(.animation(minimumInterval: 1 / 30, paused: !active)) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(active ? theme.accent : .white)
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(inside ? Color.white : Color.black.opacity(0.15), style: StrokeStyle(lineWidth: inside ? 3 : 1, dash: inside ? [4, 3] : []))
                )
                .frame(width: 24, height: 28)
                .shadow(color: active ? theme.accent : .clear, radius: active ? 10 : 0)
                .scaleEffect(active ? 1.12 + 0.06 * sin(t * 9 + Double(index)) : 1)
        }
        .frame(width: 30, height: 34)
    }

    private func angle(_ i: Int, top: Bool) -> Double {
        let f = Double(i) / Double(teethPerArch - 1)
        // top arch is an upside-down U, bottom arch a U
        return top ? (.pi * (1.1 + 0.8 * f)) : (.pi * (0.9 - 0.8 * f))
    }

    private func point(_ i: Int, center: CGPoint, rx: CGFloat, ry: CGFloat, top: Bool) -> CGPoint {
        let a = angle(i, top: top)
        return CGPoint(x: center.x + cos(a) * rx, y: center.y + sin(a) * ry)
    }

    private func brushPoint(w: CGFloat, h: CGFloat, topCenter: CGPoint, bottomCenter: CGPoint, rx: CGFloat, ry: CGFloat) -> CGPoint {
        let index: Int
        switch zone.section {
        case .left: index = 1
        case .right: index = 8
        case .front, .none: index = 4
        }
        let center = zone.isTop ? topCenter : bottomCenter
        var p = point(index, center: center, rx: rx, ry: ry, top: zone.isTop)
        if zone.section == .front || zone.section == nil { p.x += w * 0.04 }
        // sit just outside the teeth (or inside, for the "inside" zones)
        let push: CGFloat = zone.section == nil ? -34 : 30
        p.y += zone.isTop ? -push : push
        return p
    }
}

// MARK: - Eight stars, one per zone

struct ZoneStars: View {
    let current: BrushZone
    let theme: Theme

    var body: some View {
        HStack(spacing: 8) {
            ForEach(BrushZone.allCases) { z in
                ZStack {
                    Circle()
                        .fill(z == current ? theme.accent.opacity(0.4) : .white.opacity(0.15))
                        .overlay(Circle().stroke(z == current ? theme.accent : .white.opacity(0.4), lineWidth: 2))
                    if z.rawValue < current.rawValue {
                        Text("⭐️").font(.system(size: 22))
                            .transition(.scale(scale: 3).combined(with: .opacity))
                    }
                }
                .frame(width: 34, height: 34)
                .scaleEffect(z == current ? 1.2 : 1)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.45), value: current)
    }
}
