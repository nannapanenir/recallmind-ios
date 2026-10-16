import SwiftUI

/// Dependency container injected through the SwiftUI environment.
struct AppEnvironment: Sendable {
    let authRepository: any AuthRepository
}

extension AppEnvironment {
    static let mock = AppEnvironment(authRepository: MockAuthRepository(error: debugRestoreError))

    /// Debug builds only: launching with `-RMSessionExpiredPreview YES` makes the mock session
    /// restore fail as expired, to check the AUTH 08 session-expired notice.
    private static var debugRestoreError: (any Error)? {
        #if DEBUG
        if UserDefaults.standard.bool(forKey: "RMSessionExpiredPreview") {
            return AuthError.sessionExpired
        }
        #endif
        return nil
    }
}

private struct AppEnvironmentKey: EnvironmentKey {
    static let defaultValue = AppEnvironment.mock
}

extension EnvironmentValues {
    var appEnvironment: AppEnvironment {
        get { self[AppEnvironmentKey.self] }
        set { self[AppEnvironmentKey.self] = newValue }
    }
}
