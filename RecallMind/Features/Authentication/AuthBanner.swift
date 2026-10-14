import SwiftUI
import UIKit

/// AUTH 08 error messages shown inline above an auth screen's primary button.
enum AuthBanner: Equatable {
    case incorrectCredentials
    case unableToConnect
    case tooManyAttempts
    /// An error that is not one of the classified `AuthError` cases.
    /// PENDING AUTH 08 / design: no approved copy yet, so nothing is shown.
    case unexpectedError

    /// Classifies a repository failure. `nil` for cancellation: the screen went away.
    init?(error: any Error) {
        switch error {
        case AuthError.invalidCredentials: self = .incorrectCredentials
        case AuthError.network: self = .unableToConnect
        case AuthError.tooManyAttempts: self = .tooManyAttempts
        case is CancellationError: return nil
        default: self = .unexpectedError
        }
    }

    /// `nil` when the state has no approved copy.
    var title: String? {
        switch self {
        case .incorrectCredentials: "Incorrect email or password."
        case .unableToConnect: "Unable to connect"
        case .tooManyAttempts: "Too many attempts. Try again later."
        case .unexpectedError: nil
        }
    }

    var message: String? {
        switch self {
        case .incorrectCredentials: "Check your details and try again."
        case .unableToConnect: "Check your internet connection."
        case .tooManyAttempts, .unexpectedError: nil
        }
    }
}

/// Local form rules shared by the auth screens.
enum AuthValidation {
    static let minimumPasswordLength = 8

    static func isValidEmail(_ email: String) -> Bool {
        email.wholeMatch(of: #/[^\s@]+@[^\s@]+\.[^\s@]+/#) != nil
    }
}

/// Renders an `AuthBanner`; banners without approved copy render nothing.
/// Only "Unable to connect" offers a retry.
struct AuthBannerView: View {
    let banner: AuthBanner
    let retry: () -> Void

    var body: some View {
        if let title = banner.title {
            let isOffline = banner == .unableToConnect
            RMErrorBanner(
                symbol: isOffline ? .offline : .error,
                title: title,
                message: banner.message,
                actionTitle: isOffline ? "Try Again" : nil,
                action: isOffline ? { retry() } : nil
            )
        }
    }
}

extension View {
    /// Announces a newly shown banner title to VoiceOver.
    func announcesAuthBanner(_ banner: AuthBanner?) -> some View {
        onChange(of: banner) { _, banner in
            if let title = banner?.title {
                UIAccessibility.post(notification: .announcement, argument: title)
            }
        }
    }
}
