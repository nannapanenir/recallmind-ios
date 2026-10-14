import SwiftUI

/// Design System v22 color tokens. Raw hex values live only in this file.
enum RMColors {
    static let background = Color(hex: 0x060C12)
    static let surface = Color(hex: 0x0C141C)
    static let surfaceRaised = Color(hex: 0x101A24)
    static let border = Color(hex: 0x293847)
    static let textPrimary = Color(hex: 0xF5F7FC)
    static let textSecondary = Color(hex: 0xA1B0C2)
    static let gold = Color(hex: 0xFFB805)
    static let goldTint = Color(hex: 0x2E2405)
    static let danger = Color(hex: 0xF5382E)
    static let success = Color(hex: 0x40D185)
    static let successTint = Color(hex: 0x0E2C1B)
    static let white = Color(hex: 0xFFFFFF)
    static let speakerInfo = Color(hex: 0x7AA8D9)
}

private extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}
