# Mac / Xcode Setup

The repository contains Swift sources only. The remaining steps need macOS and Xcode.

1. **Create the project** — Xcode → New → App: product name `RecallMind`, SwiftUI, Swift,
   testing system **Swift Testing**, saved at the repository root.
   Delete the template `ContentView.swift` and template `RecallMindApp.swift`.
2. **Add sources** — add `RecallMind/` to the `RecallMind` app target and
   `RecallMindTests/AppStateTests.swift` to the `RecallMindTests` target only.
3. **Deployment** — iOS Deployment Target **17.0**; Supported Destinations **iPhone** only.
4. **Orientation** — Portrait only (`UISupportedInterfaceOrientations` = `UIInterfaceOrientationPortrait`).
5. **Appearance** — Info.plist `UIUserInterfaceStyle` = `Dark`. Do not use `.preferredColorScheme(.dark)` in production code.
6. **Bundle identifier** — set the final RecallMind bundle ID.
7. **Signing** — select the development team; enable automatic signing.
8. **Inter fonts** — Inter is **not** bundled yet. Add the Inter Regular, Medium, SemiBold and Bold
   font files to the app target and list them under `UIAppFonts` (Fonts provided by application).
9. **Verify PostScript names** — `RMTypography` expects `Inter-Regular`, `Inter-Medium`,
   `Inter-SemiBold`, `Inter-Bold`. Confirm in Font Book (or `UIFont.familyNames`) and update the
   `InterFace` names in `RMTypography.swift` if they differ. A wrong name silently falls back to SF Pro.
10. **Build** — ⌘B with no warnings or errors.
11. **Test** — ⌘U; all `AppStateTests` must pass.
12. **Simulator** — launch shows the brand mark, then AUTH 01 Welcome (~400 ms mock restore).
    Check text renders in Inter, dark appearance, portrait lock, several iPhone sizes and large Dynamic Type.
13. **Physical iPhone** — repeat the launch and appearance checks on a device.
