import SwiftUI

/// DS 10 success chip: transient capsule with a green check and text (never colour alone).
struct RMSuccessChip: View {
    private let title: String

    @ScaledMetric(relativeTo: .callout) private var iconSize: CGFloat = 16

    /// DS 10 chip height; no spacing token matches.
    private let minHeight: CGFloat = 36

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        HStack(spacing: RMSpacing.xs) {
            Image(systemName: "checkmark")
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(RMColors.success)
                .accessibilityHidden(true)
            Text(title)
                .font(RMTypography.callout)
                .foregroundStyle(RMColors.textPrimary)
        }
        .padding(.horizontal, RMSpacing.sm)
        .frame(minHeight: minHeight)
        .background(RMColors.surface, in: Capsule())
        .overlay(Capsule().strokeBorder(RMColors.border, lineWidth: RMControlMetrics.borderWidth))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    RMSuccessChip("Email sent")
        .padding(RMSpacing.readingInset)
        .background(RMColors.background)
        .preferredColorScheme(.dark)
}
