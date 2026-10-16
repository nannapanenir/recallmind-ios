import Foundation
import Observation

/// AUTH 07 form state, validation and the password update.
@MainActor
@Observable
final class ResetPasswordViewModel {
    let context: PasswordResetContext

    // Fields re-assign their unchanged text when they lose focus; only a real edit clears an error.
    var newPassword = "" {
        didSet {
            guard newPassword != oldValue else { return }
            newPasswordError = nil
            // A mismatch reported against the old password no longer applies.
            confirmPasswordError = nil
        }
    }
    var confirmPassword = "" {
        didSet {
            if confirmPassword != oldValue { confirmPasswordError = nil }
        }
    }
    var isNewPasswordVisible = false
    var isConfirmPasswordVisible = false

    private(set) var newPasswordError: AuthFieldError?
    private(set) var confirmPasswordError: AuthFieldError?
    private(set) var banner: AuthBanner?
    private(set) var isSubmitting = false

    private let repository: any AuthRepository

    init(context: PasswordResetContext, repository: any AuthRepository) {
        self.context = context
        self.repository = repository
    }

    /// Update Password stays disabled until both fields have content.
    var canSubmit: Bool {
        !newPassword.isEmpty && !confirmPassword.isEmpty && !isSubmitting
    }

    /// Drives the "At least 8 characters" hint check.
    var meetsPasswordLength: Bool {
        newPassword.count >= AuthValidation.minimumPasswordLength
    }

    // Blur validation: called when a field loses focus, never while typing. Empty fields are not flagged.

    func validateNewPassword() {
        guard !newPassword.isEmpty else { return }
        newPasswordError = meetsPasswordLength ? nil : .passwordTooShort
    }

    func validateConfirmPassword() {
        guard !confirmPassword.isEmpty else { return }
        confirmPasswordError = confirmPassword == newPassword ? nil : .passwordsDontMatch
    }

    /// Returns the signed-in user for AUTH 07B, or `nil` when the user stays on AUTH 07.
    func updatePassword() async -> User? {
        guard canSubmit else { return nil }
        validateNewPassword()
        validateConfirmPassword()
        guard newPasswordError == nil, confirmPasswordError == nil else { return nil }

        banner = nil
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            return try await repository.resetPassword(to: newPassword, context: context)
        } catch {
            banner = AuthBanner(error: error)
            return nil
        }
    }
}
