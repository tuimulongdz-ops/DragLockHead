import SwiftUI

struct Theme {
    static let sea1 = Color(hex: "0099ff")
    static let sea2 = Color(hex: "00d4ff")
    static let red1 = Color(hex: "ff0033")
    static let dark1 = Color(hex: "06080d")
    static let dark2 = Color(hex: "0d1117")
    static let dark3 = Color(hex: "1a1f2b")
    static let smoke = Color(hex: "6b7280")
    static let smoke2 = Color(hex: "9ca3af")
    static let green = Color(hex: "22c55e")
    static let yellow = Color(hex: "fbbf24")
    static let purple = Color(hex: "a855f7")
    static let cyan = Color(hex: "00ffff")
}

extension Color {
    init(hex: String) {
        let clean = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: clean).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch clean.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

struct GradientButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
