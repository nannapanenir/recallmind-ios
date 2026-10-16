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

    @Test func completeSignInResultsInSignedIn() {
        let user = User(id: UUID(), email: "test@example.com")
        let appState = AppState()

        appState.completeSignIn(with: user)

        #expect(appState.authStatus == .signedIn(user))
    }

    @Test func expiredSessionSignsOutWithNotice() async {
        let appState = AppState()
        let repository = MockAuthRepository(error: AuthError.sessionExpired, latency: .zero)

        await appState.restoreSession(using: repository)

        #expect(appState.authStatus == .signedOut)
        #expect(appState.isSessionExpired)
    }

    @Test func otherRestoreErrorsDoNotShowSessionExpired() async {
        let appState = AppState()
        let repository = MockAuthRepository(error: RestoreFailure(), latency: .zero)

        await appState.restoreSession(using: repository)

        #expect(!appState.isSessionExpired)
    }

    @Test func signingInClearsSessionExpired() async {
        let appState = AppState()
        await appState.restoreSession(using: MockAuthRepository(error: AuthError.sessionExpired, latency: .zero))

        appState.completeSignIn(with: User(id: UUID(), email: "test@example.com"))

        #expect(!appState.isSessionExpired)
    }
}
