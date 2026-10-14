protocol AuthRepository: Sendable {
    /// Returns the signed-in user for a persisted session, or `nil` when there is none.
    func restoreSession() async throws -> User?

    /// Signs in with email and password.
    /// Throws `AuthError.invalidCredentials` for both an unknown email and a wrong password.
    func signIn(email: String, password: String) async throws -> User
}
