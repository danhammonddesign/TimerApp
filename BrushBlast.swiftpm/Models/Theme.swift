import SwiftUI

/// A visual + audio theme kids can pick. Art is all emoji, so there are no image assets to manage.
struct Theme: Identifiable, Equatable {
    let id: String              // matches audio file names: voice_<id>_*.m4a, music_<id>.wav
    let name: String
    let tagline: String
    let hero: String            // travels around the timer ring
    let goal: String            // what the hero is heading to
    let floaters: [String]      // drift around the background
    let colors: [Color]         // background gradient (top -> bottom)
    let accent: Color
    let finaleTitle: String
    let stickers: [Sticker]

    static func == (lhs: Theme, rhs: Theme) -> Bool { lhs.id == rhs.id }

    static let all: [Theme] = [space, ocean, dino, rainbow, robot]

    static func named(_ id: String) -> Theme { all.first { $0.id == id } ?? space }

    static let space = Theme(
        id: "space", name: "Rocket Brush", tagline: "Blast off to a new planet!",
        hero: "🚀", goal: "🪐", floaters: ["⭐️", "✨", "🌟", "☄️", "💫"],
        colors: [Color(hex: 0x0B0B2B), Color(hex: 0x2B1055), Color(hex: 0x7597DE)],
        accent: Color(hex: 0x7CF5FF), finaleTitle: "MISSION COMPLETE!",
        stickers: Sticker.set("space", [
            ("🌙", "Moon Buddy", .common), ("⭐️", "Super Star", .common), ("☄️", "Comet Zoom", .common),
            ("🛸", "Flying Saucer", .rare), ("👽", "Alien Pal", .rare), ("🌌", "Galaxy Swirl", .legendary),
        ])
    )

    static let ocean = Theme(
        id: "ocean", name: "Ocean Dive", tagline: "Swim to the hidden treasure!",
        hero: "🐠", goal: "🏝️", floaters: ["🫧", "🫧", "🐟", "🌊", "🐚"],
        colors: [Color(hex: 0x00C6FB), Color(hex: 0x005BEA), Color(hex: 0x021B79)],
        accent: Color(hex: 0xFFE66D), finaleTitle: "TREASURE FOUND!",
        stickers: Sticker.set("ocean", [
            ("🐚", "Shiny Shell", .common), ("🦀", "Snappy Crab", .common), ("🐢", "Turtle Pal", .common),
            ("🐬", "Dolphin Flip", .rare), ("🐙", "Octo Hugs", .rare), ("🐳", "Whale King", .legendary),
        ])
    )

    static let dino = Theme(
        id: "dino", name: "Dino Stomp", tagline: "Make the volcano erupt!",
        hero: "🦖", goal: "🌋", floaters: ["🌿", "🍃", "🦴", "🌴", "🥚"],
        colors: [Color(hex: 0x56AB2F), Color(hex: 0x2F6B1F), Color(hex: 0x3D1F0B)],
        accent: Color(hex: 0xFF7A18), finaleTitle: "KA-BOOM! ROAR!",
        stickers: Sticker.set("dino", [
            ("🥚", "Dino Egg", .common), ("🦴", "Big Bone", .common), ("🌴", "Palm Snack", .common),
            ("🦕", "Long Neck", .rare), ("🦣", "Fuzzy Mammoth", .rare), ("🐉", "Dragon Legend", .legendary),
        ])
    )

    static let rainbow = Theme(
        id: "rainbow", name: "Unicorn Magic", tagline: "Make a magic rainbow appear!",
        hero: "🦄", goal: "🌈", floaters: ["💖", "✨", "🌸", "🦋", "🍭"],
        colors: [Color(hex: 0xFF9A9E), Color(hex: 0xC471F5), Color(hex: 0x6A3093)],
        accent: Color(hex: 0xFFF59D), finaleTitle: "RAINBOW MAGIC!",
        stickers: Sticker.set("rainbow", [
            ("🌸", "Blossom", .common), ("🧁", "Cupcake", .common), ("🍭", "Swirly Pop", .common),
            ("🦋", "Butterfly", .rare), ("👑", "Royal Crown", .rare), ("🦄", "Golden Unicorn", .legendary),
        ])
    )

    static let robot = Theme(
        id: "robot", name: "Robot Power", tagline: "Charge up to 100%!",
        hero: "🤖", goal: "🔋", floaters: ["⚙️", "🔩", "💡", "⚡️", "🛰️"],
        colors: [Color(hex: 0x232526), Color(hex: 0x1D4350), Color(hex: 0x00B4DB)],
        accent: Color(hex: 0x39FF14), finaleTitle: "FULLY CHARGED!",
        stickers: Sticker.set("robot", [
            ("⚙️", "Gear Spin", .common), ("💡", "Bright Idea", .common), ("🔧", "Wrench", .common),
            ("🛰️", "Satellite", .rare), ("🦾", "Robo Arm", .rare), ("👾", "Pixel Legend", .legendary),
        ])
    )
}

enum Rarity: String, Codable {
    case common, rare, legendary

    var label: String {
        switch self {
        case .common: return "Cool"
        case .rare: return "Rare!"
        case .legendary: return "LEGENDARY!!"
        }
    }

    var color: Color {
        switch self {
        case .common: return Color(hex: 0x7CF5FF)
        case .rare: return Color(hex: 0xC77DFF)
        case .legendary: return Color(hex: 0xFFD700)
        }
    }

    /// Chance weight when picking a reward.
    var weight: Int {
        switch self {
        case .common: return 60
        case .rare: return 30
        case .legendary: return 10
        }
    }
}

struct Sticker: Identifiable, Hashable, Codable {
    let id: String
    let emoji: String
    let name: String
    let rarity: Rarity

    static func set(_ theme: String, _ items: [(String, String, Rarity)]) -> [Sticker] {
        items.enumerated().map { i, item in
            Sticker(id: "\(theme)-\(i)", emoji: item.0, name: item.1, rarity: item.2)
        }
    }
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: opacity)
    }
}
