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
}
