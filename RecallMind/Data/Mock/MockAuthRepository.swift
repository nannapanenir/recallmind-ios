import Foundation

struct MockAuthRepository: AuthRepository {
    /// A reset link with this token is treated as expired (Debug launch argument `-RMResetPasswordPreview expired`).
    static let expiredResetToken = "expired"

    private let user: User?
    private let error: (any Error)?
    private let signInUser: User?
    private let signInError: (any Error)?
    private let signUpError: (any Error)?
    private let resendError: (any Error)?
    private let isEmailVerified: Bool
    private let verificationError: (any Error)?
    private let passwordResetError: (any Error)?
    private let resetPasswordError: (any Error)?
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
        passwordResetError: (any Error)? = nil,
        resetPasswordError: (any Error)? = nil,
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
        self.passwordResetError = passwordResetError
        self.resetPasswordError = resetPasswordError
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

    /// Succeeds for any email unless `passwordResetError` is set; no email is sent.
    func requestPasswordReset(email: String) async throws {
        try await Task.sleep(for: latency)
        if let passwordResetError {
            throw passwordResetError
        }
    }

    /// Succeeds unless `resetPasswordError` is set or the link uses `expiredResetToken`.
    func resetPassword(to newPassword: String, context: PasswordResetContext) async throws -> User {
        try await Task.sleep(for: latency)
        if context.token == Self.expiredResetToken {
            throw AuthError.resetLinkExpired
        }
        if let resetPasswordError {
            throw resetPasswordError
        }
        return signInUser ?? User(id: UUID(), email: context.email)
    }
}
