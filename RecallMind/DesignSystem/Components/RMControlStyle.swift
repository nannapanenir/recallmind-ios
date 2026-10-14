import SwiftUI

/// Shared metrics for buttons (DS 06) and fields (DS 07).
enum RMControlMetrics {
    static let height: CGFloat = 54
    static let minTouchTarget: CGFloat = 44
    static let borderWidth: CGFloat = 1
    /// Focus, error and selection borders.
    static let emphasisBorderWidth: CGFloat = 1.5
}

/// DS 06 pressed state: 85% opacity.
struct RMPressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}
