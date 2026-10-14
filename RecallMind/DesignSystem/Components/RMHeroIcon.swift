import SwiftUI

/// Decorative hero symbol for confirmation screens (AUTH 04, AUTH 06):
/// gold symbol in a gold-tint circle with a gold hairline. Hidden from VoiceOver.
struct RMHeroIcon: View {
    private let systemImage: String

    @ScaledMetric(relativeTo: .largeTitle) private var diameter: CGFloat = 72
    @ScaledMetric(relativeTo: .largeTitle) private var symbolSize: CGFloat = 32

    init(systemImage: String) {
        self.systemImage = systemImage
    }

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: symbolSize))
            .foregroundStyle(RMColors.gold)
            .frame(width: diameter, height: diameter)
            .background(RMColors.goldTint, in: Circle())
            .overlay(Circle().strokeBorder(RMColors.gold, lineWidth: RMControlMetrics.borderWidth))
            .accessibilityHidden(true)
    }
}

#Preview {
    RMHeroIcon(systemImage: "envelope")
        .padding(RMSpacing.readingInset)
        .background(RMColors.background)
        .preferredColorScheme(.dark)
}
