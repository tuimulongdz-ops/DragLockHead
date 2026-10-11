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

    static let accents: [(String, String)] = [
        ("CYBER", "00d4ff"),
        ("MATRIX", "00ff41"),
        ("BLOOD", "ff0033"),
        ("GOLD", "ffcc00"),
        ("ICE", "00ffff"),
        ("NEON", "ff00ff"),
        ("SUNSET", "ff6b00"),
        ("TOXIC", "aaff00"),
        ("VOID", "a855f7"),
        ("RETRO", "ff00aa"),
        ("OCEAN", "1e90ff"),
        ("FOREST", "22c55e")
    ]
}

extension Color {
    init(hex: String) {
        let c = hex.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted
        )
        var i: UInt64 = 0
        Scanner(string: c).scanHexInt64(&i)
        let a, r, g, b: UInt64
        switch c.count {
        case 3:
            (a, r, g, b) = (
                255,
                (i >> 8) * 17,
                (i >> 4 & 0xF) * 17,
                (i & 0xF) * 17
            )
        case 6:
            (a, r, g, b) = (
                255,
                i >> 16,
                i >> 8 & 0xFF,
                i & 0xFF
            )
        case 8:
            (a, r, g, b) = (
                i >> 24,
                i >> 16 & 0xFF,
                i >> 8 & 0xFF,
                i & 0xFF
            )
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
