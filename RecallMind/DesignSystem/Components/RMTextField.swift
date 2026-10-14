import SwiftUI

/// DS 07 text field: label above, 54 pt surface field, inline error below.
/// Keyboard, content type and submit behavior are set by the caller.
struct RMTextField<Field: Hashable>: View {
    private let label: String
    private let placeholder: String
    @Binding private var text: String
    private let errorMessage: String?
    private let focus: FocusState<Field?>.Binding
    private let field: Field

    init(
        label: String,
        placeholder: String,
        text: Binding<String>,
        errorMessage: String? = nil,
        focus: FocusState<Field?>.Binding,
        field: Field
    ) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.errorMessage = errorMessage
        self.focus = focus
        self.field = field
    }

    var body: some View {
        VStack(alignment: .leading, spacing: RMSpacing.xs) {
            RMFieldLabel(label)
            TextField(label, text: $text, prompt: RMFieldTypography.prompt(placeholder))
                .font(RMFieldTypography.value)
                .foregroundStyle(RMColors.textPrimary)
                .focused(focus, equals: field)
                .rmFieldChrome(isFocused: focus.wrappedValue == field, isInvalid: errorMessage != nil)
            if let errorMessage {
                RMFieldError(message: errorMessage)
            }
        }
    }
}

/// DS 07 field value: 17 pt Regular (no RMTypography role at this size).
enum RMFieldTypography {
    static let value = Font.custom(InterFace.regular, size: 17, relativeTo: .body)

    static func prompt(_ placeholder: String) -> Text {
        Text(placeholder).foregroundStyle(RMColors.textSecondary)
    }
}

/// Visible field label. Hidden from VoiceOver because the field itself carries the label.
struct RMFieldLabel: View {
    private let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(RMTypography.callout)
            .foregroundStyle(RMColors.textSecondary)
            .accessibilityHidden(true)
    }
}

/// Inline field error: danger symbol + text (never color alone).
struct RMFieldError: View {
    private let message: String

    @ScaledMetric(relativeTo: .callout) private var iconSize: CGFloat = 16

    init(message: String) {
        self.message = message
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: RMSpacing.xs) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: iconSize))
                .accessibilityHidden(true)
            Text(message)
                .font(RMTypography.callout)
        }
        .foregroundStyle(RMColors.danger)
    }
}

/// DS 07 field hint below a field, e.g. a password rule. The check turns success green once the rule is met.
struct RMFieldHint: View {
    private let message: String
    private let isMet: Bool

    @ScaledMetric(relativeTo: .callout) private var iconSize: CGFloat = 16

    init(_ message: String, isMet: Bool) {
        self.message = message
        self.isMet = isMet
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: RMSpacing.xs) {
            Image(systemName: "checkmark")
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(isMet ? RMColors.success : RMColors.textSecondary)
                .accessibilityHidden(true)
            Text(message)
                .font(RMTypography.callout)
                .foregroundStyle(RMColors.textSecondary)
        }
    }
}

extension View {
    /// DS 07 field container: surface fill, hairline border; gold when focused, danger when invalid.
    func rmFieldChrome(isFocused: Bool, isInvalid: Bool, trailingPadding: CGFloat = RMSpacing.md) -> some View {
        let shape = RoundedRectangle(cornerRadius: RMRadius.md, style: .continuous)
        let borderColor = isInvalid ? RMColors.danger : (isFocused ? RMColors.gold : RMColors.border)
        let borderWidth = isInvalid || isFocused ? RMControlMetrics.emphasisBorderWidth : RMControlMetrics.borderWidth

        return self
            .padding(.leading, RMSpacing.md)
            .padding(.trailing, trailingPadding)
            .frame(minHeight: RMControlMetrics.height)
            .background(RMColors.surface, in: shape)
            .overlay(shape.strokeBorder(borderColor, lineWidth: borderWidth))
            .tint(RMColors.gold)
    }
}
