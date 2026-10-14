import Foundation
import Testing
@testable import RecallMind

@MainActor
struct CreateAccountViewModelTests {
    private struct UnexpectedFailure: Error {}

    private func makeViewModel(
        spy: SpyAuthRepository? = nil,
        email: String = "ram@example.com",
        password: String = "listenlearn",
        confirmPassword: String = "listenlearn"
    ) -> CreateAccountViewModel {
        let viewModel = CreateAccountViewModel(repository: spy ?? SpyAuthRepository())
        viewModel.email = email
        viewModel.password = password
        viewModel.confirmPassword = confirmPassword
        return viewModel
    }

    // MARK: - Enablement

    @Test func createAccountNeedsAllThreeFields() {
        let viewModel = CreateAccountViewModel(repository: SpyAuthRepository())
        #expect(!viewModel.canSubmit)

        viewModel.email = "ram@example.com"
        viewModel.password = "listenlearn"
        #expect(!viewModel.canSubmit)

        viewModel.confirmPassword = "x"
        #expect(viewModel.canSubmit)
    }

    @Test func passwordHintTracksMinimumLength() {
        let viewModel = CreateAccountViewModel(repository: SpyAuthRepository())

        viewModel.password = "1234567"
        #expect(!viewModel.meetsPasswordLength)

        viewModel.password = "12345678"
        #expect(viewModel.meetsPasswordLength)
    }

    // MARK: - Blur validation

    @Test func blurFlagsShortPasswordAndEditingClearsIt() {
        let viewModel = CreateAccountViewModel(repository: SpyAuthRepository())
        viewModel.password = "listen"

        viewModel.validatePassword()
        #expect(viewModel.passwordError == .passwordTooShort)
        #expect(viewModel.passwordError?.message == "Use at least 8 characters.")

        viewModel.password = "listenlearn"
        #expect(viewModel.passwordError == nil)
    }

    @Test func blurFlagsMismatchAndEditingEitherPasswordClearsIt() {
        let viewModel = makeViewModel(confirmPassword: "listenlearm")

        viewModel.validateConfirmPassword()
        #expect(viewModel.confirmPasswordError == .passwordsDontMatch)
        #expect(viewModel.confirmPasswordError?.message == "Passwords don’t match.")

        viewModel.password = "listenlearm"
        #expect(viewModel.confirmPasswordError == nil)
    }

    @Test func blurIgnoresEmptyFields() {
        let viewModel = CreateAccountViewModel(repository: SpyAuthRepository())

        viewModel.validateEmail()
        viewModel.validatePassword()
        viewModel.validateConfirmPassword()

        #expect(viewModel.emailError == nil)
        #expect(viewModel.passwordError == nil)
        #expect(viewModel.confirmPasswordError == nil)
    }

    @Test func reassigningSameValuesKeepsBlurErrors() {
        let viewModel = makeViewModel(email: "ram@example", password: "listen", confirmPassword: "other")
        viewModel.validateEmail()
        viewModel.validatePassword()
        viewModel.validateConfirmPassword()

        // Fields write their unchanged text back when they lose focus.
        viewModel.email = "ram@example"
        viewModel.password = "listen"
        viewModel.confirmPassword = "other"

        #expect(viewModel.emailError == .invalidEmail)
        #expect(viewModel.passwordError == .passwordTooShort)
        #expect(viewModel.confirmPasswordError == .passwordsDontMatch)
    }

    // MARK: - Submit validation

    @Test func invalidFieldsDoNotSubmit() async {
        let spy = SpyAuthRepository()
        let viewModel = makeViewModel(spy: spy, email: "ram@example", password: "listen", confirmPassword: "listen")

        let outcome = await viewModel.createAccount()

        #expect(outcome == nil)
        #expect(viewModel.emailError == .invalidEmail)
        #expect(viewModel.passwordError == .passwordTooShort)
        #expect(spy.signUpEmails.isEmpty)
    }

    @Test func mismatchDoesNotSubmit() async {
        let spy = SpyAuthRepository()
        let viewModel = makeViewModel(spy: spy, confirmPassword: "listenlearm")

        let outcome = await viewModel.createAccount()

        #expect(outcome == nil)
        #expect(viewModel.confirmPasswordError == .passwordsDontMatch)
        #expect(spy.signUpEmails.isEmpty)
    }

    // MARK: - Repository outcomes

    @Test func successContinuesToVerificationWithTrimmedEmail() async {
        let spy = SpyAuthRepository()
        let viewModel = makeViewModel(spy: spy, email: "  ram@example.com \n")

        let outcome = await viewModel.createAccount()

        #expect(outcome == .verificationRequired(email: "ram@example.com"))
        #expect(spy.signUpEmails == ["ram@example.com"])
        #expect(spy.signUpPasswords == ["listenlearn"])
        #expect(!viewModel.isSubmitting)
    }

    @Test func networkErrorShowsUnableToConnect() async {
        let spy = SpyAuthRepository()
        spy.signUpResult = .failure(AuthError.network)
        let viewModel = makeViewModel(spy: spy)

        let outcome = await viewModel.createAccount()

        #expect(outcome == nil)
        #expect(viewModel.banner == .unableToConnect)
    }

    @Test func tooManyAttemptsShowsMessage() async {
        let spy = SpyAuthRepository()
        spy.signUpResult = .failure(AuthError.tooManyAttempts)
        let viewModel = makeViewModel(spy: spy)

        _ = await viewModel.createAccount()

        #expect(viewModel.banner == .tooManyAttempts)
    }

    @Test func unexpectedErrorHasNoApprovedCopy() async {
        let spy = SpyAuthRepository()
        spy.signUpResult = .failure(UnexpectedFailure())
        let viewModel = makeViewModel(spy: spy)

        _ = await viewModel.createAccount()

        #expect(viewModel.banner == .unexpectedError)
        #expect(viewModel.banner?.title == nil)
    }

    @Test func retryClearsBannerOnSuccess() async {
        let spy = SpyAuthRepository()
        spy.signUpResult = .failure(AuthError.network)
        let viewModel = makeViewModel(spy: spy)
        _ = await viewModel.createAccount()

        spy.signUpResult = .success(())
        let outcome = await viewModel.createAccount()

        #expect(outcome == .verificationRequired(email: "ram@example.com"))
        #expect(viewModel.banner == nil)
    }

    @Test func secondSubmitWhileInFlightIsIgnored() async {
        let spy = SpyAuthRepository(delay: .milliseconds(50))
        let viewModel = makeViewModel(spy: spy)

        async let first = viewModel.createAccount()
        async let second = viewModel.createAccount()
        let outcomes = await [first, second]

        #expect(spy.signUpEmails.count == 1)
        #expect(outcomes.compactMap { $0 } == [.verificationRequired(email: "ram@example.com")])
        #expect(!viewModel.isSubmitting)
    }
}
