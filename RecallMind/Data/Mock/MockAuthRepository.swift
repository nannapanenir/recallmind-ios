import Foundation

struct MockAuthRepository: AuthRepository {
    private let user: User?
    private let error: (any Error)?
    private let signInUser: User?
    private let signInError: (any Error)?
    private let signUpError: (any Error)?
    private let latency: Duration

    /// Defaults to no active session and successful operations, each after ~400 ms.
    init(
        user: User? = nil,
        error: (any Error)? = nil,
        signInUser: User? = nil,
        signInError: (any Error)? = nil,
        signUpError: (any Error)? = nil,
        latency: Duration = .milliseconds(400)
    ) {
        self.user = user
        self.error = error
        self.signInUser = signInUser
        self.signInError = signInError
        self.signUpError = signUpError
        self.latency = latency
    }

    func restoreSession() async throws -> User? {
        try await Task.sleep(for: latency)
        if let error {
            throw error
        }
        return user
    }

    /// Succeeds for any credentials unless `signInError` is set.
    func signIn(email: String, password: String) async throws -> User {
        try await Task.sleep(for: latency)
        if let signInError {
            throw signInError
        }
        return signInUser ?? User(id: UUID(), email: email)
    }

    /// Succeeds for any email unless `signUpError` is set; no email is sent.
    func signUp(email: String, password: String) async throws {
        try await Task.sleep(for: latency)
        if let signUpError {
            throw signUpError
        }
    }
}
