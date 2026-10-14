import Foundation
import Observation

/// AUTH 05 form state, validation and the reset-link request.
@MainActor
@Observable
final class ForgotPasswordViewModel {
    enum Outcome: Equatable {
        /// For AUTH 06 — Check Your Email (not built yet). Returned for every email,
        /// so the result never reveals whether an account exists.
        case resetLinkSent(email: String)
    }

    enum FieldError: Equatable {
        case invalidEmail

        var message: String {
            switch self {
            case .invalidEmail: "Enter a valid email address."
            }
        }
    }

    var email = "" {
        // TextField re-assigns the unchanged text when it loses focus; only a real edit clears the error.
        didSet {
            if email != oldValue { emailError = nil }
        }
    }

    private(set) var emailError: FieldError?
    private(set) var banner: AuthBanner?
    private(set) var isSubmitting = false

    private let repository: any AuthRepository

    init(repository: any AuthRepository) {
        self.repository = repository
    }

    /// Send Reset Link stays disabled until the email has content.
    var canSubmit: Bool {
        !trimmedEmail.isEmpty && !isSubmitting
    }

    /// Called when the email field loses focus. Never called while typing.
    func validateEmail() {
        guard !trimmedEmail.isEmpty else { return }
        emailError = AuthValidation.isValidEmail(trimmedEmail) ? nil : .invalidEmail
    }

    /// Returns an outcome for the flow to route, or `nil` when the user stays on AUTH 05.
    func sendResetLink() async -> Outcome? {
        guard canSubmit else { return nil }
        guard AuthValidation.isValidEmail(trimmedEmail) else {
            emailError = .invalidEmail
            return nil
        }

        let email = trimmedEmail
        banner = nil
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            try await repository.requestPasswordReset(email: email)
            return .resetLinkSent(email: email)
        } catch {
            banner = AuthBanner(error: error)
            return nil
        }
    }

    private var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
