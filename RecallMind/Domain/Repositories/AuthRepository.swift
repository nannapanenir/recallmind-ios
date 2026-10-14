protocol AuthRepository: Sendable {
    /// Returns the signed-in user for a persisted session, or `nil` when there is none.
    func restoreSession() async throws -> User?
}
