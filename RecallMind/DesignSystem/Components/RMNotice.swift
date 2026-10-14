import SwiftUI

/// DS 10 notice (warning / info): hairline border, gold symbol, title and optional message.
/// Red is reserved for errors; use `RMErrorBanner` for those.
struct RMNotice: View {
    private let systemImage: String
    private let title: String
    private let message: String?

    @ScaledMetric(relativeTo: .body) private var iconSize: CGFloat = 18

    init(systemImage: String, title: String, message: String? = nil) {
        self.systemImage = systemImage
        self.title = title
        self.message = message
    }

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: RMRadius.md, style: .continuous)

        HStack(alignment: .top, spacing: RMSpacing.xs) {
            Image(systemName: systemImage)
                .font(.system(size: iconSize))
                .foregroundStyle(RMColors.gold)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: RMSpacing.xxs) {
                Text(title)
                    .font(RMTypography.bodyEmphasis)
                    .foregroundStyle(RMColors.textPrimary)
                if let message {
                    Text(message)
                        .font(RMTypography.callout)
                        .foregroundStyle(RMColors.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(RMSpacing.sm)
        .background(RMColors.surface, in: shape)
        .overlay(shape.strokeBorder(RMColors.border, lineWidth: RMControlMetrics.borderWidth))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    RMNotice(
        systemImage: "envelope",
        title: "We couldn’t confirm your email yet.",
        message: "Open the link in your email, then try again."
    )
    .padding(RMSpacing.readingInset)
    .background(RMColors.background)
    .preferredColorScheme(.dark)
}
