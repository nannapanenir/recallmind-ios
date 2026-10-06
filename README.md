# RecallMind iOS

**Listen. Learn. Remember.**

RecallMind is an iPhone-first learning and memory application that turns
recorded or uploaded audio into structured, searchable knowledge.

The core product flow is:

Record / Upload
→ Transcribe
→ Understand
→ Ask AI
→ Study
→ Recall

---

## Platform

RecallMind v1 focuses exclusively on:

- iPhone
- iOS
- Native SwiftUI

Web and iPad versions are deferred until after the initial iPhone release.

---

## Technology

- Swift
- SwiftUI
- Swift Concurrency / async-await
- Supabase Auth
- Supabase PostgreSQL
- Supabase Storage
- Supabase Row Level Security
- Sign in with Apple
- AVFoundation
- SwiftData where appropriate
- Keychain
- StoreKit 2
- UserNotifications / APNs
- URLSession
- Swift Package Manager

---

## Authentication

RecallMind v1 supports:

- Sign in with Apple
- Email + Password

Authentication is provided by Supabase Auth.

User-facing features should never reference Supabase directly.

---

## Architecture

RecallMind uses a feature-first SwiftUI architecture with MVVM.

```text
RecallMind/
│
├── App/
│
├── Features/
│   ├── Authentication/
│   ├── Onboarding/
│   ├── Home/
│   ├── Recording/
│   ├── Upload/
│   ├── Processing/
│   ├── Notes/
│   ├── Transcript/
│   ├── AskAI/
│   ├── Study/
│   ├── Search/
│   ├── Notifications/
│   ├── Account/
│   ├── Settings/
│   └── Premium/
│
├── Domain/
├── Data/
├── Core/
├── DesignSystem/
├── Resources/
└── Extensions/
