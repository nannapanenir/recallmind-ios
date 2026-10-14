import SwiftUI
import UIKit

/// DS 07 password field: masked by default, eye / eye.slash toggle in a 44 pt target.
struct RMPasswordField<Field: Hashable>: View {
    private let label: String
    private let placeholder: String
    @Binding private var text: String
    @Binding private var isRevealed: Bool
    private let errorMessage: String?
    private let contentType: UITextContentType
    private let focus: FocusState<Field?>.Binding
    private let field: Field

    @ScaledMetric(relativeTo: .body) private var eyeSize: CGFloat = 22

    init(
        label: String,
        placeholder: String,
        text: Binding<String>,
        isRevealed: Binding<Bool>,
        errorMessage: String? = nil,
        contentType: UITextContentType = .password,
        focus: FocusState<Field?>.Binding,
        field: Field
    ) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self._isRevealed = isRevealed
        self.errorMessage = errorMessage
        self.contentType = contentType
        self.focus = focus
        self.field = field
    }

    var body: some View {
        VStack(alignment: .leading, spacing: RMSpacing.xs) {
            RMFieldLabel(label)
            HStack(spacing: 0) {
                input
                    .font(RMFieldTypography.value)
                    .foregroundStyle(RMColors.textPrimary)
                    .textContentType(contentType)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused(focus, equals: field)
                    .frame(maxWidth: .infinity, minHeight: RMControlMetrics.height)

                Button(action: toggleReveal) {
                    Image(systemName: isRevealed ? "eye.slash" : "eye")
                        .font(.system(size: eyeSize))
                        .foregroundStyle(isRevealed ? RMColors.textPrimary : RMColors.textSecondary)
                        .frame(width: RMControlMetrics.minTouchTarget, height: RMControlMetrics.minTouchTarget)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isRevealed ? "Hide password" : "Show password")
            }
            .rmFieldChrome(
                isFocused: focus.wrappedValue == field,
                isInvalid: errorMessage != nil,
                trailingPadding: RMSpacing.xxs
            )
            if let errorMessage {
                RMFieldError(message: errorMessage)
            }
        }
    }

    @ViewBuilder
    private var input: some View {
        if isRevealed {
            TextField(label, text: $text, prompt: RMFieldTypography.prompt(placeholder))
        } else {
            SecureField(label, text: $text, prompt: RMFieldTypography.prompt(placeholder))
        }
    }

    private func toggleReveal() {
        let wasFocused = focus.wrappedValue == field
        isRevealed.toggle()
        // Swapping SecureField and TextField drops focus; restore it.
        if wasFocused {
            focus.wrappedValue = field
        }
    }
}
