import Foundation
import Observation

/// AUTH 02 form state, validation and submission.
@MainActor
@Observable
final class EmailSignInViewModel {
    enum Outcome: Equatable {
        case signedIn(User)
        /// Pending AUTH 04 — Verify Email.
        case requiresEmailVerification(email: String)
    }

    enum FieldError: Equatable {
        case invalidEmail

        var message: String {
            switch self {
            case .invalidEmail: "Enter a valid email address."
            }
        }
    }

    /// AUTH 08 messages shown inline above the Sign In button.
    typealias Banner = AuthBanner

    var email = "" {
        // TextField re-assigns the unchanged text when it loses focus; only a real edit clears the error.
        didSet {
            if email != oldValue { emailError = nil }
        }
    }
    var password = ""
    var isPasswordVisible = false

    private(set) var emailError: FieldError?
    private(set) var banner: Banner?
    private(set) var isSubmitting = false

    private let repository: any AuthRepository

    init(repository: any AuthRepository) {
        self.repository = repository
    }

    /// Sign In stays disabled until both required fields have content.
    var canSubmit: Bool {
        !trimmedEmail.isEmpty && !password.isEmpty && !isSubmitting
    }

    /// Called when the email field loses focus. Never called while typing.
    func validateEmail() {
        guard !trimmedEmail.isEmpty else { return }
        emailError = Self.isValidEmail(trimmedEmail) ? nil : .invalidEmail
    }

    /// Returns an outcome for the flow to route, or `nil` when the user stays on AUTH 02.
    func signIn() async -> Outcome? {
        guard canSubmit else { return nil }
        guard Self.isValidEmail(trimmedEmail) else {
            emailError = .invalidEmail
            return nil
        }

        let email = trimmedEmail
        banner = nil
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            let user = try await repository.signIn(email: email, password: password)
            return .signedIn(user)
        } catch AuthError.emailNotVerified {
            return .requiresEmailVerification(email: email)
        } catch AuthError.invalidCredentials {
            banner = .incorrectCredentials
        } catch AuthError.tooManyAttempts {
            banner = .tooManyAttempts
        } catch AuthError.network {
            banner = .unableToConnect
        } catch is CancellationError {
            // The screen went away; nothing to show.
        } catch {
            banner = .unexpectedError
        }
        return nil
    }

    private var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func isValidEmail(_ email: String) -> Bool {
        AuthValidation.isValidEmail(email)
    }
}
