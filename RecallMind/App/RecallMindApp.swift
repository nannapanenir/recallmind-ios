import SwiftUI

@main
struct RecallMindApp: App {
    @State private var appState = AppState()
    private let environment = AppEnvironment.mock

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .environment(\.appEnvironment, environment)
        }
    }
}
