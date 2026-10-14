import SwiftUI

/// DS 06 primary button: gold fill; border fill when disabled; spinner and label while loading.
struct RMPrimaryButton: View {
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
        let isActive = isEnabled || isLoading
        let shape = RoundedRectangle(cornerRadius: RMRadius.md, style: .continuous)

        Button(action: action) {
            HStack(spacing: RMSpacing.xs) {
                if isLoading {
                    ProgressView()
                        .tint(RMColors.background)
                        .accessibilityHidden(true)
                }
                Text(isLoading ? (loadingTitle ?? title) : title)
                    .font(RMTypography.headline)
            }
            .foregroundStyle(isActive ? RMColors.background : RMColors.textSecondary)
            .padding(.horizontal, RMSpacing.md)
            .padding(.vertical, RMSpacing.sm)
            .frame(maxWidth: .infinity, minHeight: RMControlMetrics.height)
            .background(isActive ? RMColors.gold : RMColors.border, in: shape)
            .contentShape(shape)
        }
        .buttonStyle(RMPressableButtonStyle())
        .disabled(isLoading)
    }
}

#Preview {
    VStack(spacing: RMSpacing.sm) {
        RMPrimaryButton("Sign In") {}
        RMPrimaryButton("Sign In", loadingTitle: "Signing you in…", isLoading: true) {}
        RMPrimaryButton("Sign In") {}.disabled(true)
    }
    .padding(RMSpacing.readingInset)
    .background(RMColors.background)
    .preferredColorScheme(.dark)
}
