import SwiftUI

/// DS 06 pill button for actions inside banners and cards: gold capsule, 44 pt tall,
/// label in the background colour. Not a replacement for the full-width primary button.
struct RMPillButton: View {
    private let title: String
    private let action: () -> Void

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(RMTypography.bodyEmphasis)
                .foregroundStyle(RMColors.background)
                .padding(.horizontal, RMSpacing.md)
                .frame(minHeight: RMControlMetrics.minTouchTarget)
                .background(RMColors.gold, in: Capsule())
                .contentShape(Capsule())
        }
        .buttonStyle(RMPressableButtonStyle())
    }
}

#Preview {
    RMPillButton("Send a new link") {}
        .padding(RMSpacing.readingInset)
        .background(RMColors.background)
        .preferredColorScheme(.dark)
}
