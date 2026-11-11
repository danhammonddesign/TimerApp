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
    @State private var pet: Pet = .cat
    @State private var tileSeed = UInt64.random(in: 1...UInt64.max)

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
                timerSection
                Spacer(minLength: 0)
                MouthMap(zone: session.zone, theme: theme)
                    .frame(height: 150)
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
            // a new surprise each time: which pet is hidden / which jar shape
            pet = theme.timer == .sandJar ? Pet.allCases.randomElement()! : [Pet.cat, .dog].randomElement()!
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

    /// Each theme gets its own kind of timer.
    @ViewBuilder
    private var timerSection: some View {
        switch theme.timer {
        case .ring:
            zoneBubble
            TimerRing(session: session, theme: theme, talking: audio.isSpeaking)
                .frame(maxWidth: 340, maxHeight: 340)
                .padding(.bottom, 26)      // room for the time pill hanging off the bottom
                .layoutPriority(1)
        case .plinko:
            sideBubble
            PlinkoBoard(session: session, theme: theme)
                .overlay(alignment: .bottom) { timePill }
                .padding(.bottom, 26)
                .layoutPriority(1)
        case .sandJar:
            sideBubble
            SandJarTimer(session: session, theme: theme, pet: pet)
                .overlay(alignment: .bottom) { timePill }
                .padding(.bottom, 26)
                .layoutPriority(1)
        case .tiles:
            sideBubble
            TileRevealTimer(session: session, theme: theme, pet: pet == .shark ? .cat : pet, seed: tileSeed)
                .overlay(alignment: .bottom) { timePill }
                .padding(.bottom, 26)
                .layoutPriority(1)
        }
    }

    private var timePill: some View {
        TimePill(seconds: Int(ceil(session.remaining)),
                 color: session.remaining <= 10 ? Palette.red : Palette.ink, size: 40)
            .offset(y: 26)
            // grown-ups: long-press the time to jump to the end and test the finale
            .onLongPressGesture(minimumDuration: 1.5) { session.skipToEnd() }
    }

    /// Chompy beside the speech bubble (for timers that need the middle of the screen).
    private var sideBubble: some View {
        HStack(spacing: 6) {
            Mascot(costume: theme.costume,
                   mood: session.countdown != nil ? .wow : .happy,
                   talking: audio.isSpeaking,
                   look: session.zone.look,
                   brushing: true,
                   size: 72)
            ZStack {
                SpeechBubble(text: session.zone.title, symbol: session.zone.symbol, accent: theme.primary,
                             size: 22, tailLeading: true)
                    .id(session.zone)
                    .transition(.asymmetric(insertion: .scale(scale: 0.3, anchor: .leading).combined(with: .opacity),
                                            removal: .opacity))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .animation(.spring(response: 0.45, dampingFraction: 0.55), value: session.zone)
        }
        .frame(height: 86)
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

/// A big open cartoon mouth seen from the front: glossy lips, a row of teeth along
/// the top and bottom, tongue and throat. The teeth to brush light up in the theme color
/// and a toothbrush scrubs over them.
struct MouthMap: View {
    let zone: BrushZone
    let theme: Theme

    private var teethPerRow: Int { 10 }

    // flat mouth colors
    private static let lip = Color(hex: 0xFF6F96)
    private static let lipShade = Color(hex: 0xD94F78)
    private static let inside = Color(hex: 0x9E2342)
    private static let throat = Color(hex: 0x5C0F25)
    private static let tongue = Color(hex: 0xFF8FA8)
    private static let tongueShade = Color(hex: 0xE86F8C)

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            let outerH = h * 0.92
            let outer = CGSize(width: min(w * 0.9, outerH * 1.75), height: outerH)
            let lipThickness = h * 0.11
            let inner = CGSize(width: outer.width - lipThickness * 2, height: outer.height - lipThickness * 2)
            let c = CGPoint(x: w / 2, y: h / 2)
            let layout = TeethLayout(count: teethPerRow, inner: inner)

            ZStack {
                // lips with a chunky darker edge underneath
                Ellipse().fill(Self.lipShade)
                    .frame(width: outer.width, height: outer.height)
                    .position(x: c.x, y: c.y + 5)
                Ellipse().fill(Self.lip)
                    .frame(width: outer.width, height: outer.height)
                    .position(c)

                // inside of the mouth: throat, little dangly uvula, tongue
                ZStack {
                    Ellipse().fill(Self.inside)
                    Ellipse().fill(Self.throat)
                        .frame(width: inner.width * 0.42, height: inner.height * 0.5)
                        .offset(y: -inner.height * 0.02)
                    Capsule().fill(Self.inside)
                        .frame(width: inner.width * 0.035, height: inner.height * 0.2)
                        .offset(y: -inner.height * 0.2)
                    tongueView(inner: inner)
                }
                .frame(width: inner.width, height: inner.height)
                .clipShape(Ellipse())
                .position(c)

                // glossy shine on the lips
                lipShine(at: 238, length: 0.22, opacity: 0.5, center: c, outer: outer, lip: lipThickness)
                lipShine(at: 60, length: 0.14, opacity: 0.35, center: c, outer: outer, lip: lipThickness)

                // teeth
                ForEach(0..<teethPerRow, id: \.self) { i in
                    toothView(top: true, index: i, center: c, inner: inner, layout: layout)
                    toothView(top: false, index: i, center: c, inner: inner, layout: layout)
                }

                // the toothbrush scrubs back and forth over the active spot
                TimelineView(.animation) { tl in
                    let t = tl.date.timeIntervalSinceReferenceDate
                    FlatToothbrush(handle: theme.primary)
                        .frame(width: h * 0.13, height: h * 0.5)
                        .rotationEffect(.degrees(brushTilt))
                        .offset(x: sin(t * 14) * 10, y: cos(t * 7) * 3)
                }
                .frame(width: h * 0.6, height: h * 0.6)
                .position(brushPoint(center: c, inner: inner, layout: layout))
                .animation(.spring(response: 0.6, dampingFraction: 0.6), value: zone)
            }
        }
    }

    // MARK: Pieces

    private func tongueView(inner: CGSize) -> some View {
        let glow = zone == .bottomInside
        return TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: !glow)) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            ZStack {
                Ellipse().fill(Self.tongueShade).offset(y: 4)
                Ellipse().fill(glow ? theme.primaryLight : Self.tongue)
                Capsule().fill(Color.black.opacity(0.08))
                    .frame(width: 3, height: inner.height * 0.18)
                    .offset(y: -inner.height * 0.04)
                Capsule().fill(Color.white.opacity(0.35))
                    .frame(width: inner.width * 0.08, height: inner.height * 0.05)
                    .offset(x: inner.width * 0.1, y: -inner.height * 0.06)
            }
            .frame(width: inner.width * 0.5, height: inner.height * 0.52)
            .scaleEffect(glow ? 1 + 0.03 * sin(t * 8) : 1)
        }
        .offset(y: inner.height * 0.3)
    }

    private func lipShine(at degrees: Double, length: CGFloat, opacity: Double,
                          center: CGPoint, outer: CGSize, lip: CGFloat) -> some View {
        let a = degrees * .pi / 180
        let rx = outer.width / 2 - lip / 2, ry = outer.height / 2 - lip / 2
        let point = CGPoint(x: center.x + cos(a) * rx, y: center.y + sin(a) * ry)
        let tangent = Angle(radians: atan2(cos(a) * ry, -sin(a) * rx))
        return Capsule().fill(Color.white.opacity(opacity))
            .frame(width: outer.width * length, height: lip * 0.3)
            .rotationEffect(tangent)
            .position(point)
    }

    private func isActive(top: Bool, index: Int) -> Bool {
        guard zone.isTop == top else { return false }
        guard let section = zone.section else { return true }   // inside: whole row
        switch section {
        case .left: return index <= 2
        case .front: return (3...6).contains(index)
        case .right: return index >= 7
        }
    }

    private func onEllipse(_ a: Double, center: CGPoint, inner: CGSize, scale: CGFloat) -> CGPoint {
        CGPoint(x: center.x + cos(a) * inner.width / 2 * scale,
                y: center.y + sin(a) * inner.height / 2 * scale)
    }

    private func toothView(top: Bool, index: Int, center: CGPoint, inner: CGSize, layout: TeethLayout) -> some View {
        let a = top ? layout.topAngles[index] : layout.bottomAngles[index]
        let active = isActive(top: top, index: index)
        let inside = active && zone.section == nil
        // turn each tooth so its root points out toward the lips
        let nx = cos(a) / (inner.width / 2), ny = sin(a) / (inner.height / 2)
        let rotation = Angle(radians: atan2(ny, nx) + .pi / 2)
        let front = (3...6).contains(index)
        let size = CGSize(width: layout.toothWidth, height: layout.toothWidth * (front ? 1.2 : 1.0))
        let corner = size.width * 0.3

        return TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: !active)) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            ZStack {
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(active ? theme.primaryLip : Palette.toothShade)
                    .offset(y: 3)
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(active ? theme.primary : Color.white)
                if inside {
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 2, dash: [3, 3]))
                }
            }
            .frame(width: size.width, height: size.height)
            .scaleEffect(active ? 1.08 + 0.05 * sin(t * 9 + Double(index)) : 1)
        }
        .rotationEffect(rotation)
        .position(onEllipse(a, center: center, inner: inner, scale: TeethLayout.ring))
    }

    private var brushTilt: Double {
        switch zone.section {
        case .left: return zone.isTop ? 45 : 135
        case .right: return zone.isTop ? -45 : -135
        default: return 90
        }
    }

    private func brushPoint(center: CGPoint, inner: CGSize, layout: TeethLayout) -> CGPoint {
        let angles = zone.isTop ? layout.topAngles : layout.bottomAngles
        let a: Double
        switch zone.section {
        case .left: a = angles[1]
        case .right: a = angles[angles.count - 2]
        case .front, .none: a = zone.isTop ? -.pi / 2 : .pi / 2
        }
        // outside zones: over the lips; inside zones: in toward the middle of the mouth
        let scale: CGFloat = zone.section == nil ? 0.45 : 1.15
        return onEllipse(a, center: center, inner: inner, scale: scale)
    }
}

/// Spreads the teeth evenly (by distance, not angle) around each half of the mouth.
struct TeethLayout {
    static let ring: CGFloat = 0.84     // how far out from the center the teeth sit

    let topAngles: [Double]
    let bottomAngles: [Double]
    let toothWidth: CGFloat

    init(count: Int, inner: CGSize) {
        let rx = Double(inner.width / 2 * Self.ring), ry = Double(inner.height / 2 * Self.ring)
        let (top, length) = Self.evenAngles(count: count, from: .pi, to: 2 * .pi, rx: rx, ry: ry)
        let (bottom, _) = Self.evenAngles(count: count, from: .pi, to: 0, rx: rx, ry: ry)
        topAngles = top
        bottomAngles = bottom
        toothWidth = CGFloat(length / Double(count)) * 0.9
    }

    private static func evenAngles(count: Int, from a0: Double, to a1: Double, rx: Double, ry: Double) -> ([Double], Double) {
        let steps = 240
        var lengths: [Double] = [0]
        var prev = (x: cos(a0) * rx, y: sin(a0) * ry)
        for s in 1...steps {
            let a = a0 + (a1 - a0) * Double(s) / Double(steps)
            let p = (x: cos(a) * rx, y: sin(a) * ry)
            lengths.append(lengths[lengths.count - 1] + hypot(p.x - prev.x, p.y - prev.y))
            prev = p
        }
        let total = lengths[lengths.count - 1]
        let angles = (0..<count).map { k -> Double in
            let target = total * (Double(k) + 0.5) / Double(count)
            let i = lengths.firstIndex { $0 >= target } ?? steps
            return a0 + (a1 - a0) * Double(i) / Double(steps)
        }
        return (angles, total)
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
