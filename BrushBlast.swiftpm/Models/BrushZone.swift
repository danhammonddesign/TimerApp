import Foundation

/// The eight parts of the mouth, brushed in order. Each gets 1/8 of the timer
/// (15 seconds each with the default 2 minutes, as dentists recommend).
enum BrushZone: Int, CaseIterable, Identifiable {
    case topFront, topLeft, topRight, topInside
    case bottomFront, bottomLeft, bottomRight, bottomInside

    var id: Int { rawValue }

    /// Matches the keys in tools/voice_lines.json.
    var voiceKey: String {
        switch self {
        case .topFront: return "top_front"
        case .topLeft: return "top_left"
        case .topRight: return "top_right"
        case .topInside: return "top_inside"
        case .bottomFront: return "bottom_front"
        case .bottomLeft: return "bottom_left"
        case .bottomRight: return "bottom_right"
        case .bottomInside: return "bottom_inside"
        }
    }

    var title: String {
        switch self {
        case .topFront: return "Top Front"
        case .topLeft: return "Top Left Side"
        case .topRight: return "Top Right Side"
        case .topInside: return "Inside Top Teeth"
        case .bottomFront: return "Bottom Front"
        case .bottomLeft: return "Bottom Left Side"
        case .bottomRight: return "Bottom Right Side"
        case .bottomInside: return "Inside Bottom + Tongue"
        }
    }

    var arrow: String {
        switch self {
        case .topFront: return "⬆️"
        case .topLeft: return "↖️"
        case .topRight: return "↗️"
        case .topInside: return "🔄"
        case .bottomFront: return "⬇️"
        case .bottomLeft: return "↙️"
        case .bottomRight: return "↘️"
        case .bottomInside: return "👅"
        }
    }

    var isTop: Bool { rawValue < 4 }

    /// Which third of the arch lights up on the mouth map (nil = the whole arch, for "inside").
    enum Section { case left, front, right }
    var section: Section? {
        switch self {
        case .topFront, .bottomFront: return .front
        case .topLeft, .bottomLeft: return .left
        case .topRight, .bottomRight: return .right
        case .topInside, .bottomInside: return nil
        }
    }
}
