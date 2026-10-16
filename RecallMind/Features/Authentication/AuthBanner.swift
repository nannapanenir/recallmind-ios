import SwiftUI
import UIKit

/// AUTH 08 error messages shown inline above an auth screen's primary button.
enum AuthBanner: Equatable {
    case incorrectCredentials
    case unableToConnect
    case tooManyAttempts
    /// AUTH 07: the password reset link is no longer valid.
    case resetLinkExpired
    /// AUTH 04: the email verification link is no longer valid.
    case verificationLinkExpired
    /// An error that is not one of the classified `AuthError` cases.
    /// PENDING AUTH 08 / design: no approved copy yet, so nothing is shown.
    case unexpectedError

    /// Classifies a repository failure. `nil` for cancellation: the screen went away.
    init?(error: any Error) {
        switch error {
        case AuthError.invalidCredentials: self = .incorrectCredentials
        case AuthError.network: self = .unableToConnect
        case AuthError.tooManyAttempts: self = .tooManyAttempts
        case AuthError.resetLinkExpired: self = .resetLinkExpired
        case AuthError.verificationLinkExpired: self = .verificationLinkExpired
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
        case .resetLinkExpired, .verificationLinkExpired: "This link has expired"
        case .unexpectedError: nil
        }
    }

    var message: String? {
        switch self {
        case .incorrectCredentials: "Check your details and try again."
        case .unableToConnect: "Check your internet connection."
        case .resetLinkExpired: "Request a new password reset link."
        case .verificationLinkExpired: "Send a new verification email to finish creating your account."
        case .tooManyAttempts, .unexpectedError: nil
        }
    }

    /// The banner's action, if AUTH 08 gives it one.
    var actionTitle: String? {
        switch self {
        case .unableToConnect: "Try Again"
        case .resetLinkExpired: "Send a new link"
        case .verificationLinkExpired: "Resend Email"
        case .incorrectCredentials, .tooManyAttempts, .unexpectedError: nil
        }
    }
}

/// AUTH 08 inline field errors.
enum AuthFieldError: Equatable {
    case invalidEmail
    case passwordTooShort
    case passwordsDontMatch

    var message: String {
        switch self {
        case .invalidEmail: "Enter a valid email address."
        case .passwordTooShort: "Use at least 8 characters."
        case .passwordsDontMatch: "Passwords don’t match."
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
/// `action` runs the banner's own action ("Try Again", "Send a new link").
struct AuthBannerView: View {
    let banner: AuthBanner
    let action: () -> Void

    var body: some View {
        if let title = banner.title {
            let actionTitle = banner.actionTitle
            RMErrorBanner(
                symbol: banner == .unableToConnect ? .offline : .error,
                title: title,
                message: banner.message,
                actionTitle: actionTitle,
                action: actionTitle == nil ? nil : { action() }
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
