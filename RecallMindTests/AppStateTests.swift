import Foundation
import Testing
@testable import RecallMind

@MainActor
struct AppStateTests {
    private struct RestoreFailure: Error {}

    @Test func noRestoredSessionResultsInSignedOut() async {
        let appState = AppState()
        let repository = MockAuthRepository(latency: .zero)

        await appState.restoreSession(using: repository)

        #expect(appState.authStatus == .signedOut)
    }

    @Test func restoredSessionResultsInSignedIn() async {
        let user = User(id: UUID(), email: "test@example.com")
        let appState = AppState()
        let repository = MockAuthRepository(user: user, latency: .zero)

        await appState.restoreSession(using: repository)

        #expect(appState.authStatus == .signedIn(user))
    }

    @Test func restoreErrorResultsInSignedOut() async {
        let appState = AppState()
        let repository = MockAuthRepository(error: RestoreFailure(), latency: .zero)

        await appState.restoreSession(using: repository)

        #expect(appState.authStatus == .signedOut)
    }
}
