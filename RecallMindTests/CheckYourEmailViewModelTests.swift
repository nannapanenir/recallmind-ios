import Foundation
import Testing
@testable import RecallMind

@MainActor
struct CheckYourEmailViewModelTests {
    private let email = "ram@example.com"

    /// Sleeps return immediately so the cooldown runs to zero synchronously.
    private func makeViewModel(spy: SpyAuthRepository) -> CheckYourEmailViewModel {
        CheckYourEmailViewModel(email: email, repository: spy, sleep: { _ in })
    }

    private func makeReadyToResend(spy: SpyAuthRepository) async -> CheckYourEmailViewModel {
        let viewModel = makeViewModel(spy: spy)
        await viewModel.cooldown.run()
        return viewModel
    }

    @Test func arrivingStartsThirtySecondCooldown() {
        let viewModel = makeViewModel(spy: SpyAuthRepository())

        #expect(viewModel.cooldown.secondsRemaining == 30)
        #expect(viewModel.cooldown.buttonTitle == "Resend available in 30s")
        #expect(!viewModel.canResend)
    }

    @Test func resendIsIgnoredDuringCooldown() async {
        let spy = SpyAuthRepository()
        let viewModel = makeViewModel(spy: spy)

        await viewModel.resend()

        #expect(spy.passwordResetEmails.isEmpty)
    }

    @Test func cooldownEndsWithResendEmailTitle() async {
        let viewModel = await makeReadyToResend(spy: SpyAuthRepository())

        #expect(viewModel.canResend)
        #expect(viewModel.cooldown.buttonTitle == "Resend Email")
    }

    @Test func successfulResendRequestsResetAgainAndRestartsCooldown() async {
        let spy = SpyAuthRepository()
        let viewModel = await makeReadyToResend(spy: spy)
        let cycle = viewModel.cooldown.cycle

        await viewModel.resend()

        #expect(spy.passwordResetEmails == [email])
        #expect(viewModel.cooldown.secondsRemaining == 30)
        #expect(viewModel.cooldown.cycle == cycle + 1)
        #expect(viewModel.banner == nil)
        #expect(!viewModel.isResending)
    }

    @Test func failedResendShowsBannerAndStaysAvailable() async {
        let spy = SpyAuthRepository()
        spy.passwordResetResult = .failure(AuthError.network)
        let viewModel = await makeReadyToResend(spy: spy)

        await viewModel.resend()

        #expect(viewModel.banner == .unableToConnect)
        #expect(viewModel.canResend)
    }

    @Test func tooManyAttemptsShowsMessage() async {
        let spy = SpyAuthRepository()
        spy.passwordResetResult = .failure(AuthError.tooManyAttempts)
        let viewModel = await makeReadyToResend(spy: spy)

        await viewModel.resend()

        #expect(viewModel.banner == .tooManyAttempts)
    }
}
