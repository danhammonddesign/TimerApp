import SwiftUI

/// The timer engine. Tracks time, moves through the eight mouth zones and fires
/// the narrator / sound cues at the right moments.
@MainActor
final class BrushSession: ObservableObject {
    let theme: Theme
    let duration: TimeInterval

    @Published private(set) var elapsed: TimeInterval = 0
    @Published private(set) var zone: BrushZone = .topFront
    @Published private(set) var isPaused = false
    @Published private(set) var isFinished = false
    /// Bumps every time a zone is completed, so views can celebrate.
    @Published private(set) var zoneCelebration = 0
    /// 5...1 during the final countdown, otherwise nil.
    @Published private(set) var countdown: Int?

    var onFinish: (@MainActor () -> Void)?

    private var timer: Timer?
    private var lastTick: Date?
    private var cheeredZones: Set<Int> = []
    private var cheerOrder = ["cheer1", "cheer2", "cheer3"].shuffled()
    private let audio = AudioManager.shared

    init(theme: Theme, duration: TimeInterval) {
        self.theme = theme
        self.duration = duration
    }

    var zoneLength: TimeInterval { duration / Double(BrushZone.allCases.count) }
    var progress: Double { min(elapsed / duration, 1) }
    var remaining: TimeInterval { max(duration - elapsed, 0) }
    /// 0...1 within the current zone.
    var zoneProgress: Double {
        let p = (elapsed - Double(zone.rawValue) * zoneLength) / zoneLength
        return min(max(p, 0), 1)
    }

    func start() {
        audio.startMusic(theme: theme.id)
        audio.play(.whoosh)
        // Short timers: skip the intro and talk a bit faster so each zone's line fits.
        audio.voiceRate = zoneLength < 5 ? 1.3 : (zoneLength < 9 ? 1.1 : 1)
        if zoneLength >= 9 { audio.say(theme: theme.id, line: "intro") }
        audio.say(theme: theme.id, line: zone.voiceKey)
        resume()
    }

    func togglePause() {
        isPaused ? resume() : pause()
    }

    func pause() {
        guard !isPaused, !isFinished else { return }
        isPaused = true
        timer?.invalidate()
        timer = nil
        audio.pauseMusic()
        audio.stopVoice()
    }

    func resume() {
        isPaused = false
        lastTick = Date()
        timer?.invalidate()
        let t = Timer(timeInterval: 1.0 / 20.0, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
        if elapsed > 0 { audio.resumeMusic() }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        audio.voiceRate = 1
        audio.stopAll()
    }

    /// Smooth elapsed time for animations that run every frame (the timer itself only ticks 20x a second).
    func elapsed(at date: Date) -> TimeInterval {
        guard !isPaused, !isFinished, let last = lastTick else { return elapsed }
        return min(elapsed + min(max(date.timeIntervalSince(last), 0), 0.5), duration)
    }

    /// Handy for testing the finale: jump to a few seconds before the end.
    func skipToEnd() {
        elapsed = max(elapsed, duration - 6)
        zone = .bottomInside
    }

    private func tick() {
        guard !isPaused, !isFinished, let last = lastTick else { return }
        let now = Date()
        // cap the step so returning from the background doesn't skip everything at once
        elapsed += min(now.timeIntervalSince(last), 0.5)
        lastTick = now

        // Zone change
        let newZoneIndex = min(Int(elapsed / zoneLength), BrushZone.allCases.count - 1)
        if newZoneIndex != zone.rawValue, let newZone = BrushZone(rawValue: newZoneIndex) {
            zone = newZone
            zoneCelebration += 1
            audio.playQuiet(.zone, volume: 0.3)
            Haptics.bump()
            if zoneLength < 9 {
                audio.sayNow(theme: theme.id, line: newZone.voiceKey)   // never fall behind the timer
            } else {
                audio.say(theme: theme.id, line: newZone.voiceKey)
            }
        }

        // A cheer in the middle of some zones (only if there is time for it)
        let into = elapsed - Double(zone.rawValue) * zoneLength
        if zoneLength >= 10, into > zoneLength * 0.6, zone.rawValue % 2 == 1,
           !cheeredZones.contains(zone.rawValue), !audio.isSpeaking, remaining > 8 {
            cheeredZones.insert(zone.rawValue)
            let line = cheerOrder.removeFirst()
            cheerOrder.append(line)
            audio.say(theme: theme.id, line: line)
        }

        // Final countdown beeps
        let secondsLeft = Int(ceil(remaining))
        if secondsLeft <= 5, secondsLeft >= 1 {
            if countdown != secondsLeft {
                countdown = secondsLeft
                audio.play(.beep)
                Haptics.tap()
            }
        } else if countdown != nil, secondsLeft > 5 {
            countdown = nil
        }

        if elapsed >= duration {
            elapsed = duration
            countdown = nil
            isFinished = true
            timer?.invalidate()
            timer = nil
            audio.play(.beepFinal)
            audio.stopMusic(fade: 0.3)
            audio.stopVoice()
            audio.voiceRate = 1
            onFinish?()
        }
    }
}
