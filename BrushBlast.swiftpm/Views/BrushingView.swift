import SwiftUI

@MainActor
struct BrushingView: View {
    let theme: Theme
    var onFinish: () -> Void
    var onQuit: () -> Void

    @EnvironmentObject var settings: AppSettings
    @StateObject private var session: BrushSession
    @ObservedObject private var audio = AudioManager.shared
    @State private var showPause = false

    init(theme: Theme, duration: TimeInterval, onFinish: @escaping () -> Void, onQuit: @escaping () -> Void) {
        self.theme = theme
        self.onFinish = onFinish
        self.onQuit = onQuit
        _session = StateObject(wrappedValue: BrushSession(theme: theme, duration: duration))
    }

    var body: some View {
        ZStack {
            FlatBackground(theme: theme, speed: 1.3)

            VStack(spacing: 12) {
                topBar
                zoneBubble
                TimerRing(session: session, theme: theme, talking: audio.isSpeaking)
                    .frame(maxWidth: 340, maxHeight: 340)
                    .padding(.bottom, 26)      // room for the time pill hanging off the bottom
                    .layoutPriority(1)
                Spacer(minLength: 0)
                MouthMap(zone: session.zone, theme: theme)
                    .frame(height: 118)
                Button("Pause") {
                    AudioManager.shared.play(.tap)
                    session.pause()
                    withAnimation(.spring(response: 0.35)) { showPause = true }
                }
                .buttonStyle(OutlineButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)

            // little celebration each time a zone is finished
            ConfettiView(trigger: session.zoneCelebration, colors: [theme.primary, theme.primaryLight, .white],
                         style: .small, origin: CGPoint(x: 0.5, y: 0.35))
                .ignoresSafeArea()
                .allowsHitTesting(false)

            if let n = session.countdown {
                Text("\(n)")
                    .chunkyText(200, color: theme.primary, lip: theme.primaryLip)
                    .id(n)
                    .transition(.asymmetric(insertion: .scale(scale: 2.2).combined(with: .opacity),
                                            removal: .scale(scale: 0.4).combined(with: .opacity)))
                    .allowsHitTesting(false)
            }

            if showPause { pauseSheet }
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
        HStack(spacing: 12) {
            IconButton(symbol: "xmark") {
                AudioManager.shared.play(.tap)
                session.pause()
                withAnimation(.spring(response: 0.35)) { showPause = true }
            }
            ZoneSegments(current: session.zone, zoneProgress: session.zoneProgress, theme: theme)
        }
        .padding(.top, 6)
    }

    private var zoneBubble: some View {
        ZStack {
            SpeechBubble(text: session.zone.title, symbol: session.zone.symbol, accent: theme.primary, size: 26)
                .id(session.zone)
                .transition(.asymmetric(insertion: .scale(scale: 0.3, anchor: .bottom).combined(with: .opacity),
                                        removal: .opacity))
        }
        .frame(height: 84)
        .animation(.spring(response: 0.45, dampingFraction: 0.55), value: session.zone)
    }

    private var pauseSheet: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.55).ignoresSafeArea()
            VStack(spacing: 16) {
                HStack(spacing: 14) {
                    Mascot(costume: theme.costume, mood: .wow, size: 90)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Wait, don't stop now!")
                            .chunkyText(24)
                        Text("Your teeth are \(Int(session.progress * 100))% sparkly.")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(Palette.muted)
                    }
                    Spacer(minLength: 0)
                }
                Button("Keep brushing") {
                    AudioManager.shared.play(.tap)
                    withAnimation(.spring(response: 0.35)) { showPause = false }
                    session.resume()
                }
                .buttonStyle(ChunkyButtonStyle(fill: theme.primary, lip: theme.primaryLip, text: theme.buttonText))
                Button("End session") {
                    AudioManager.shared.play(.tap)
                    session.stop()
                    onQuit()
                }
                .buttonStyle(ChunkyButtonStyle(fill: Palette.red, lip: Palette.redLip))
            }
            .padding(20)
            .padding(.bottom, 10)
            .background(
                UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28, style: .continuous)
                    .fill(Palette.card)
                    .ignoresSafeArea()
            )
            .transition(.move(edge: .bottom))
        }
        .transition(.opacity)
    }
}

// MARK: - The big countdown ring with Chompy inside

/// A thick ring that empties clockwise as time runs out, Chompy standing in the
/// middle, and a big time pill hanging off the bottom. Turns red for the last 10 seconds.
struct TimerRing: View {
    @ObservedObject var session: BrushSession
    let theme: Theme
    var talking: Bool

    var body: some View {
        GeometryReader { geo in
            let d = min(geo.size.width, geo.size.height)
            let line = d * 0.085
            let remaining = 1 - session.progress
            let hurry = session.remaining <= 10
            let color = hurry ? Palette.red : theme.primary
            let lip = hurry ? Palette.redLip : theme.primaryLip
            let r = (d - line) / 2
            let end = Angle.degrees(-90 + remaining * 360)

            ZStack {
                // face of the clock
                Circle()
                    .fill(Color.black.opacity(0.28))
                    .padding(line * 0.5)

                // empty track
                Circle()
                    .stroke(Palette.border, lineWidth: line)
                    .padding(line / 2)

                // zone notches: 8 little dots on the track
                ForEach(0..<8, id: \.self) { i in
                    let a = Angle.degrees(-90 + Double(i) * 45)
                    Circle()
                        .fill(Color.white.opacity(0.35))
                        .frame(width: line * 0.28, height: line * 0.28)
                        .offset(x: cos(a.radians) * r, y: sin(a.radians) * r)
                }

                // time left: darker edge underneath, then the bright arc, then a shine line
                arc(remaining).stroke(lip, style: StrokeStyle(lineWidth: line, lineCap: .round))
                    .padding(line / 2)
                    .offset(y: line * 0.14)
                arc(remaining).stroke(color, style: StrokeStyle(lineWidth: line, lineCap: .round))
                    .padding(line / 2)
                arc(remaining).stroke(Color.white.opacity(0.35), style: StrokeStyle(lineWidth: line * 0.18, lineCap: .round))
                    .padding(line * 0.24)

                // knob at the end of the arc
                Circle()
                    .fill(Color.white)
                    .overlay(Circle().stroke(color, lineWidth: line * 0.18))
                    .frame(width: line * 0.9, height: line * 0.9)
                    .offset(x: cos(end.radians) * r, y: sin(end.radians) * r)
                    .opacity(remaining > 0.01 ? 1 : 0)

                // Chompy in the middle
                Mascot(costume: theme.costume,
                       mood: session.countdown != nil ? .wow : .happy,
                       talking: talking,
                       look: session.zone.look,
                       brushing: true,
                       size: d * 0.5)
                    .offset(y: -d * 0.03)

                // big, easy-to-read time pill
                TimePill(seconds: Int(ceil(session.remaining)), color: hurry ? Palette.red : Palette.ink, size: d * 0.13)
                    .offset(y: d / 2 + d * 0.01)
                    // grown-ups: long-press the time to jump to the end and test the finale
                    .onLongPressGesture(minimumDuration: 1.5) { session.skipToEnd() }
            }
            .frame(width: d, height: d)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
            .animation(.linear(duration: 0.1), value: session.progress)
            .animation(.easeInOut(duration: 0.4), value: hurry)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    /// Arc starting at 12 o'clock, going clockwise for `fraction` of the circle.
    private func arc(_ fraction: Double) -> some Shape {
        Circle()
            .trim(from: 0, to: max(0, min(1, fraction)))
            .rotation(.degrees(-90))
    }
}

/// White pill with big minutes:seconds.
struct TimePill: View {
    var seconds: Int
    var color: Color
    var size: CGFloat

    var body: some View {
        let shape = Capsule()
        Text(String(format: "%d:%02d", seconds / 60, seconds % 60))
            .font(.system(size: size, weight: .heavy, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(color)
            .contentTransition(.numericText(countsDown: true))
            .animation(.snappy, value: seconds)
            .padding(.horizontal, size * 0.55)
            .padding(.vertical, size * 0.12)
            .background(shape.fill(Color.white).overlay(shape.stroke(Palette.bubbleBorder, lineWidth: 3)))
            .background(shape.fill(Palette.bubbleBorder).offset(y: 5))
    }
}

// MARK: - Mouth map showing where to brush

struct MouthMap: View {
    let zone: BrushZone
    let theme: Theme

    private var teethPerArch: Int { 8 }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            let rx = w * 0.38, ry = h * 0.30
            let topCenter = CGPoint(x: w / 2, y: h * 0.47)
            let bottomCenter = CGPoint(x: w / 2, y: h * 0.53)

            ZStack {
                // card
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.black.opacity(0.25))
                    .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.12), lineWidth: 2.5))

                // mouth
                Capsule()
                    .fill(Color(hex: 0x8C1D33))
                    .overlay(Capsule().stroke(Color(hex: 0xFF8FAB), lineWidth: 8))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 16)

                if zone == .bottomInside {
                    Ellipse().fill(Palette.tongue).frame(width: 70, height: 40).position(x: w / 2, y: h * 0.62)
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
                    FlatToothbrush(handle: theme.primary)
                        .frame(width: 18, height: 70)
                        .rotationEffect(.degrees(zone.isTop ? 70 : 110))
                        .offset(x: sin(t * 14) * 12, y: cos(t * 7) * 3)
                }
                .frame(width: 80, height: 80)
                .position(brushPoint(w: w, topCenter: topCenter, bottomCenter: bottomCenter, rx: rx, ry: ry))
                .animation(.spring(response: 0.6, dampingFraction: 0.6), value: zone)
            }
        }
    }

    private func isActive(top: Bool, index: Int) -> Bool {
        guard zone.isTop == top else { return false }
        guard let section = zone.section else { return true }   // inside: whole arch
        switch section {
        case .left: return index <= 1
        case .front: return (2...5).contains(index)
        case .right: return index >= 6
        }
    }

    private func tooth(isTop: Bool, index: Int) -> some View {
        let active = isActive(top: isTop, index: index)
        let inside = active && zone.section == nil
        return TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: !active)) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(active ? theme.primaryLip : Palette.toothShade)
                    .offset(y: 3)
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(active ? theme.primary : Color.white)
                if inside {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 2.5, dash: [4, 3]))
                }
            }
            .frame(width: 26, height: 26)
            .scaleEffect(active ? 1.1 + 0.05 * sin(t * 9 + Double(index)) : 1)
        }
        .frame(width: 32, height: 32)
    }

    private func angle(_ i: Int, top: Bool) -> Double {
        let f = Double(i) / Double(teethPerArch - 1)
        // top arch is an upside-down U, bottom arch a U
        return top ? (.pi * (1.14 + 0.72 * f)) : (.pi * (0.86 - 0.72 * f))
    }

    private func point(_ i: Int, center: CGPoint, rx: CGFloat, ry: CGFloat, top: Bool) -> CGPoint {
        let a = angle(i, top: top)
        return CGPoint(x: center.x + cos(a) * rx, y: center.y + sin(a) * ry)
    }

    private func brushPoint(w: CGFloat, topCenter: CGPoint, bottomCenter: CGPoint, rx: CGFloat, ry: CGFloat) -> CGPoint {
        let index: Int
        switch zone.section {
        case .left: index = 1
        case .right: index = 6
        case .front, .none: index = 3
        }
        let center = zone.isTop ? topCenter : bottomCenter
        var p = point(index, center: center, rx: rx, ry: ry, top: zone.isTop)
        if zone.section == .front || zone.section == nil { p.x += w * 0.04 }
        // sit just outside the teeth (or inside, for the "inside" zones)
        let push: CGFloat = zone.section == nil ? -30 : 26
        p.y += zone.isTop ? -push : push
        return p
    }
}

// MARK: - Eight segments, one per zone

struct ZoneSegments: View {
    let current: BrushZone
    let zoneProgress: Double
    let theme: Theme

    var body: some View {
        HStack(spacing: 6) {
            ForEach(BrushZone.allCases) { z in
                GeometryReader { g in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Palette.border)
                        if z.rawValue < current.rawValue {
                            Capsule().fill(theme.primary)
                        } else if z == current {
                            Capsule().fill(theme.primary)
                                .frame(width: max(g.size.height, g.size.width * zoneProgress))
                        }
                    }
                }
                .frame(height: 12)
            }
        }
        .animation(.linear(duration: 0.1), value: zoneProgress)
    }
}
