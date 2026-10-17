import SwiftUI

/// Dependency container injected through the SwiftUI environment.
struct AppEnvironment: Sendable {
    let authRepository: any AuthRepository
}

extension AppEnvironment {
    static let mock = AppEnvironment(
        authRepository: MockAuthRepository(error: debugRestoreError, verificationError: debugVerificationError)
    )

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

    /// Debug builds only: launching with `-RMVerificationExpiredPreview YES` makes AUTH 04's
    /// "I’ve verified my email" report an expired verification link (AUTH 08 state).
    private static var debugVerificationError: (any Error)? {
        #if DEBUG
        if UserDefaults.standard.bool(forKey: "RMVerificationExpiredPreview") {
            return AuthError.verificationLinkExpired
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
