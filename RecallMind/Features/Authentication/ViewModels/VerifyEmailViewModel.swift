import Foundation
import Observation

/// AUTH 04 state: resend with cooldown and the "I’ve verified my email" check.
@MainActor
@Observable
final class VerifyEmailViewModel {
    /// How the user reached AUTH 04.
    enum Context: Hashable {
        /// AUTH 03 created the account and sent the first email.
        case accountCreated
        /// AUTH 02 sign-in found the email unverified and sent a new link.
        case signInUnverified
    }

    /// AUTH 08 notices shown inline above Open Mail.
    enum Notice: Equatable {
        case verifyToContinue(email: String)
        case notConfirmedYet

        var title: String {
            switch self {
            case .verifyToContinue: "Verify your email to continue."
            case .notConfirmedYet: "We couldn’t confirm your email yet."
            }
        }

        var message: String {
            switch self {
            case .verifyToContinue(let email): "We sent a new verification link to \(email)."
            case .notConfirmedYet: "Open the link in your email, then try again."
            }
        }
    }

    /// The action an "Unable to connect" banner retries.
    enum Action: Equatable {
        case resend
        case checkVerification
    }

    let email: String
    let cooldown: ResendCooldown

    private(set) var notice: Notice?
    private(set) var banner: AuthBanner?
    private(set) var failedAction: Action?
    private(set) var isEmailSentVisible = true
    private(set) var isResending = false
    private(set) var isCheckingVerification = false

    private let repository: any AuthRepository

    init(
        email: String,
        context: Context,
        repository: any AuthRepository,
        sleep: @escaping (Duration) async throws -> Void = { try await Task.sleep(for: $0) }
    ) {
        self.email = email
        self.repository = repository
        self.cooldown = ResendCooldown(sleep: sleep)
        if context == .signInUnverified {
            notice = .verifyToContinue(email: email)
        }
    }

    var resendSecondsRemaining: Int {
        cooldown.secondsRemaining
    }

    /// Changes each time a cooldown starts, so the view restarts its countdown task.
    var cooldownCycle: Int {
        cooldown.cycle
    }

    var canResend: Bool {
        !cooldown.isActive && !isResending
    }

    func runResendCountdown() async {
        await cooldown.run()
    }

    func resend() async {
        guard canResend else { return }
        clearMessages()
        isEmailSentVisible = false
        isResending = true
        defer { isResending = false }

        do {
            try await repository.resendVerificationEmail(to: email)
            isEmailSentVisible = true
            cooldown.restart()
        } catch {
            fail(.resend, error)
        }
    }

    /// Returns the signed-in user when the email is verified, otherwise `nil` with a notice or banner.
    func checkVerification() async -> User? {
        guard !isCheckingVerification else { return nil }
        clearMessages()
        isCheckingVerification = true
        defer { isCheckingVerification = false }

        do {
            if let user = try await repository.checkEmailVerification(email: email) {
                return user
            }
            notice = .notConfirmedYet
        } catch {
            fail(.checkVerification, error)
        }
        return nil
    }

    private func clearMessages() {
        notice = nil
        banner = nil
        failedAction = nil
    }

    private func fail(_ action: Action, _ error: any Error) {
        banner = AuthBanner(error: error)
        if banner == .verificationLinkExpired {
            // AUTH 08: the expired link needs a new email now; the banner's "Resend Email" sends it.
            cooldown.finish()
            isEmailSentVisible = false
            failedAction = .resend
        } else {
            failedAction = banner == nil ? nil : action
        }
    }
}
