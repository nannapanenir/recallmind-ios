import SwiftUI

/// Legal consent line (AUTH 01, AUTH 03): caption text followed by gold underlined
/// Terms of Service and Privacy Policy links.
struct RMLegalFooter: View {
    private let lead: LocalizedStringKey
    private let onShowTerms: () -> Void
    private let onShowPrivacy: () -> Void

    init(_ lead: LocalizedStringKey, onShowTerms: @escaping () -> Void, onShowPrivacy: @escaping () -> Void) {
        self.lead = lead
        self.onShowTerms = onShowTerms
        self.onShowPrivacy = onShowPrivacy
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(lead)
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 0) { links }
                VStack(spacing: 0) { links }
            }
        }
        .font(RMTypography.caption)
        .foregroundStyle(RMColors.textSecondary)
        .multilineTextAlignment(.center)
    }

    @ViewBuilder
    private var links: some View {
        LegalLinkButton(title: "Terms of Service", action: onShowTerms)
        Text(" and ")
        HStack(spacing: 0) {
            LegalLinkButton(title: "Privacy Policy", action: onShowPrivacy)
            Text(".")
        }
    }
}

/// Gold underlined text link with a 44 pt hit area that does not change line layout.
private struct LegalLinkButton: View {
    let title: String
    let action: () -> Void

    private let hitSlop: CGFloat = 13

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(RMTypography.caption)
                .underline()
                .foregroundStyle(RMColors.gold)
                .padding(.vertical, hitSlop)
                .contentShape(Rectangle())
                .padding(.vertical, -hitSlop)
        }
        .buttonStyle(RMPressableButtonStyle())
        .accessibilityAddTraits(.isLink)
    }
}

#Preview {
    RMLegalFooter("By creating an account, you agree to our", onShowTerms: {}, onShowPrivacy: {})
        .padding(RMSpacing.readingInset)
        .background(RMColors.background)
        .preferredColorScheme(.dark)
}
