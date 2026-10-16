import Foundation
import Testing
@testable import RecallMind

@MainActor
struct VerifyEmailViewModelTests {
    private struct UnexpectedFailure: Error {}

    private let email = "ram@example.com"
    private let user = User(id: UUID(), email: "ram@example.com")

    /// Sleeps return immediately so the cooldown runs to zero synchronously.
    private func makeViewModel(
        spy: SpyAuthRepository,
        context: VerifyEmailViewModel.Context = .accountCreated
    ) -> VerifyEmailViewModel {
        VerifyEmailViewModel(email: email, context: context, repository: spy, sleep: { _ in })
    }

    private func makeReadyToResend(spy: SpyAuthRepository) async -> VerifyEmailViewModel {
        let viewModel = makeViewModel(spy: spy)
        await viewModel.runResendCountdown()
        return viewModel
    }

    // MARK: - Arrival

    @Test func arrivingFromCreateAccountShowsEmailSentAndStartsCooldown() {
        let viewModel = makeViewModel(spy: SpyAuthRepository())

        #expect(viewModel.isEmailSentVisible)
        #expect(viewModel.notice == nil)
        #expect(viewModel.resendSecondsRemaining == 30)
        #expect(!viewModel.canResend)
    }

    @Test func arrivingFromUnverifiedSignInShowsVerifyNotice() {
        let viewModel = makeViewModel(spy: SpyAuthRepository(), context: .signInUnverified)

        #expect(viewModel.notice == .verifyToContinue(email: email))
        #expect(viewModel.notice?.title == "Verify your email to continue.")
        #expect(viewModel.notice?.message == "We sent a new verification link to ram@example.com.")
    }

    // MARK: - Resend

    @Test func countdownReachesZeroAndEnablesResend() async {
        let viewModel = await makeReadyToResend(spy: SpyAuthRepository())

        #expect(viewModel.resendSecondsRemaining == 0)
        #expect(viewModel.canResend)
    }

    @Test func countdownStopsWhenCancelled() async {
        let viewModel = VerifyEmailViewModel(
            email: email,
            context: .accountCreated,
            repository: SpyAuthRepository(),
            sleep: { _ in throw CancellationError() }
        )

        await viewModel.runResendCountdown()

        #expect(viewModel.resendSecondsRemaining == 30)
    }

    @Test func resendIsIgnoredDuringCooldown() async {
        let spy = SpyAuthRepository()
        let viewModel = makeViewModel(spy: spy)

        await viewModel.resend()

        #expect(spy.resendEmails.isEmpty)
    }

    @Test func successfulResendRestartsCooldown() async {
        let spy = SpyAuthRepository()
        let viewModel = await makeReadyToResend(spy: spy)
        let cycle = viewModel.cooldownCycle

        await viewModel.resend()

        #expect(spy.resendEmails == [email])
        #expect(viewModel.isEmailSentVisible)
        #expect(viewModel.resendSecondsRemaining == 30)
        #expect(viewModel.cooldownCycle == cycle + 1)
        #expect(!viewModel.isResending)
    }

    @Test func failedResendShowsRetryableBanner() async {
        let spy = SpyAuthRepository()
        spy.resendResult = .failure(AuthError.network)
        let viewModel = await makeReadyToResend(spy: spy)

        await viewModel.resend()

        #expect(viewModel.banner == .unableToConnect)
        #expect(viewModel.failedAction == .resend)
        #expect(!viewModel.isEmailSentVisible)
        #expect(viewModel.canResend)
    }

    // MARK: - Check verification

    @Test func verifiedEmailReturnsUser() async {
        let spy = SpyAuthRepository()
        spy.verificationResult = .success(user)
        let viewModel = makeViewModel(spy: spy)

        let result = await viewModel.checkVerification()

        #expect(result == user)
        #expect(spy.verificationChecks == [email])
        #expect(viewModel.notice == nil)
        #expect(!viewModel.isCheckingVerification)
    }

    @Test func unverifiedEmailShowsNotConfirmedNotice() async {
        let viewModel = makeViewModel(spy: SpyAuthRepository(), context: .signInUnverified)

        let result = await viewModel.checkVerification()

        #expect(result == nil)
        #expect(viewModel.notice == .notConfirmedYet)
        #expect(viewModel.notice?.title == "We couldn’t confirm your email yet.")
        #expect(viewModel.notice?.message == "Open the link in your email, then try again.")
    }

    @Test func failedCheckShowsRetryableBannerAndClearsNotice() async {
        let spy = SpyAuthRepository()
        spy.verificationResult = .failure(AuthError.network)
        let viewModel = makeViewModel(spy: spy, context: .signInUnverified)

        let result = await viewModel.checkVerification()

        #expect(result == nil)
        #expect(viewModel.banner == .unableToConnect)
        #expect(viewModel.failedAction == .checkVerification)
        #expect(viewModel.notice == nil)
    }

    @Test func unexpectedFailureHasNoApprovedCopyOrRetry() async {
        let spy = SpyAuthRepository()
        spy.verificationResult = .failure(UnexpectedFailure())
        let viewModel = makeViewModel(spy: spy)

        _ = await viewModel.checkVerification()

        #expect(viewModel.banner == .unexpectedError)
        #expect(viewModel.banner?.title == nil)
    }

    @Test func expiredVerificationLinkOffersImmediateResend() async {
        let spy = SpyAuthRepository()
        spy.verificationResult = .failure(AuthError.verificationLinkExpired)
        let viewModel = makeViewModel(spy: spy)
        #expect(!viewModel.canResend)

        _ = await viewModel.checkVerification()

        #expect(viewModel.banner == .verificationLinkExpired)
        #expect(viewModel.banner?.title == "This link has expired")
        #expect(viewModel.banner?.message == "Send a new verification email to finish creating your account.")
        #expect(viewModel.banner?.actionTitle == "Resend Email")
        #expect(viewModel.failedAction == .resend)
        #expect(viewModel.canResend)
        #expect(!viewModel.isEmailSentVisible)

        await viewModel.resend()

        #expect(spy.resendEmails == [email])
        #expect(viewModel.banner == nil)
        #expect(viewModel.isEmailSentVisible)
        #expect(viewModel.resendSecondsRemaining == 30)
    }
}
