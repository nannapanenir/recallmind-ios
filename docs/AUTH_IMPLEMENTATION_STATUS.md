# Authentication — implementation status

Visual source of truth: Claude Design canvas (artboards `AUTH-01` … `AUTH-08`, `DS-01` … `DS-13`).
Locked Design System v22 tokens win over small artboard differences.

**Status: Authentication complete (AUTH 01–07B, AUTH 08 states) on the mock repository.**

## Screens (`RecallMind/Features/Authentication/`)

| Screen | Files | Notes |
|---|---|---|
| AUTH 01 Welcome | `Views/WelcomeView` | locked |
| AUTH 02 Email Sign In | `Views/EmailSignInView`, `ViewModels/EmailSignInViewModel` | |
| AUTH 03 Create Account | `Views/CreateAccountView`, `ViewModels/CreateAccountViewModel` | |
| AUTH 04 Verify Email | `Views/VerifyEmailView`, `ViewModels/VerifyEmailViewModel` | no back button |
| AUTH 05 Forgot Password | `Views/ForgotPasswordView`, `ViewModels/ForgotPasswordViewModel` | |
| AUTH 06 Check Your Email | `Views/CheckYourEmailView`, `ViewModels/CheckYourEmailViewModel` | |
| AUTH 07 Reset Password | `Views/ResetPasswordView`, `ViewModels/ResetPasswordViewModel` | no back button |
| AUTH 07B Password Updated | `Views/PasswordUpdatedView` | no view model, no back button |

All simulator-validated on iPhone 17 Pro (Xcode 27.1, iOS 26.5 runtime).

## AUTH 08 (states, not a screen)

- `AuthBanner` (`AuthBanner.swift`): error banners with approved copy and action — incorrect credentials,
  unable to connect (Try Again), too many attempts, reset link expired (Send a new link),
  verification link expired (Resend Email), `unexpectedError` (no copy → not shown).
- `AuthFieldError`: invalid email, password too short, passwords don’t match (blur + submit, never while typing).
- Notices (`RMNotice`): AUTH 04 “Verify your email to continue.” / “We couldn’t confirm your email yet.”;
  session expired at the top of AUTH 01/02 (`AppState.isSessionExpired`).
- Success: “Email sent” chip (AUTH 04), AUTH 07B screen. Loading labels on every primary action.
- Sign-up and reset requests succeed for every email (never reveal an account).

## Routes (`AuthenticationFlowView`, auth-local `NavigationStack` path)

```
AUTH 01 ─▶ AUTH 02 ─┬─ Create account ─▶ AUTH 03 ─▶ AUTH 04 (.accountCreated) ─ verified ─▶ Home
                    ├─ sign-in, unverified ─▶ AUTH 04 (.signInUnverified, notice)
                    ├─ Forgot password? ─▶ AUTH 05 ─▶ AUTH 06
                    └─ signed in ─▶ Home
Reset link ─▶ AUTH 07 ─▶ AUTH 07B ─ Continue to RecallMind ─▶ Home (signed in)
AUTH 07 expired ─ Send a new link ─▶ AUTH 05
AUTH 03/04/05/06 Sign in / Back to Sign In ─▶ pop to AUTH 02
AUTH 04 Use a different email ─▶ AUTH 03
```

No global router. Debug-only launch arguments stand in for missing deep links:
`-RMResetPasswordPreview <token>` opens AUTH 07 (`expired` → expired state);
`-RMSessionExpiredPreview YES` makes the mock session restore expire.

## Shared components

Design System (`DesignSystem/Components/`): `RMPrimaryButton`, `RMSecondaryButton`, `RMTextButton`
(.gold/.secondary), `RMTextField`, `RMPasswordField`, `RMFieldError`, `RMFieldHint`, `RMErrorBanner`,
`RMNotice`, `RMSuccessChip`, `RMHeroIcon` (.gold/.success), `RMLegalFooter`, `RMPressableButtonStyle`.
Auth-only: `AuthBanner`/`AuthBannerView`/`.announcesAuthBanner`, `AuthFieldError`, `AuthValidation`,
`ResendCooldown` (30 s, AUTH 04/06), `OpenURLAction.openMail()`.

## `AuthRepository`

- `restoreSession() -> User?` — `AuthError.sessionExpired` shows the session notice
- `signIn(email:password:) -> User` — `invalidCredentials` for unknown email and wrong password; `emailNotVerified` → AUTH 04
- `signUp(email:password:)`
- `resendVerificationEmail(to:)`
- `checkEmailVerification(email:) -> User?` — `nil` while unverified; may throw `verificationLinkExpired`
- `requestPasswordReset(email:)`
- `resetPassword(to:context:) -> User` — `PasswordResetContext(email, token)`; throws `resetLinkExpired`

## `MockAuthRepository` (default app environment)

Every call waits `latency` (400 ms) and succeeds unless configured: `user`/`error` (restore),
`signInUser`/`signInError`, `signUpError`, `resendError`, `isEmailVerified` (default `true`)/`verificationError`,
`passwordResetError`, `resetPasswordError`; reset token `"expired"` throws `resetLinkExpired`. No email, no backend.
Tests use `RecallMindTests/Support/SpyAuthRepository.swift`.

## Tests

71 passing (Swift Testing): AppState 7 · EmailSignIn 15 · CreateAccount 14 · VerifyEmail 12 ·
ForgotPassword 8 · CheckYourEmail 6 · ResetPassword 9.

## Open items

- Inter fonts not bundled: every weight falls back to SF Pro Regular.
- No approved copy: generic unexpected error (not shown); a separate resend-limit message (rate limits use “Too many attempts”).
- Real backend, reset-link / verification deep links (Universal Links) and session persistence not built.
- Sign in with Apple not implemented (AUTH 08 Apple states pending with it).
- AUTH 04 verified → design goes to 69 Quick Setup; app goes to Home until it exists.
- Terms of Service / Privacy Policy destinations not wired.
- AUTH 07 expired banner action is inline gold text, not the DS 06 pill shown on AUTH 08.
- Not yet checked on a physical iPhone or at large Dynamic Type sizes.

## Next product step

Quick Setup (69), then the signed-in app (Home / Notes / Settings); backend integration of `AuthRepository`.
