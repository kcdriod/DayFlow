import SwiftUI

enum TaskCategory: String, Codable, CaseIterable, Identifiable {
    case work, health, personal, other

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .work:     return .catWork
        case .health:   return .catHealth
        case .personal: return .catPersonal
        case .other:    return .catOther
        }
    }

    var label: String { rawValue.capitalized }

    var icon: String {
        switch self {
        case .work:     return "💼"
        case .health:   return "💪"
        case .personal: return "👤"
        case .other:    return "🎯"
        }
    }
}
