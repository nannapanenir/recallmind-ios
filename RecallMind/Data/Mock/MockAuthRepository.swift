import Foundation

struct MockAuthRepository: AuthRepository {
    private let user: User?
    private let error: (any Error)?
    private let signInUser: User?
    private let signInError: (any Error)?
    private let signUpError: (any Error)?
    private let resendError: (any Error)?
    private let isEmailVerified: Bool
    private let verificationError: (any Error)?
    private let latency: Duration

    /// Defaults to no active session and successful operations, each after ~400 ms.
    /// Verification checks report the email as verified unless `isEmailVerified` is false.
    init(
        user: User? = nil,
        error: (any Error)? = nil,
        signInUser: User? = nil,
        signInError: (any Error)? = nil,
        signUpError: (any Error)? = nil,
        resendError: (any Error)? = nil,
        isEmailVerified: Bool = true,
        verificationError: (any Error)? = nil,
        latency: Duration = .milliseconds(400)
    ) {
        self.user = user
        self.error = error
        self.signInUser = signInUser
        self.signInError = signInError
        self.signUpError = signUpError
        self.resendError = resendError
        self.isEmailVerified = isEmailVerified
        self.verificationError = verificationError
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

    /// Succeeds unless `resendError` is set; no email is sent.
    func resendVerificationEmail(to email: String) async throws {
        try await Task.sleep(for: latency)
        if let resendError {
            throw resendError
        }
    }

    func checkEmailVerification(email: String) async throws -> User? {
        try await Task.sleep(for: latency)
        if let verificationError {
            throw verificationError
        }
        return isEmailVerified ? (signInUser ?? User(id: UUID(), email: email)) : nil
    }
}
