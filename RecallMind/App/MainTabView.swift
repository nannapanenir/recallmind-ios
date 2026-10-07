import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            PlaceholderTab(title: "Home")
                .tabItem { Label("Home", systemImage: "house") }

            PlaceholderTab(title: "Notes")
                .tabItem { Label("Notes", systemImage: "note.text") }

            PlaceholderTab(title: "Settings")
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}

/// Temporary signed-in placeholder until the real feature screens exist.
private struct PlaceholderTab: View {
    let title: String

    var body: some View {
        NavigationStack {
            ZStack {
                RMColors.background.ignoresSafeArea()
                Text(title)
                    .font(RMTypography.title)
                    .foregroundStyle(RMColors.textSecondary)
            }
            .navigationTitle(title)
        }
    }
}

#Preview {
    MainTabView()
        .preferredColorScheme(.dark)
}
