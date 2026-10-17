import SwiftUI

/// Decorative hero symbol for confirmation screens: a symbol in a tinted circle with a hairline.
/// `.gold` for informational screens (AUTH 04, AUTH 06), `.success` for completion (AUTH 07B).
/// Hidden from VoiceOver.
struct RMHeroIcon: View {
    enum Style {
        case gold
        case success
    }

    private let systemImage: String
    private let style: Style

    @ScaledMetric(relativeTo: .largeTitle) private var diameter: CGFloat = 72
    @ScaledMetric(relativeTo: .largeTitle) private var symbolSize: CGFloat = 32

    init(systemImage: String, style: Style = .gold) {
        self.systemImage = systemImage
        self.style = style
    }

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: symbolSize, weight: style == .success ? .semibold : .regular))
            .foregroundStyle(accent)
            .frame(width: diameter, height: diameter)
            .background(tint, in: Circle())
            .overlay(Circle().strokeBorder(accent, lineWidth: RMControlMetrics.borderWidth))
            .accessibilityHidden(true)
    }

    private var accent: Color {
        style == .success ? RMColors.success : RMColors.gold
    }

    private var tint: Color {
        style == .success ? RMColors.successTint : RMColors.goldTint
    }
}

#Preview {
    HStack(spacing: RMSpacing.xl) {
        RMHeroIcon(systemImage: "envelope")
        RMHeroIcon(systemImage: "checkmark", style: .success)
    }
    .padding(RMSpacing.readingInset)
    .background(RMColors.background)
    .preferredColorScheme(.dark)
}
