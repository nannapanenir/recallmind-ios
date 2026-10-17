import Foundation
import Observation

/// AUTH 03 form state, validation and submission.
@MainActor
@Observable
final class CreateAccountViewModel {
    enum Outcome: Equatable {
        /// Every successful sign-up continues to AUTH 04, registered email or not (AUTH 08).
        case verificationRequired(email: String)
    }

    typealias FieldError = AuthFieldError

    // Fields re-assign their unchanged text when they lose focus; only a real edit clears an error.
    var email = "" {
        didSet {
            if email != oldValue { emailError = nil }
        }
    }
    var password = "" {
        didSet {
            guard password != oldValue else { return }
            passwordError = nil
            // A mismatch reported against the old password no longer applies.
            confirmPasswordError = nil
        }
    }
    var confirmPassword = "" {
        didSet {
            if confirmPassword != oldValue { confirmPasswordError = nil }
        }
    }
    var isPasswordVisible = false
    var isConfirmPasswordVisible = false

    private(set) var emailError: FieldError?
    private(set) var passwordError: FieldError?
    private(set) var confirmPasswordError: FieldError?
    private(set) var banner: AuthBanner?
    private(set) var isSubmitting = false

    private let repository: any AuthRepository

    init(repository: any AuthRepository) {
        self.repository = repository
    }

    /// Create Account stays disabled until all three fields have content.
    var canSubmit: Bool {
        !trimmedEmail.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && !isSubmitting
    }

    /// Drives the "At least 8 characters" hint check.
    var meetsPasswordLength: Bool {
        password.count >= AuthValidation.minimumPasswordLength
    }

    // Blur validation: called when a field loses focus, never while typing. Empty fields are not flagged.

    func validateEmail() {
        guard !trimmedEmail.isEmpty else { return }
        emailError = AuthValidation.isValidEmail(trimmedEmail) ? nil : .invalidEmail
    }

    func validatePassword() {
        guard !password.isEmpty else { return }
        passwordError = meetsPasswordLength ? nil : .passwordTooShort
    }

    func validateConfirmPassword() {
        guard !confirmPassword.isEmpty else { return }
        confirmPasswordError = confirmPassword == password ? nil : .passwordsDontMatch
    }

    /// Returns an outcome for the flow to route, or `nil` when the user stays on AUTH 03.
    func createAccount() async -> Outcome? {
        guard canSubmit else { return nil }
        validateEmail()
        validatePassword()
        validateConfirmPassword()
        guard emailError == nil, passwordError == nil, confirmPasswordError == nil else { return nil }

        let email = trimmedEmail
        banner = nil
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            try await repository.signUp(email: email, password: password)
            return .verificationRequired(email: email)
        } catch {
            banner = AuthBanner(error: error)
            return nil
        }
    }

    private var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
