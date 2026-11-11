import SwiftUI

/// Flat, bold colors used everywhere.
enum Palette {
    static let dark = Color(hex: 0x131F24)
    static let card = Color(hex: 0x202F36)
    static let border = Color(hex: 0x37464F)
    static let muted = Color(hex: 0x8FA3AD)
    static let ink = Color(hex: 0x3C3C3C)
    static let snow = Color(hex: 0xF7F7F7)
    static let bubbleBorder = Color(hex: 0xE2E2E2)
    static let toothShade = Color(hex: 0xD6E2EA)

    static let green = Color(hex: 0x5BCB0C), greenLip = Color(hex: 0x46A005)
    static let blue = Color(hex: 0x1FB2F5), blueLip = Color(hex: 0x1592CC)
    static let yellow = Color(hex: 0xFFCB05), yellowLip = Color(hex: 0xDDA704)
    static let orange = Color(hex: 0xFF9A0A), orangeLip = Color(hex: 0xD97C00)
    static let red = Color(hex: 0xFF5050), redLip = Color(hex: 0xD63636)
    static let pink = Color(hex: 0xFF8AD2), pinkLip = Color(hex: 0xDD62AE)
    static let purple = Color(hex: 0xB876FF), purpleLip = Color(hex: 0x9455D9)

    static let mouth = Color(hex: 0xB8261A)
    static let tongue = Color(hex: 0xFF5A6A)
    static let cheek = Color(hex: 0xFFB3C3)
    static let pupil = Color(hex: 0x2B2B2B)
}

/// The tooth mascot's outfit for each theme.
enum Costume { case helmet, snorkel, dinoHood, unicorn, robot, propeller, sunHat, beret }

/// What the countdown looks like for a theme.
enum TimerStyle { case ring, plinko, sandJar, tiles }

/// A theme kids can pick: colors, mascot costume, narrator (voice files) and stickers.
struct Theme: Identifiable, Equatable {
    let id: String              // matches audio file names: voice_<id>_*.m4a, music_<id>.wav
    let name: String
    let tagline: String
    let costume: Costume
    let bgTop: Color
    let bgBottom: Color
    let primary: Color          // buttons, progress bar, highlights
    let primaryLip: Color       // the darker "3D" edge under buttons
    let primaryLight: Color
    let buttonText: Color
    let shapeColors: [Color]    // flat shapes drifting in the background
    let finaleTitle: String
    let stickers: [Sticker]
    var timer: TimerStyle = .ring

    static func == (lhs: Theme, rhs: Theme) -> Bool { lhs.id == rhs.id }

    static let all: [Theme] = [marble, sand, tiles, space, ocean, dino, rainbow, robot]

    static func named(_ id: String) -> Theme { all.first { $0.id == id } ?? space }

    static let marble = Theme(
        id: "marble", name: "Marble Drop", tagline: "Fill the whole board with marbles!", costume: .propeller,
        bgTop: Color(hex: 0x1B2A4A), bgBottom: Color(hex: 0x0F1830),
        primary: Palette.red, primaryLip: Palette.redLip, primaryLight: Color(hex: 0xFF9A9A), buttonText: .white,
        shapeColors: [Palette.red, Palette.yellow, Palette.blue, Palette.green],
        finaleTitle: "Board full!",
        stickers: Sticker.set("marble", [
            ("🎱", "Eight Ball", .common), ("🎯", "Bullseye", .common), ("🪀", "Yo-yo", .common),
            ("🔮", "Crystal Orb", .rare), ("🧿", "Lucky Eye", .rare), ("💎", "Diamond Marble", .legendary),
        ]),
        timer: .plinko
    )

    static let sand = Theme(
        id: "sand", name: "Sand Art", tagline: "Fill the jar with rainbow sand!", costume: .sunHat,
        bgTop: Color(hex: 0x2A1E4A), bgBottom: Color(hex: 0x160F2C),
        primary: Color(hex: 0x2EC4B6), primaryLip: Color(hex: 0x219E92), primaryLight: Color(hex: 0x8FF0E6), buttonText: .white,
        shapeColors: [Palette.yellow, Palette.pink, Color(hex: 0x2EC4B6), Palette.orange],
        finaleTitle: "Jar full!",
        stickers: Sticker.set("sand", [
            ("⏳", "Hourglass", .common), ("🌵", "Cactus", .common), ("🐪", "Camel", .common),
            ("🐱", "Kitty Jar", .rare), ("🐶", "Puppy Jar", .rare), ("🦈", "Golden Shark", .legendary),
        ]),
        timer: .sandJar
    )

    static let tiles = Theme(
        id: "tiles", name: "Secret Picture", tagline: "Flip the tiles to find a secret pet!", costume: .beret,
        bgTop: Color(hex: 0x0F3B3A), bgBottom: Color(hex: 0x08201F),
        primary: Palette.purple, primaryLip: Palette.purpleLip, primaryLight: Color(hex: 0xD8B4FF), buttonText: .white,
        shapeColors: [Palette.purple, Palette.yellow, Color(hex: 0x2EC4B6)],
        finaleTitle: "Surprise!",
        stickers: Sticker.set("tiles", [
            ("🧩", "Puzzle Piece", .common), ("🖼️", "Picture Frame", .common), ("🃏", "Joker Card", .common),
            ("🐾", "Paw Print", .rare), ("🎀", "Big Bow", .rare), ("🦁", "Lion Cub", .legendary),
        ]),
        timer: .tiles
    )

    static let space = Theme(
        id: "space", name: "Rocket Brush", tagline: "Blast off to a new planet!", costume: .helmet,
        bgTop: Color(hex: 0x131F3A), bgBottom: Color(hex: 0x241650),
        primary: Palette.blue, primaryLip: Palette.blueLip, primaryLight: Color(hex: 0x6FE3FF), buttonText: .white,
        shapeColors: [Palette.yellow, Palette.blue, Palette.purple, .white],
        finaleTitle: "Mission complete!",
        stickers: Sticker.set("space", [
            ("🌙", "Moon Buddy", .common), ("⭐️", "Super Star", .common), ("☄️", "Comet Zoom", .common),
            ("🛸", "Flying Saucer", .rare), ("👽", "Alien Pal", .rare), ("🌌", "Galaxy Swirl", .legendary),
        ])
    )

    static let ocean = Theme(
        id: "ocean", name: "Ocean Dive", tagline: "Swim to the hidden treasure!", costume: .snorkel,
        bgTop: Color(hex: 0x0C6FA8), bgBottom: Color(hex: 0x073A63),
        primary: Palette.yellow, primaryLip: Palette.yellowLip, primaryLight: Color(hex: 0xFFE46B), buttonText: Color(hex: 0x5A3D00),
        shapeColors: [.white, Color(hex: 0x6FE3FF), Palette.yellow],
        finaleTitle: "Treasure found!",
        stickers: Sticker.set("ocean", [
            ("🐚", "Shiny Shell", .common), ("🦀", "Snappy Crab", .common), ("🐢", "Turtle Pal", .common),
            ("🐬", "Dolphin Flip", .rare), ("🐙", "Octo Hugs", .rare), ("🐳", "Whale King", .legendary),
        ])
    )

    static let dino = Theme(
        id: "dino", name: "Dino Stomp", tagline: "Make the volcano erupt!", costume: .dinoHood,
        bgTop: Color(hex: 0x1E3B1A), bgBottom: Color(hex: 0x10230D),
        primary: Palette.green, primaryLip: Palette.greenLip, primaryLight: Color(hex: 0xA6F04A), buttonText: .white,
        shapeColors: [Palette.green, Palette.orange, Color(hex: 0xA6F04A)],
        finaleTitle: "Ka-boom! Roar!",
        stickers: Sticker.set("dino", [
            ("🥚", "Dino Egg", .common), ("🦴", "Big Bone", .common), ("🌴", "Palm Snack", .common),
            ("🦕", "Long Neck", .rare), ("🦣", "Fuzzy Mammoth", .rare), ("🐉", "Dragon Legend", .legendary),
        ])
    )

    static let rainbow = Theme(
        id: "rainbow", name: "Unicorn Magic", tagline: "Make a magic rainbow appear!", costume: .unicorn,
        bgTop: Color(hex: 0x8A4FD8), bgBottom: Color(hex: 0x3A1B6E),
        primary: Palette.pink, primaryLip: Palette.pinkLip, primaryLight: Color(hex: 0xFFC2E8), buttonText: .white,
        shapeColors: [Palette.pink, Palette.yellow, .white, Palette.blue],
        finaleTitle: "Rainbow magic!",
        stickers: Sticker.set("rainbow", [
            ("🌸", "Blossom", .common), ("🧁", "Cupcake", .common), ("🍭", "Swirly Pop", .common),
            ("🦋", "Butterfly", .rare), ("👑", "Royal Crown", .rare), ("🦄", "Golden Unicorn", .legendary),
        ])
    )

    static let robot = Theme(
        id: "robot", name: "Robot Power", tagline: "Charge up to 100%!", costume: .robot,
        bgTop: Color(hex: 0x1C2A31), bgBottom: Color(hex: 0x0E171B),
        primary: Palette.orange, primaryLip: Palette.orangeLip, primaryLight: Color(hex: 0xFFC56B), buttonText: .white,
        shapeColors: [Palette.orange, Palette.border, Palette.blue],
        finaleTitle: "Fully charged!",
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
        case .common: return "Cool find"
        case .rare: return "Rare!"
        case .legendary: return "Legendary!!"
        }
    }

    var color: Color {
        switch self {
        case .common: return Palette.blue
        case .rare: return Palette.purple
        case .legendary: return Palette.yellow
        }
    }

    var lip: Color {
        switch self {
        case .common: return Palette.blueLip
        case .rare: return Palette.purpleLip
        case .legendary: return Palette.yellowLip
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
