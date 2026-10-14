/// Authentication failures the UI distinguishes.
enum AuthError: Error, Equatable {
    /// Wrong password or no account for the email. Never reveals which.
    case invalidCredentials
    /// The account exists but its email address is not verified yet.
    case emailNotVerified
    /// Sign-in is temporarily blocked after repeated failures.
    case tooManyAttempts
    /// The service could not be reached.
    case network
}
