import SwiftUI

/// RecallMind waveform brand mark, drawn as scalable vector bars.
/// Decorative: hidden from VoiceOver.
struct RMBrandMark: View {
    enum Style {
        case gold
        case muted
    }

    var style: Style = .gold
    var height: CGFloat = RMBrandMarkShape.canvasSize.height

    var body: some View {
        RMBrandMarkShape()
            .fill(color)
            .frame(width: height * RMBrandMarkShape.aspectRatio, height: height)
            .accessibilityHidden(true)
    }

    private var color: Color {
        switch style {
        case .gold: RMColors.gold
        case .muted: RMColors.textSecondary
        }
    }
}

/// Approved geometry: 59 × 44 canvas, 7 bars, 5 wide, 4 gap, 2.5 corner radius.
struct RMBrandMarkShape: Shape {
    static let canvasSize = CGSize(width: 59, height: 44)
    static let aspectRatio = canvasSize.width / canvasSize.height

    private static let barWidth: CGFloat = 5
    private static let barGap: CGFloat = 4
    private static let cornerRadius: CGFloat = 2.5
    private static let barHeights: [CGFloat] = [14, 28, 44, 22, 36, 18, 30]

    func path(in rect: CGRect) -> Path {
        let canvas = Self.canvasSize
        // Uniform scale preserves the aspect ratio; the mark is centered in `rect`.
        let scale = min(rect.width / canvas.width, rect.height / canvas.height)
        let originX = rect.midX - canvas.width * scale / 2
        let originY = rect.midY - canvas.height * scale / 2

        var path = Path()
        for (index, barHeight) in Self.barHeights.enumerated() {
            let x = CGFloat(index) * (Self.barWidth + Self.barGap)
            // Bars are centered on the canvas's horizontal midline (verified against AUTH 01).
            let y = (canvas.height - barHeight) / 2
            let bar = CGRect(
                x: originX + x * scale,
                y: originY + y * scale,
                width: Self.barWidth * scale,
                height: barHeight * scale
            )
            let radius = Self.cornerRadius * scale
            path.addRoundedRect(in: bar, cornerSize: CGSize(width: radius, height: radius))
        }
        return path
    }
}

#Preview {
    VStack(spacing: RMSpacing.xxl) {
        RMBrandMark()
        RMBrandMark(style: .muted)
        RMBrandMark(height: 88)
    }
    .padding(RMSpacing.xxxl)
    .background(RMColors.background)
    .preferredColorScheme(.dark)
}
