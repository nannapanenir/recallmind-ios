import Observation

@MainActor
@Observable
final class AppState {
    enum AuthStatus: Equatable, Sendable {
        case unknown
        case signedOut
        case signedIn(User)
    }

    private(set) var authStatus: AuthStatus = .unknown
    /// Signed out because the stored session expired; AUTH 01 / 02 show the AUTH 08 notice.
    private(set) var isSessionExpired = false

    func restoreSession(using repository: any AuthRepository) async {
        do {
            if let user = try await repository.restoreSession() {
                authStatus = .signedIn(user)
            } else {
                authStatus = .signedOut
            }
        } catch AuthError.sessionExpired {
            isSessionExpired = true
            authStatus = .signedOut
        } catch {
            // A failed restore is treated as signed out for the frontend foundation.
            authStatus = .signedOut
        }
    }

    func completeSignIn(with user: User) {
        isSessionExpired = false
        authStatus = .signedIn(user)
    }
}
