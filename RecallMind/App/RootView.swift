import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.appEnvironment) private var environment

    var body: some View {
        Group {
            switch appState.authStatus {
            case .unknown:
                LaunchView()
            case .signedOut:
                AuthenticationFlowView()
            case .signedIn:
                MainTabView()
            }
        }
        .task {
            guard appState.authStatus == .unknown else { return }
            await appState.restoreSession(using: environment.authRepository)
        }
    }
}

private struct LaunchView: View {
    var body: some View {
        ZStack {
            RMColors.background.ignoresSafeArea()
            RMBrandMark()
        }
    }
}

#Preview {
    RootView()
        .environment(AppState())
        .preferredColorScheme(.dark)
}
