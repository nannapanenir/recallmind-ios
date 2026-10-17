/// What a password reset link carries into AUTH 07.
/// Built by the mock / Debug hook until real deep links exist.
struct PasswordResetContext: Hashable, Sendable {
    let email: String
    /// Opaque token from the reset link.
    let token: String
}
