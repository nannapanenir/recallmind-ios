import SwiftUI

/// Root of the signed-out flow. Owns the routing decisions for the auth screens.
struct AuthenticationFlowView: View {
    private enum Route: Hashable {
        case emailSignIn
    }

    @Environment(AppState.self) private var appState
    @Environment(\.appEnvironment) private var environment
    @State private var path: [Route] = []

    var body: some View {
        NavigationStack(path: $path) {
            WelcomeView(
                onContinueWithApple: {
                    // Pending: Sign in with Apple authorization is not implemented yet.
                },
                onContinueWithEmail: {
                    path.append(.emailSignIn)
                },
                onShowTerms: {
                    // Pending: Terms of Service destination not defined yet.
                },
                onShowPrivacy: {
                    // Pending: Privacy Policy destination not defined yet.
                }
            )
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .emailSignIn:
                    emailSignIn
                }
            }
        }
        // Back chevron color on pushed auth screens.
        .tint(RMColors.textPrimary)
    }

    private var emailSignIn: some View {
        EmailSignInView(
            viewModel: EmailSignInViewModel(repository: environment.authRepository),
            onSignedIn: { user in
                appState.completeSignIn(with: user)
            },
            onRequiresEmailVerification: { _ in
                // Pending AUTH 04 — Verify Email.
            },
            onForgotPassword: {
                // Pending AUTH 05 — Forgot Password.
            },
            onCreateAccount: {
                // Pending AUTH 03 — Create Account.
            }
        )
    }
}

#Preview {
    AuthenticationFlowView()
        .environment(AppState())
        .preferredColorScheme(.dark)
}
