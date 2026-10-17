protocol AuthRepository: Sendable {
    /// Returns the signed-in user for a persisted session, or `nil` when there is none.
    func restoreSession() async throws -> User?

    /// Signs in with email and password.
    /// Throws `AuthError.invalidCredentials` for both an unknown email and a wrong password.
    func signIn(email: String, password: String) async throws -> User

    /// Creates an account and sends a verification email.
    /// Also succeeds for an email that is already registered: the result never reveals
    /// whether an account exists (AUTH 08).
    func signUp(email: String, password: String) async throws

    /// Sends a new verification email to `email`.
    func resendVerificationEmail(to email: String) async throws

    /// Returns the signed-in user once `email` is verified, or `nil` while it is not yet.
    func checkEmailVerification(email: String) async throws -> User?

    /// Sends a password reset link to `email`.
    /// Also succeeds when no account uses the email: the result never reveals whether one exists.
    func requestPasswordReset(email: String) async throws

    /// Sets a new password from a reset link and returns the signed-in user (AUTH 07B continues into the app).
    /// Throws `AuthError.resetLinkExpired` when the link is no longer valid.
    func resetPassword(to newPassword: String, context: PasswordResetContext) async throws -> User
}
