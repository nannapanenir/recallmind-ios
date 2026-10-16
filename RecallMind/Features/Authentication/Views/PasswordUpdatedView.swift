import SwiftUI

/// AUTH 07B — Password Updated. No back button: the reset link is spent.
struct PasswordUpdatedView: View {
    let onContinue: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    message
                        .frame(maxHeight: .infinity)
                        .padding(.vertical, RMSpacing.xl)

                    RMPrimaryButton("Continue to RecallMind", action: onContinue)
                }
                .padding(.horizontal, RMSpacing.readingInset)
                .padding(.bottom, RMSpacing.xs)
                .frame(minHeight: proxy.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(RMColors.background.ignoresSafeArea())
        .navigationBarBackButtonHidden()
        .toolbarBackground(RMColors.background, for: .navigationBar)
    }

    private var message: some View {
        VStack(spacing: RMSpacing.md) {
            RMHeroIcon(systemImage: "checkmark", style: .success)

            Text("Password updated")
                .font(RMTypography.titleLarge)
                .foregroundStyle(RMColors.textPrimary)
                .accessibilityAddTraits(.isHeader)
                .padding(.top, RMSpacing.xxs)

            Text("Your password has been changed successfully.")
                .font(RMTypography.body)
                .foregroundStyle(RMColors.textSecondary)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        PasswordUpdatedView(onContinue: {})
    }
    .preferredColorScheme(.dark)
}
