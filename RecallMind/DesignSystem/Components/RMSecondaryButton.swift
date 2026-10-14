import SwiftUI

/// DS 06 secondary button: surface fill, hairline border, primary text.
/// Disabled (e.g. a countdown) and loading use secondary text; loading shows a spinner and label.
struct RMSecondaryButton: View {
    private let title: String
    private let loadingTitle: String?
    private let isLoading: Bool
    private let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    init(_ title: String, loadingTitle: String? = nil, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.loadingTitle = loadingTitle
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: RMRadius.md, style: .continuous)

        Button(action: action) {
            HStack(spacing: RMSpacing.xs) {
                if isLoading {
                    ProgressView()
                        .tint(RMColors.textSecondary)
                        .accessibilityHidden(true)
                }
                Text(isLoading ? (loadingTitle ?? title) : title)
                    .font(RMTypography.headline)
            }
            .foregroundStyle(isEnabled && !isLoading ? RMColors.textPrimary : RMColors.textSecondary)
            .padding(.horizontal, RMSpacing.md)
            .padding(.vertical, RMSpacing.sm)
            .frame(maxWidth: .infinity, minHeight: RMControlMetrics.height)
            .background(RMColors.surface, in: shape)
            .overlay(shape.strokeBorder(RMColors.border, lineWidth: RMControlMetrics.borderWidth))
            .contentShape(shape)
        }
        .buttonStyle(RMPressableButtonStyle())
        .disabled(isLoading)
    }
}

#Preview {
    VStack(spacing: RMSpacing.sm) {
        RMSecondaryButton("Resend Email") {}
        RMSecondaryButton("Resend Email", loadingTitle: "Sending email…", isLoading: true) {}
        RMSecondaryButton("Resend available in 30s") {}.disabled(true)
    }
    .padding(RMSpacing.readingInset)
    .background(RMColors.background)
    .preferredColorScheme(.dark)
}
