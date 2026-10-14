import SwiftUI

/// DS 06 text button: no icon, 44 pt tall hit area.
/// `.gold` is 15 Semibold gold; `.secondary` is a lower-emphasis action in secondary text.
struct RMTextButton: View {
    enum Style {
        case gold
        case secondary
    }

    private let title: String
    private let style: Style
    private let action: () -> Void

    init(_ title: String, style: Style = .gold, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(style == .gold ? RMTypography.bodyEmphasis : RMTypography.body)
                .foregroundStyle(style == .gold ? RMColors.gold : RMColors.textSecondary)
                .frame(minHeight: RMControlMetrics.minTouchTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(RMPressableButtonStyle())
    }
}

#Preview {
    VStack(spacing: RMSpacing.sm) {
        RMTextButton("Back to Sign In") {}
        RMTextButton("Use a different email", style: .secondary) {}
    }
    .padding(RMSpacing.readingInset)
    .background(RMColors.background)
    .preferredColorScheme(.dark)
}
