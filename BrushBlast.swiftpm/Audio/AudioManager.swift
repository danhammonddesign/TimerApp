import AVFoundation
import UIKit

/// Plays narrator lines, sound effects and background music.
/// Music automatically gets quieter while the narrator talks ("ducking").
@MainActor
final class AudioManager: NSObject, AVAudioPlayerDelegate {
    static let shared = AudioManager()

    enum SFX: String, CaseIterable {
        case tap = "sfx_tap", chime = "sfx_chime", sparkle = "sfx_sparkle"
        case beep = "sfx_beep", beepFinal = "sfx_beep_final", whoosh = "sfx_whoosh"
        case boom = "sfx_boom", rattle = "sfx_rattle", pop = "sfx_pop"
        case fanfare = "sfx_fanfare", star = "sfx_star"
    }

    var voiceEnabled = true
    var musicEnabled = true

    private var sfxPlayers: [SFX: [AVAudioPlayer]] = [:]
    private var musicPlayer: AVAudioPlayer?
    private var voicePlayer: AVAudioPlayer?
    private var voiceQueue: [(name: String, queuedAt: Date)] = []
    private let musicVolume: Float = 0.45
    private let duckedVolume: Float = 0.12

    private override init() {
        super.init()
        for sfx in SFX.allCases {
            // a few copies of each effect so rapid repeats can overlap
            sfxPlayers[sfx] = (0..<3).compactMap { _ in makePlayer(sfx.rawValue, ext: "wav") }
        }
    }

    func configureSession() {
        // .playback = still makes sound when the ring/silent switch is on (important in the bathroom!)
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.duckOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    // MARK: Sound effects

    func play(_ sfx: SFX, volume: Float = 1) {
        guard let players = sfxPlayers[sfx], !players.isEmpty else { return }
        let player = players.first { !$0.isPlaying } ?? players[0]
        player.volume = volume
        player.currentTime = 0
        player.play()
    }

    // MARK: Narrator

    /// Queue a narrator line, e.g. say(theme: "space", line: "top_front").
    /// If something is already being said, it waits its turn; stale lines are dropped.
    func say(theme: String, line: String) {
        guard voiceEnabled else { return }
        voiceQueue.append((name: "voice_\(theme)_\(line)", queuedAt: Date()))
        if voicePlayer?.isPlaying != true { playNextVoice() }
    }

    /// Say this line right now, cutting off anything else.
    func sayNow(theme: String, line: String) {
        guard voiceEnabled else { return }
        voiceQueue.removeAll()
        voicePlayer?.stop()
        voiceQueue.append((name: "voice_\(theme)_\(line)", queuedAt: Date()))
        playNextVoice()
    }

    var isSpeaking: Bool { voicePlayer?.isPlaying == true }

    private func playNextVoice() {
        // skip anything that has been waiting too long (it would be out of sync with the timer)
        voiceQueue.removeAll { Date().timeIntervalSince($0.queuedAt) > 6 }
        guard !voiceQueue.isEmpty else {
            musicPlayer?.setVolume(musicVolume, fadeDuration: 0.4)
            return
        }
        let next = voiceQueue.removeFirst()
        guard let player = makePlayer(next.name, ext: "m4a") else { playNextVoice(); return }
        player.delegate = self
        voicePlayer = player
        musicPlayer?.setVolume(duckedVolume, fadeDuration: 0.2)
        player.play()
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            guard player === self.voicePlayer else { return }
            self.playNextVoice()
        }
    }

    func stopVoice() {
        voiceQueue.removeAll()
        voicePlayer?.stop()
        voicePlayer = nil
    }

    // MARK: Music

    func startMusic(theme: String) {
        stopMusic()
        guard musicEnabled, let player = makePlayer("music_\(theme)", ext: "wav") else { return }
        player.numberOfLoops = -1
        player.volume = 0
        player.play()
        player.setVolume(isSpeaking ? duckedVolume : musicVolume, fadeDuration: 1.0)
        musicPlayer = player
    }

    func stopMusic(fade: TimeInterval = 0) {
        guard let player = musicPlayer else { return }
        musicPlayer = nil
        if fade > 0 {
            player.setVolume(0, fadeDuration: fade)
            DispatchQueue.main.asyncAfter(deadline: .now() + fade) { player.stop() }
        } else {
            player.stop()
        }
    }

    func pauseMusic() { musicPlayer?.pause() }
    func resumeMusic() { musicPlayer?.play() }

    func stopAll() {
        stopVoice()
        stopMusic()
    }

    // MARK: Loading

    private func makePlayer(_ name: String, ext: String) -> AVAudioPlayer? {
        guard let url = Self.url(name, ext: ext) else {
            print("⚠️ Missing audio file \(name).\(ext)")
            return nil
        }
        let player = try? AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
        return player
    }

    private static func url(_ name: String, ext: String) -> URL? {
        Bundle.module.url(forResource: name, withExtension: ext)
            ?? Bundle.module.url(forResource: name, withExtension: ext, subdirectory: "Audio")
            ?? Bundle.main.url(forResource: name, withExtension: ext)
    }
}

/// Little buzzes in the hand that make every moment feel more physical.
enum Haptics {
    @MainActor static func tap() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    @MainActor static func bump() { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
    @MainActor static func boom() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred(intensity: 1)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
