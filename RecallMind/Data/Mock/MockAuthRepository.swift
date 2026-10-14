import Foundation

struct MockAuthRepository: AuthRepository {
    private let user: User?
    private let error: (any Error)?
    private let latency: Duration

    /// Defaults to no active session after ~400 ms.
    init(user: User? = nil, error: (any Error)? = nil, latency: Duration = .milliseconds(400)) {
        self.user = user
        self.error = error
        self.latency = latency
    }

    func restoreSession() async throws -> User? {
        try await Task.sleep(for: latency)
        if let error {
            throw error
        }
        return user
    }
}
