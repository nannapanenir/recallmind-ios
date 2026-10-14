# Authentication — implementation status

Visual source of truth: Claude Design canvas (artboards `AUTH-01` … `AUTH-08`, `DS-01` … `DS-13`).
Locked Design System v22 tokens win over small artboard differences.

## Screens

| Screen | Status | Files |
|---|---|---|
| AUTH 01 Welcome | Done, locked | `Views/WelcomeView.swift` |
| AUTH 02 Email Sign In | Done, simulator-validated | `Views/EmailSignInView.swift`, `ViewModels/EmailSignInViewModel.swift` |
| AUTH 03 Create Account | Done, simulator-validated | `Views/CreateAccountView.swift`, `ViewModels/CreateAccountViewModel.swift` |
| AUTH 04 Verify Email | Done, simulator-validated | `Views/VerifyEmailView.swift`, `ViewModels/VerifyEmailViewModel.swift` |
| AUTH 05 Forgot Password | Done, simulator-validated | `Views/ForgotPasswordView.swift`, `ViewModels/ForgotPasswordViewModel.swift` |
| AUTH 06 Check Your Email | Not started | — |
| AUTH 07 Reset Password | Not started | — |
| AUTH 07B Password Updated | Not started | — |
| AUTH 08 States | Applied per screen | `AuthBanner.swift` + per-screen field/notice copy |

Paths are under `RecallMind/Features/Authentication/`.

## Routes (`AuthenticationFlowView`, auth-local `NavigationStack` path)

```
AUTH 01 ── Continue with Email ──▶ AUTH 02
AUTH 02 ── Create account ───────▶ AUTH 03 ── success ──▶ AUTH 04 (.accountCreated)
AUTH 02 ── sign-in, unverified ──▶ AUTH 04 (.signInUnverified, shows notice)
AUTH 02 ── Forgot password? ─────▶ AUTH 05 ── success ──▶ (AUTH 06 pending: .resetLinkSent(email:))
AUTH 03 / 04 / 05 ── Sign in / Back to Sign In ──▶ pop to AUTH 02
AUTH 04 ── Use a different email ──▶ AUTH 03 (pop, or replace when reached from AUTH 02)
AUTH 04 ── I’ve verified (verified) ──▶ signed in (Home; Quick Setup 69 not built)
AUTH 02 ── signed in ──▶ Home
```

No global router; AUTH 04 hides the back button by design.

## Shared components (`RecallMind/DesignSystem/Components/`)

`RMPrimaryButton`, `RMSecondaryButton`, `RMTextButton` (.gold / .secondary), `RMTextField`,
`RMPasswordField`, `RMFieldError`, `RMFieldHint`, `RMErrorBanner`, `RMNotice`, `RMSuccessChip`,
`RMHeroIcon`, `RMLegalFooter`, `RMPressableButtonStyle`, `RMControlMetrics`.
Auth-only: `AuthBanner` / `AuthBannerView` / `.announcesAuthBanner`, `AuthValidation`.

## `AuthRepository`

- `restoreSession() -> User?`
- `signIn(email:password:) -> User` — `invalidCredentials` for unknown email and wrong password
- `signUp(email:password:)` — succeeds for registered emails too (never reveals an account)
- `resendVerificationEmail(to:)`
- `checkEmailVerification(email:) -> User?` — `nil` while unverified
- `requestPasswordReset(email:)` — succeeds for unknown emails too

## `MockAuthRepository` (default app environment)

Every call waits `latency` (400 ms default) and succeeds unless configured:
`user`/`error` (restore), `signInUser`/`signInError`, `signUpError`, `resendError`,
`isEmailVerified` (default `true`) / `verificationError`, `passwordResetError`.
No email is sent; no backend.

Tests use `RecallMindTests/Support/SpyAuthRepository.swift` (records calls, configurable results).

## Tests

52 passing (Swift Testing): AppState 4 · EmailSignIn 15 · CreateAccount 14 · VerifyEmail 11 · ForgotPassword 8.

## Open issues

- Inter fonts not bundled: all weights fall back to SF Pro Regular (titles and emphasis look unbolded).
- `AuthBanner.unexpectedError` has no approved copy; nothing is shown.
- AUTH 04 verified → design goes to 69 Quick Setup; app signs in to Home until it exists.
- AUTH 04 enabled resend label uses AUTH 08's “Resend Email” (artboard only shows the countdown).
- AUTH 03 password field has no placeholder (none in the artboard); email placeholder reuses DS 07 “you@example.com”.
- Expired verification / reset link states (AUTH 08) need deep links; not implemented.
- Terms of Service / Privacy Policy destinations not wired (AUTH 01, AUTH 03).
- Open Mail uses the `message://` URL; no Mail app in the simulator.
- iOS AutoFill shows “Use Strong Password?” on AUTH 03 (`.newPassword`) and save/update prompts after sign-in.
- Not yet checked on a physical iPhone or at large Dynamic Type sizes.

## Next

AUTH 06 Check Your Email (consumes `ForgotPasswordViewModel.Outcome.resetLinkSent`), AUTH 07 Reset Password,
AUTH 07B Password Updated, then remaining AUTH 08 states (expired links, session expired, Apple sign-in).
