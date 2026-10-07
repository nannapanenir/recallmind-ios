import SwiftUI

/// Placeholder root for the signed-out flow. AUTH 01–08 are not implemented yet.
struct AuthenticationFlowView: View {
    var body: some View {
        ZStack {
            RMColors.background.ignoresSafeArea()
            VStack(spacing: RMSpacing.md) {
                RMBrandMark()
                Text("RecallMind")
                    .font(RMTypography.titleLarge)
                    .foregroundStyle(RMColors.textPrimary)
            }
            .padding(.horizontal, RMSpacing.pageInset)
        }
    }
}

#Preview {
    AuthenticationFlowView()
        .preferredColorScheme(.dark)
}
