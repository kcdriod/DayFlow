import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 1, 1, 1)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }

    static let coral       = Color(hex: "#e8806a")
    static let coralDeep   = Color(hex: "#c45f49")
    static let surface1    = Color(hex: "#1c1c1e")
    static let surface2    = Color(hex: "#2c2c2e")
    static let surface3    = Color(hex: "#3a3a3c")
    static let textPrimary = Color.white
    static let textSec     = Color(white: 1, opacity: 0.80)
    static let textTert    = Color(white: 1, opacity: 0.50)
    static let textQuart   = Color(white: 1, opacity: 0.25)
    static let catWork     = Color(hex: "#0a84ff")
    static let catHealth   = Color(hex: "#30d158")
    static let catPersonal = Color(hex: "#bf5af2")
    static let catOther    = Color(hex: "#e8806a")
}
