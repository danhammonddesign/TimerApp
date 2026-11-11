import SwiftUI

/// Remembers the sticker collection and the daily brushing streak (saved on device).
@MainActor
final class RewardStore: ObservableObject {
    @Published private(set) var counts: [String: Int] = [:]    // sticker id -> times won
    @Published private(set) var streak: Int = 0
    @Published private(set) var totalBrushes: Int = 0
    @Published private(set) var lastWasNew = false

    private var lastBrushDay: Date?
    private let defaults = UserDefaults.standard

    init() {
        counts = (defaults.dictionary(forKey: "stickerCounts") as? [String: Int]) ?? [:]
        streak = defaults.integer(forKey: "streak")
        totalBrushes = defaults.integer(forKey: "totalBrushes")
        lastBrushDay = defaults.object(forKey: "lastBrushDay") as? Date
        // A streak only survives if the last brush was today or yesterday.
        if let last = lastBrushDay {
            let cal = Calendar.current
            let days = cal.dateComponents([.day], from: cal.startOfDay(for: last), to: cal.startOfDay(for: Date())).day ?? 0
            if days > 1 { streak = 0 }
        }
    }

    var collectedCount: Int { counts.keys.count }
    var totalStickers: Int { Theme.all.reduce(0) { $0 + $1.stickers.count } }

    func count(of sticker: Sticker) -> Int { counts[sticker.id] ?? 0 }

    /// Picks a weighted-random sticker, preferring ones the kid hasn't found yet.
    func awardSticker(for theme: Theme) -> Sticker {
        let missing = theme.stickers.filter { counts[$0.id] == nil }
        // 70% of the time, if there are missing stickers, choose from those
        let pool = (!missing.isEmpty && Int.random(in: 0..<10) < 7) ? missing : theme.stickers
        let total = pool.reduce(0) { $0 + $1.rarity.weight }
        var roll = Int.random(in: 0..<max(total, 1))
        var chosen = pool[0]
        for s in pool {
            roll -= s.rarity.weight
            if roll < 0 { chosen = s; break }
        }

        lastWasNew = counts[chosen.id] == nil
        counts[chosen.id, default: 0] += 1
        totalBrushes += 1
        bumpStreak()
        save()
        return chosen
    }

    private func bumpStreak() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        if let last = lastBrushDay {
            let days = cal.dateComponents([.day], from: cal.startOfDay(for: last), to: today).day ?? 0
            if days == 1 { streak += 1 } else if days > 1 { streak = 1 } else if streak == 0 { streak = 1 }
        } else {
            streak = 1
        }
        lastBrushDay = Date()
    }

    private func save() {
        defaults.set(counts, forKey: "stickerCounts")
        defaults.set(streak, forKey: "streak")
        defaults.set(totalBrushes, forKey: "totalBrushes")
        defaults.set(lastBrushDay, forKey: "lastBrushDay")
    }
}

/// Things chosen on the home screen, remembered between launches.
@MainActor
final class AppSettings: ObservableObject {
    private let defaults = UserDefaults.standard

    @Published var theme: Theme { didSet { defaults.set(theme.id, forKey: "themeID") } }
    @Published var duration: Double { didSet { defaults.set(duration, forKey: "durationSeconds") } }
    @Published var musicOn: Bool { didSet { defaults.set(musicOn, forKey: "musicOn") } }
    @Published var voiceOn: Bool { didSet { defaults.set(voiceOn, forKey: "voiceOn") } }

    init() {
        theme = Theme.named(defaults.string(forKey: "themeID") ?? Theme.space.id)
        let saved = defaults.double(forKey: "durationSeconds")
        duration = [30, 60, 90].contains(saved) ? saved : 60
        musicOn = defaults.object(forKey: "musicOn") as? Bool ?? true
        voiceOn = defaults.object(forKey: "voiceOn") as? Bool ?? true
    }
}
