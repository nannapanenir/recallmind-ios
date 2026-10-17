import Foundation
import Testing
@testable import RecallMind

@MainActor
struct ForgotPasswordViewModelTests {
    private struct UnexpectedFailure: Error {}

    private func makeViewModel(spy: SpyAuthRepository, email: String = "ram@example.com") -> ForgotPasswordViewModel {
        let viewModel = ForgotPasswordViewModel(repository: spy)
        viewModel.email = email
        return viewModel
    }

    @Test func emptyEmailDisablesSubmit() {
        let viewModel = makeViewModel(spy: SpyAuthRepository(), email: "  ")

        #expect(!viewModel.canSubmit)
    }

    @Test func blurFlagsInvalidEmailAndEditingClearsIt() {
        let viewModel = makeViewModel(spy: SpyAuthRepository(), email: "ram@example")

        viewModel.validateEmail()
        #expect(viewModel.emailError == .invalidEmail)
        #expect(viewModel.emailError?.message == "Enter a valid email address.")

        // The field writes its unchanged text back when it loses focus.
        viewModel.email = "ram@example"
        #expect(viewModel.emailError == .invalidEmail)

        viewModel.email = "ram@example.com"
        #expect(viewModel.emailError == nil)
    }

    @Test func invalidEmailDoesNotSubmit() async {
        let spy = SpyAuthRepository()
        let viewModel = makeViewModel(spy: spy, email: "ram@example")

        let outcome = await viewModel.sendResetLink()

        #expect(outcome == nil)
        #expect(viewModel.emailError == .invalidEmail)
        #expect(spy.passwordResetEmails.isEmpty)
    }

    @Test func successReturnsTypedOutcomeWithTrimmedEmail() async {
        let spy = SpyAuthRepository()
        let viewModel = makeViewModel(spy: spy, email: " ram@example.com\n")

        let outcome = await viewModel.sendResetLink()

        #expect(outcome == .resetLinkSent(email: "ram@example.com"))
        #expect(spy.passwordResetEmails == ["ram@example.com"])
        #expect(!viewModel.isSubmitting)
    }

    @Test func networkErrorShowsUnableToConnect() async {
        let spy = SpyAuthRepository()
        spy.passwordResetResult = .failure(AuthError.network)
        let viewModel = makeViewModel(spy: spy)

        let outcome = await viewModel.sendResetLink()

        #expect(outcome == nil)
        #expect(viewModel.banner == .unableToConnect)
    }

    @Test func tooManyAttemptsShowsMessage() async {
        let spy = SpyAuthRepository()
        spy.passwordResetResult = .failure(AuthError.tooManyAttempts)
        let viewModel = makeViewModel(spy: spy)

        _ = await viewModel.sendResetLink()

        #expect(viewModel.banner == .tooManyAttempts)
    }

    @Test func unexpectedErrorHasNoApprovedCopy() async {
        let spy = SpyAuthRepository()
        spy.passwordResetResult = .failure(UnexpectedFailure())
        let viewModel = makeViewModel(spy: spy)

        _ = await viewModel.sendResetLink()

        #expect(viewModel.banner == .unexpectedError)
        #expect(viewModel.banner?.title == nil)
    }

    @Test func secondSubmitWhileInFlightIsIgnored() async {
        let spy = SpyAuthRepository(delay: .milliseconds(50))
        let viewModel = makeViewModel(spy: spy)

        async let first = viewModel.sendResetLink()
        async let second = viewModel.sendResetLink()
        let outcomes = await [first, second]

        #expect(spy.passwordResetEmails.count == 1)
        #expect(outcomes.compactMap { $0 } == [.resetLinkSent(email: "ram@example.com")])
    }
}
