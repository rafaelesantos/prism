import SwiftUI

/// In-app push-style notification banner with swipe-to-dismiss.
///
/// ```swift
/// @State private var notification: PrismNotificationBanner.Content?
///
/// ContentView()
///     .prismNotificationBanner($notification)
/// ```
public struct PrismNotificationBanner: View {
    @Environment(\.prismTheme) private var theme
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1

    let content: Content
    let onDismiss: () -> Void

    public var body: some View {
        HStack(spacing: SpacingToken.md.rawValue) {
            Image(systemName: content.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(iconColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(content.title)
                    .font(TypographyToken.subheadline.font(weight: .semibold))
                    .foregroundStyle(theme.color(.onSurface))

                if let message = content.message {
                    Text(message)
                        .font(TypographyToken.caption.font)
                        .foregroundStyle(theme.color(.onBackgroundSecondary))
                        .lineLimit(2)
                }
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(theme.color(.onBackgroundTertiary))
            }
        }
        .padding(SpacingToken.md.rawValue)
        .background(theme.color(.surface), in: RadiusToken.lg.shape)
        .prismElevation(.high)
        .padding(.horizontal, SpacingToken.md.rawValue)
        .offset(y: offset)
        .opacity(opacity)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.height < 0 {
                        offset = value.translation.height
                    }
                }
                .onEnded { value in
                    if value.translation.height < -50 {
                        dismiss()
                    } else {
                        withAnimation(.snappy) {
                            offset = 0
                        }
                    }
                }
        )
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    private var iconColor: Color {
        switch content.style {
        case .info: theme.color(.info)
        case .success: theme.color(.success)
        case .warning: theme.color(.warning)
        case .error: theme.color(.error)
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.2)) {
            offset = -100
            opacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onDismiss()
        }
    }

    public struct Content: @unchecked Sendable {
        public let title: LocalizedStringKey
        public let message: LocalizedStringKey?
        public let icon: String
        public let style: Style
        public let duration: TimeInterval

        public init(
            _ title: LocalizedStringKey,
            message: LocalizedStringKey? = nil,
            icon: String = "bell.fill",
            style: Style = .info,
            duration: TimeInterval = 4
        ) {
            self.title = title
            self.message = message
            self.icon = icon
            self.style = style
            self.duration = duration
        }

        public enum Style: Sendable {
            case info, success, warning, error
        }
    }
}

// MARK: - Modifier

private struct PrismNotificationBannerModifier: ViewModifier {
    @Binding var content: PrismNotificationBanner.Content?

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content

            if let notification = self.content {
                PrismNotificationBanner(content: notification) {
                    self.content = nil
                }
                .padding(.top, SpacingToken.sm.rawValue)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + notification.duration) {
                        withAnimation {
                            self.content = nil
                        }
                    }
                }
            }
        }
    }
}

extension View {

    /// Presents an in-app notification banner.
    public func prismNotificationBanner(
        _ content: Binding<PrismNotificationBanner.Content?>
    ) -> some View {
        modifier(PrismNotificationBannerModifier(content: content))
    }
}
