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

    /// `.text`: inline gold text action at the trailing edge ("Try Again").
    /// `.pill`: DS 06 pill below the message, aligned with the text ("Send a new link").
    enum ActionStyle {
        case text
        case pill
    }

    private let symbol: Symbol
    private let title: String
    private let message: String?
    private let actionTitle: String?
    private let actionStyle: ActionStyle
    private let action: (() -> Void)?

    @ScaledMetric(relativeTo: .body) private var iconSize: CGFloat = 18

    init(
        symbol: Symbol = .error,
        title: String,
        message: String? = nil,
        actionTitle: String? = nil,
        actionStyle: ActionStyle = .text,
        action: (() -> Void)? = nil
    ) {
        self.symbol = symbol
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.actionStyle = actionStyle
        self.action = action
    }

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: RMRadius.md, style: .continuous)

        VStack(alignment: .leading, spacing: RMSpacing.xs) {
            content

            if actionStyle == .pill, let actionTitle, let action {
                RMPillButton(actionTitle, action: action)
                    .padding(.leading, iconSize + RMSpacing.xs)
            }
        }
        .padding(RMSpacing.sm)
        .background(RMColors.surface, in: shape)
        .overlay(shape.strokeBorder(RMColors.danger, lineWidth: RMControlMetrics.borderWidth))
    }

    private var content: some View {
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

            if actionStyle == .text, let actionTitle, let action {
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
