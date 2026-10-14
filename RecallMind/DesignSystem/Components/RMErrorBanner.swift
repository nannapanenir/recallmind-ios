import SwiftUI

/// DS 10 / AUTH 08 error banner: danger border, symbol, title, optional message and gold action.
struct RMErrorBanner: View {
    enum Symbol {
        case error
        case offline

        var systemName: String {
            switch self {
            case .error: "exclamationmark.circle"
            case .offline: "wifi.slash"
            }
        }
    }

    private let symbol: Symbol
    private let title: String
    private let message: String?
    private let actionTitle: String?
    private let action: (() -> Void)?

    @ScaledMetric(relativeTo: .body) private var iconSize: CGFloat = 18

    init(
        symbol: Symbol = .error,
        title: String,
        message: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.symbol = symbol
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: RMRadius.md, style: .continuous)

        HStack(alignment: message == nil ? .center : .top, spacing: RMSpacing.xs) {
            Image(systemName: symbol.systemName)
                .font(.system(size: iconSize))
                .foregroundStyle(RMColors.danger)
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
            .accessibilityElement(children: .combine)

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(RMTypography.bodyEmphasis)
                        .foregroundStyle(RMColors.gold)
                        .padding(.horizontal, RMSpacing.xs)
                        .frame(minHeight: RMControlMetrics.minTouchTarget)
                        .contentShape(Rectangle())
                }
                .buttonStyle(RMPressableButtonStyle())
            }
        }
        .padding(RMSpacing.sm)
        .background(RMColors.surface, in: shape)
        .overlay(shape.strokeBorder(RMColors.danger, lineWidth: RMControlMetrics.borderWidth))
    }
}

#Preview {
    VStack(spacing: RMSpacing.sm) {
        RMErrorBanner(title: "Incorrect email or password.", message: "Check your details and try again.")
        RMErrorBanner(
            symbol: .offline,
            title: "Unable to connect",
            message: "Check your internet connection.",
            actionTitle: "Try Again",
            action: {}
        )
        RMErrorBanner(title: "Too many attempts. Try again later.")
    }
    .padding(RMSpacing.readingInset)
    .background(RMColors.background)
    .preferredColorScheme(.dark)
}
