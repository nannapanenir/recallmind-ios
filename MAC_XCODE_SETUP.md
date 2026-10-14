# Mac / Xcode Setup

The Xcode project is in the repository. Remaining local steps:

1. **Pull** the latest branch you are working on (`git pull`).
2. **Open** `RecallMind.xcodeproj`.
3. **Signing** — signing is Automatic with no team committed. Simulator builds need no team.
   For a physical device, pick your own Development Team in Signing & Capabilities.
   **Do not commit** the resulting `DEVELOPMENT_TEAM` change in `project.pbxproj`.
4. **Inter fonts** — Inter is **not** bundled yet. Add the Inter Regular, Medium, SemiBold and Bold
   font files to the `RecallMind` target and list them under `UIAppFonts` (Fonts provided by application).
5. **Verify PostScript names** — `RMTypography` expects `Inter-Regular`, `Inter-Medium`,
   `Inter-SemiBold`, `Inter-Bold`. Confirm in Font Book (or `UIFont.familyNames`) and update the
   `InterFace` names in `RMTypography.swift` if they differ. A wrong name silently falls back to SF Pro.
6. **Build** — ⌘B with no warnings or errors.
7. **Test** — ⌘U; all `AppStateTests` must pass.
8. **Simulator** — launch shows the brand mark, then AUTH 01 Welcome (~400 ms mock restore).
   Check Inter text, dark appearance, portrait lock, several iPhone sizes and large Dynamic Type.
9. **Physical iPhone** — repeat the launch and appearance checks on a device.
