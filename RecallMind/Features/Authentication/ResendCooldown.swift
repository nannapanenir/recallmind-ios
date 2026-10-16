import Foundation
import Observation
import SwiftUI

/// Resend cooldown shared by AUTH 04 and AUTH 06: "Resend available in 30s", then "Resend Email".
/// Starts counting when created, because those screens are shown right after an email was sent.
@MainActor
@Observable
final class ResendCooldown {
    nonisolated static let defaultSeconds = 30

    private(set) var secondsRemaining: Int
    /// Changes each time a cooldown restarts, so a view can restart its countdown task.
    private(set) var cycle = 0

    private let seconds: Int
    private let sleep: (Duration) async throws -> Void

    init(
        seconds: Int = ResendCooldown.defaultSeconds,
        sleep: @escaping (Duration) async throws -> Void = { try await Task.sleep(for: $0) }
    ) {
        self.seconds = seconds
        self.secondsRemaining = seconds
        self.sleep = sleep
    }

    var isActive: Bool {
        secondsRemaining > 0
    }

    /// AUTH 04 / AUTH 06 secondary button label; AUTH 08 "Resend Email" once available.
    var buttonTitle: String {
        isActive ? "Resend available in \(secondsRemaining)s" : "Resend Email"
    }

    /// Counts down once per second. Ends early when the task is cancelled.
    func run() async {
        while secondsRemaining > 0 {
            do {
                try await sleep(.seconds(1))
            } catch {
                return
            }
            secondsRemaining -= 1
        }
    }

    func restart() {
        secondsRemaining = seconds
        cycle += 1
    }

    /// Ends the cooldown early, e.g. when the last link turned out to be expired.
    func finish() {
        secondsRemaining = 0
        cycle += 1
    }
}

extension OpenURLAction {
    /// "Open Mail" on AUTH 04 / AUTH 06.
    func openMail() {
        if let url = URL(string: "message://") {
            self(url)
        }
    }
}
