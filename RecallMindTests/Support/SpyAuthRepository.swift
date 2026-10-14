import Foundation
@testable import RecallMind

/// Records repository calls and returns the configured results after an optional delay.
@MainActor
final class SpyAuthRepository: AuthRepository {
    /// Sign-in result.
    var result: Result<User, any Error>
    var signUpResult: Result<Void, any Error> = .success(())
    var resendResult: Result<Void, any Error> = .success(())
    var verificationResult: Result<User?, any Error> = .success(nil)

    private(set) var signInEmails: [String] = []
    private(set) var signUpEmails: [String] = []
    private(set) var signUpPasswords: [String] = []
    private(set) var resendEmails: [String] = []
    private(set) var verificationChecks: [String] = []

    private let delay: Duration

    init(result: Result<User, any Error> = .failure(AuthError.invalidCredentials), delay: Duration = .zero) {
        self.result = result
        self.delay = delay
    }

    func restoreSession() async throws -> User? { nil }

    func signIn(email: String, password: String) async throws -> User {
        signInEmails.append(email)
        try await Task.sleep(for: delay)
        return try result.get()
    }

    func signUp(email: String, password: String) async throws {
        signUpEmails.append(email)
        signUpPasswords.append(password)
        try await Task.sleep(for: delay)
        try signUpResult.get()
    }

    func resendVerificationEmail(to email: String) async throws {
        resendEmails.append(email)
        try await Task.sleep(for: delay)
        try resendResult.get()
    }

    func checkEmailVerification(email: String) async throws -> User? {
        verificationChecks.append(email)
        try await Task.sleep(for: delay)
        return try verificationResult.get()
    }
}
