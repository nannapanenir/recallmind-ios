import SwiftUI

/// Dependency container injected through the SwiftUI environment.
struct AppEnvironment: Sendable {
    let authRepository: any AuthRepository
}

extension AppEnvironment {
    static let mock = AppEnvironment(authRepository: MockAuthRepository())
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
