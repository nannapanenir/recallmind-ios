import AuthenticationServices
import SwiftUI

/// AUTH 01 — Welcome. Presentation only; the owner decides what each action does.
struct WelcomeView: View {
    let onContinueWithApple: () -> Void
    let onContinueWithEmail: () -> Void
    let onShowTerms: () -> Void
    let onShowPrivacy: () -> Void

    @ScaledMetric(relativeTo: .headline) private var emailIconSize: CGFloat = 20

    var body: some View {
        // Scrolls only when large Dynamic Type sizes no longer fit the screen.
        ViewThatFits(in: .vertical) {
            content
            ScrollView { content }
        }
        .background(RMColors.background.ignoresSafeArea())
    }

    private var content: some View {
        VStack(spacing: 0) {
            brandLockup
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, RMSpacing.xxxl)

            VStack(spacing: RMSpacing.sm) {
                AppleIDButton(action: onContinueWithApple)
                    .frame(height: Layout.buttonHeight)

                Button(action: onContinueWithEmail) {
                    HStack(spacing: RMSpacing.xs) {
                        Image(systemName: "envelope")
                            .font(.system(size: emailIconSize))
                            .accessibilityHidden(true)
                        Text("Continue with Email")
                            .font(RMTypography.headline)
                    }
                    .foregroundStyle(RMColors.textPrimary)
                    .padding(.horizontal, RMSpacing.md)
                    .padding(.vertical, RMSpacing.sm)
                    .frame(maxWidth: .infinity, minHeight: Layout.buttonHeight)
                    .background(RMColors.surface, in: buttonShape)
                    .overlay(buttonShape.strokeBorder(RMColors.border, lineWidth: 1))
                    .contentShape(buttonShape)
                }
                .buttonStyle(PressedOpacityButtonStyle())
            }

            legalFooter
                .padding(.top, RMSpacing.lg)
                .padding(.horizontal, RMSpacing.xs)
        }
        .padding(.horizontal, RMSpacing.readingInset)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var buttonShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: RMRadius.md, style: .continuous)
    }

    private var brandLockup: some View {
        VStack(spacing: RMSpacing.xl) {
            RMBrandMark()

            VStack(spacing: RMSpacing.xs) {
                (Text("Recall").foregroundStyle(RMColors.textPrimary)
                    + Text("Mind").foregroundStyle(RMColors.gold))
                    .font(WelcomeTypography.wordmark)
                    .tracking(WelcomeTypography.wordmarkTracking)
                    .accessibilityAddTraits(.isHeader)

                Text("Listen. Learn. Remember.")
                    .font(WelcomeTypography.tagline)
                    .foregroundStyle(RMColors.textSecondary)
            }
            .multilineTextAlignment(.center)
        }
    }

    private var legalFooter: some View {
        VStack(spacing: 0) {
            Text("By continuing, you agree to our")
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 0) { legalLinks }
                VStack(spacing: 0) { legalLinks }
            }
        }
        .font(RMTypography.caption)
        .foregroundStyle(RMColors.textSecondary)
        .multilineTextAlignment(.center)
    }

    @ViewBuilder
    private var legalLinks: some View {
        LegalLinkButton(title: "Terms of Service", action: onShowTerms)
        Text(" and ")
        HStack(spacing: 0) {
            LegalLinkButton(title: "Privacy Policy", action: onShowPrivacy)
            Text(".")
        }
    }
}

/// AUTH 01 layout value with no spacing token (DS 06 Buttons: 54 pt).
private enum Layout {
    static let buttonHeight: CGFloat = 54
}

/// Welcome-only brand lockup type (DS 01 Brand): wordmark 34 Bold, tagline 16 Medium.
private enum WelcomeTypography {
    static let wordmark = Font.custom(InterFace.bold, size: 34, relativeTo: .largeTitle)
    static let wordmarkTracking: CGFloat = -0.34
    static let tagline = Font.custom(InterFace.medium, size: 16, relativeTo: .callout)
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
        .buttonStyle(PressedOpacityButtonStyle())
        .accessibilityAddTraits(.isLink)
    }
}

private struct PressedOpacityButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

/// Apple's native "Continue with Apple" button. Tapping only calls `action`;
/// no authorization request is made here.
private struct AppleIDButton: UIViewRepresentable {
    let action: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(authorizationButtonType: .continue, authorizationButtonStyle: .white)
        button.cornerRadius = RMRadius.md
        button.addTarget(context.coordinator, action: #selector(Coordinator.didTap), for: .touchUpInside)
        return button
    }

    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        context.coordinator.action = action
    }

    @MainActor
    final class Coordinator: NSObject {
        var action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
        }

        @objc func didTap() {
            action()
        }
    }
}

#Preview {
    WelcomeView(
        onContinueWithApple: {},
        onContinueWithEmail: {},
        onShowTerms: {},
        onShowPrivacy: {}
    )
    .preferredColorScheme(.dark)
}
