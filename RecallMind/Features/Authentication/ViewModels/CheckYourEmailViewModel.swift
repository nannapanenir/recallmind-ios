import Foundation
import Observation

/// AUTH 06 state: resending the password reset link with a cooldown.
@MainActor
@Observable
final class CheckYourEmailViewModel {
    let email: String
    let cooldown: ResendCooldown

    private(set) var banner: AuthBanner?
    private(set) var isResending = false

    private let repository: any AuthRepository

    init(
        email: String,
        repository: any AuthRepository,
        sleep: @escaping (Duration) async throws -> Void = { try await Task.sleep(for: $0) }
    ) {
        self.email = email
        self.repository = repository
        self.cooldown = ResendCooldown(sleep: sleep)
    }

    var canResend: Bool {
        !cooldown.isActive && !isResending
    }

    /// Sends the reset link again. Succeeds for every email, as on AUTH 05.
    func resend() async {
        guard canResend else { return }
        banner = nil
        isResending = true
        defer { isResending = false }

        do {
            try await repository.requestPasswordReset(email: email)
            cooldown.restart()
        } catch {
            banner = AuthBanner(error: error)
        }
    }
}
