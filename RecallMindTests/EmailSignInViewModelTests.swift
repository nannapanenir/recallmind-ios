import Foundation
import Testing
@testable import RecallMind

@MainActor
struct EmailSignInViewModelTests {
    private struct UnexpectedFailure: Error {}

    /// Records sign-in calls; returns `result` after an optional delay.
    @MainActor
    private final class SpyAuthRepository: AuthRepository {
        private(set) var signInEmails: [String] = []
        var result: Result<User, any Error>
        private let delay: Duration

        init(result: Result<User, any Error>, delay: Duration = .zero) {
            self.result = result
            self.delay = delay
        }

        func restoreSession() async throws -> User? { nil }

        func signIn(email: String, password: String) async throws -> User {
            signInEmails.append(email)
            try await Task.sleep(for: delay)
            return try result.get()
        }
    }

    private let user = User(id: UUID(), email: "ram@example.com")

    private func makeViewModel(signInError: (any Error)? = nil) -> EmailSignInViewModel {
        let repository = MockAuthRepository(signInUser: user, signInError: signInError, latency: .zero)
        let viewModel = EmailSignInViewModel(repository: repository)
        viewModel.email = "ram@example.com"
        viewModel.password = "listenlearn"
        return viewModel
    }

    // MARK: - Local validation

    @Test func invalidEmailDoesNotSubmit() async {
        let spy = SpyAuthRepository(result: .success(user))
        let viewModel = EmailSignInViewModel(repository: spy)
        viewModel.email = "ram@example"
        viewModel.password = "listenlearn"

        let outcome = await viewModel.signIn()

        #expect(outcome == nil)
        #expect(viewModel.emailError == .invalidEmail)
        #expect(viewModel.emailError?.message == "Enter a valid email address.")
        #expect(spy.signInEmails.isEmpty)
    }

    @Test func emptyPasswordDoesNotSubmit() async {
        let spy = SpyAuthRepository(result: .success(user))
        let viewModel = EmailSignInViewModel(repository: spy)
        viewModel.email = "ram@example.com"

        #expect(!viewModel.canSubmit)
        let outcome = await viewModel.signIn()

        #expect(outcome == nil)
        #expect(spy.signInEmails.isEmpty)
    }

    @Test func emptyEmailDisablesSubmit() {
        let viewModel = EmailSignInViewModel(repository: SpyAuthRepository(result: .success(user)))
        viewModel.email = "   "
        viewModel.password = "listenlearn"

        #expect(!viewModel.canSubmit)
    }

    @Test func blurValidationFlagsInvalidEmailAndEditingClearsIt() {
        let viewModel = EmailSignInViewModel(repository: SpyAuthRepository(result: .success(user)))
        viewModel.email = "not-an-email"

        viewModel.validateEmail()
        #expect(viewModel.emailError == .invalidEmail)

        viewModel.email = "not-an-email@example.com"
        #expect(viewModel.emailError == nil)
    }

    @Test func blurValidationIgnoresEmptyEmail() {
        let viewModel = EmailSignInViewModel(repository: SpyAuthRepository(result: .success(user)))

        viewModel.validateEmail()

        #expect(viewModel.emailError == nil)
    }

    @Test func submitsTrimmedEmail() async {
        let spy = SpyAuthRepository(result: .success(user))
        let viewModel = EmailSignInViewModel(repository: spy)
        viewModel.email = "  ram@example.com \n"
        viewModel.password = "listenlearn"

        _ = await viewModel.signIn()

        #expect(spy.signInEmails == ["ram@example.com"])
    }

    // MARK: - Repository outcomes

    @Test func successfulSignInReturnsUser() async {
        let viewModel = makeViewModel()

        let outcome = await viewModel.signIn()

        #expect(outcome == .signedIn(user))
        #expect(viewModel.banner == nil)
        #expect(!viewModel.isSubmitting)
    }

    @Test func invalidCredentialsShowPrivacySafeMessage() async {
        let viewModel = makeViewModel(signInError: AuthError.invalidCredentials)

        let outcome = await viewModel.signIn()

        #expect(outcome == nil)
        #expect(viewModel.banner == .incorrectCredentials)
        #expect(viewModel.banner?.title == "Incorrect email or password.")
        #expect(viewModel.banner?.message == "Check your details and try again.")
        #expect(viewModel.emailError == nil)
    }

    @Test func unverifiedEmailRoutesToVerification() async {
        let viewModel = makeViewModel(signInError: AuthError.emailNotVerified)

        let outcome = await viewModel.signIn()

        #expect(outcome == .requiresEmailVerification(email: "ram@example.com"))
        #expect(viewModel.banner == nil)
    }

    @Test func tooManyAttemptsShowsMessage() async {
        let viewModel = makeViewModel(signInError: AuthError.tooManyAttempts)

        _ = await viewModel.signIn()

        #expect(viewModel.banner == .tooManyAttempts)
        #expect(viewModel.banner?.title == "Too many attempts. Try again later.")
    }

    @Test func networkErrorShowsUnableToConnect() async {
        let viewModel = makeViewModel(signInError: AuthError.network)

        _ = await viewModel.signIn()

        #expect(viewModel.banner == .unableToConnect)
        #expect(viewModel.banner?.title == "Unable to connect")
    }

    @Test func unexpectedErrorShowsUnableToConnect() async {
        let viewModel = makeViewModel(signInError: UnexpectedFailure())

        _ = await viewModel.signIn()

        #expect(viewModel.banner == .unableToConnect)
        #expect(!viewModel.isSubmitting)
    }

    @Test func retryClearsPreviousBannerOnSuccess() async {
        let spy = SpyAuthRepository(result: .failure(AuthError.network))
        let viewModel = EmailSignInViewModel(repository: spy)
        viewModel.email = "ram@example.com"
        viewModel.password = "listenlearn"
        _ = await viewModel.signIn()
        #expect(viewModel.banner == .unableToConnect)

        spy.result = .success(user)
        let outcome = await viewModel.signIn()

        #expect(outcome == .signedIn(user))
        #expect(viewModel.banner == nil)
        #expect(spy.signInEmails.count == 2)
    }

    // MARK: - Double submission

    @Test func secondSubmitWhileInFlightIsIgnored() async {
        let spy = SpyAuthRepository(result: .success(user), delay: .milliseconds(50))
        let viewModel = EmailSignInViewModel(repository: spy)
        viewModel.email = "ram@example.com"
        viewModel.password = "listenlearn"

        async let first = viewModel.signIn()
        async let second = viewModel.signIn()
        let outcomes = await [first, second]

        #expect(spy.signInEmails.count == 1)
        #expect(outcomes.compactMap { $0 } == [.signedIn(user)])
        #expect(!viewModel.isSubmitting)
    }
}
