import Foundation
import Testing
@testable import RecallMind

@MainActor
struct ResetPasswordViewModelTests {
    private struct UnexpectedFailure: Error {}

    private let context = PasswordResetContext(email: "ram@example.com", token: "token-1")
    private let user = User(id: UUID(), email: "ram@example.com")

    private func makeViewModel(
        spy: SpyAuthRepository,
        newPassword: String = "rememberthis",
        confirmPassword: String = "rememberthis"
    ) -> ResetPasswordViewModel {
        let viewModel = ResetPasswordViewModel(context: context, repository: spy)
        viewModel.newPassword = newPassword
        viewModel.confirmPassword = confirmPassword
        return viewModel
    }

    @Test func updateNeedsBothFields() {
        let viewModel = ResetPasswordViewModel(context: context, repository: SpyAuthRepository())
        #expect(!viewModel.canSubmit)

        viewModel.newPassword = "rememberthis"
        #expect(!viewModel.canSubmit)

        viewModel.confirmPassword = "x"
        #expect(viewModel.canSubmit)
    }

    @Test func blurFlagsShortPasswordAndEditingClearsIt() {
        let viewModel = makeViewModel(spy: SpyAuthRepository(), newPassword: "remember")
        viewModel.newPassword = "short"

        viewModel.validateNewPassword()
        #expect(viewModel.newPasswordError == .passwordTooShort)
        #expect(!viewModel.meetsPasswordLength)

        // The field writes its unchanged text back when it loses focus.
        viewModel.newPassword = "short"
        #expect(viewModel.newPasswordError == .passwordTooShort)

        viewModel.newPassword = "rememberthis"
        #expect(viewModel.newPasswordError == nil)
        #expect(viewModel.meetsPasswordLength)
    }

    @Test func blurFlagsMismatchAndEditingNewPasswordClearsIt() {
        let viewModel = makeViewModel(spy: SpyAuthRepository(), confirmPassword: "rememberthat")

        viewModel.validateConfirmPassword()
        #expect(viewModel.confirmPasswordError == .passwordsDontMatch)

        viewModel.newPassword = "rememberthat"
        #expect(viewModel.confirmPasswordError == nil)
    }

    @Test func invalidPasswordsDoNotSubmit() async {
        let spy = SpyAuthRepository()
        let viewModel = makeViewModel(spy: spy, newPassword: "short", confirmPassword: "other")

        let result = await viewModel.updatePassword()

        #expect(result == nil)
        #expect(viewModel.newPasswordError == .passwordTooShort)
        #expect(viewModel.confirmPasswordError == .passwordsDontMatch)
        #expect(spy.newPasswords.isEmpty)
    }

    @Test func successReturnsUserForPasswordUpdated() async {
        let spy = SpyAuthRepository()
        spy.resetPasswordResult = .success(user)
        let viewModel = makeViewModel(spy: spy)

        let result = await viewModel.updatePassword()

        #expect(result == user)
        #expect(spy.newPasswords == ["rememberthis"])
        #expect(spy.resetContexts == [context])
        #expect(!viewModel.isSubmitting)
    }

    @Test func expiredLinkShowsAuth08Banner() async {
        let spy = SpyAuthRepository()
        spy.resetPasswordResult = .failure(AuthError.resetLinkExpired)
        let viewModel = makeViewModel(spy: spy)

        let result = await viewModel.updatePassword()

        #expect(result == nil)
        #expect(viewModel.banner == .resetLinkExpired)
        #expect(viewModel.banner?.title == "This link has expired")
        #expect(viewModel.banner?.message == "Request a new password reset link.")
        #expect(viewModel.banner?.actionTitle == "Send a new link")
    }

    @Test func networkErrorShowsRetryableBanner() async {
        let spy = SpyAuthRepository()
        spy.resetPasswordResult = .failure(AuthError.network)
        let viewModel = makeViewModel(spy: spy)

        _ = await viewModel.updatePassword()

        #expect(viewModel.banner == .unableToConnect)
        #expect(viewModel.banner?.actionTitle == "Try Again")
    }

    @Test func unexpectedErrorHasNoApprovedCopy() async {
        let spy = SpyAuthRepository()
        spy.resetPasswordResult = .failure(UnexpectedFailure())
        let viewModel = makeViewModel(spy: spy)

        _ = await viewModel.updatePassword()

        #expect(viewModel.banner == .unexpectedError)
        #expect(viewModel.banner?.title == nil)
    }

    @Test func mockTreatsExpiredTokenAsExpiredLink() async {
        let mock = MockAuthRepository(latency: .zero)
        let expired = PasswordResetContext(email: "ram@example.com", token: MockAuthRepository.expiredResetToken)

        await #expect(throws: AuthError.resetLinkExpired) {
            _ = try await mock.resetPassword(to: "rememberthis", context: expired)
        }
        let user = try? await mock.resetPassword(to: "rememberthis", context: context)
        #expect(user?.email == "ram@example.com")
    }
}
