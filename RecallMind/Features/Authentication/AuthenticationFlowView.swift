import SwiftUI

/// Root of the signed-out flow. Owns the routing decisions for the auth screens.
struct AuthenticationFlowView: View {
    var body: some View {
        WelcomeView(
            onContinueWithApple: {
                // Pending: Sign in with Apple authorization is not implemented yet.
            },
            onContinueWithEmail: {
                // Pending AUTH 02 — Email Sign In.
            },
            onShowTerms: {
                // Pending: Terms of Service destination not defined yet.
            },
            onShowPrivacy: {
                // Pending: Privacy Policy destination not defined yet.
            }
        )
    }
}

#Preview {
    AuthenticationFlowView()
        .preferredColorScheme(.dark)
}
