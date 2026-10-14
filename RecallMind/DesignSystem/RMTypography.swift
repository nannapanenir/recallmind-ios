import SwiftUI

/// Design System v22 type scale, set in Inter and scaled with Dynamic Type.
///
/// Inter font files must be bundled and registered (UIAppFonts) in Xcode.
/// If they are missing, `Font.custom` silently falls back to the system font.
/// See MAC_XCODE_SETUP.md.
enum RMTypography {
    static let display = Font.custom(InterFace.bold, size: 30, relativeTo: .largeTitle)
    static let titleLarge = Font.custom(InterFace.bold, size: 28, relativeTo: .title)
    static let title = Font.custom(InterFace.semibold, size: 20, relativeTo: .title3)
    static let headline = Font.custom(InterFace.semibold, size: 17, relativeTo: .headline)
    static let body = Font.custom(InterFace.regular, size: 15, relativeTo: .body)
    static let bodyEmphasis = Font.custom(InterFace.semibold, size: 15, relativeTo: .body)
    static let callout = Font.custom(InterFace.medium, size: 13, relativeTo: .callout)
    static let caption = Font.custom(InterFace.regular, size: 12, relativeTo: .caption)
    static let overline = Font.custom(InterFace.semibold, size: 11, relativeTo: .caption2)
}

/// Inter PostScript names. Verify against the bundled font files.
enum InterFace {
    static let regular = "Inter-Regular"
    static let medium = "Inter-Medium"
    static let semibold = "Inter-SemiBold"
    static let bold = "Inter-Bold"
}
