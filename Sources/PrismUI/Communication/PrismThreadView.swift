import SwiftUI

public struct PrismThread: Identifiable, Sendable, Equatable {
    public let id: UUID
    public let rootMessage: PrismMessage
    public let replies: [PrismMessage]
    public let replyCount: Int

    public init(
        id: UUID = UUID(),
        rootMessage: PrismMessage,
        replies: [PrismMessage] = [],
        replyCount: Int? = nil
    ) {
        self.id = id
        self.rootMessage = rootMessage
        self.replies = replies
        self.replyCount = replyCount ?? replies.count
    }
}

@MainActor
public struct PrismThreadView: View {
    @Environment(\.prismTheme) private var theme

    private let thread: PrismThread
    private let bubbleStyle: PrismBubbleStyle

    @State private var isExpanded: Bool

    public init(thread: PrismThread, bubbleStyle: PrismBubbleStyle = .filled, expanded: Bool = false) {
        self.thread = thread
        self.bubbleStyle = bubbleStyle
        self._isExpanded = State(initialValue: expanded)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.sm.rawValue) {
            PrismChatBubble(
                text: thread.rootMessage.text,
                timestamp: thread.rootMessage.timestamp,
                isOutgoing: thread.rootMessage.isOutgoing,
                style: bubbleStyle,
                status: thread.rootMessage.status
            )

            if thread.replyCount > 0 {
                replyToggle

                if isExpanded {
                    repliesList
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isExpanded)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Thread with \(thread.replyCount) replies")
    }

    // MARK: - Subviews

    private var replyToggle: some View {
        Button {
            isExpanded.toggle()
        } label: {
            HStack(spacing: SpacingToken.xs.rawValue) {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.system(size: 12, weight: .semibold))

                Text("\(thread.replyCount) \(thread.replyCount == 1 ? "reply" : "replies")")
                    .font(TypographyToken.caption.font(weight: .medium))
            }
            .foregroundStyle(theme.color(.brand))
            .padding(.leading, SpacingToken.lg.rawValue)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(thread.replyCount) replies, \(isExpanded ? "collapse" : "expand")")
        .accessibilityHint("Double-tap to \(isExpanded ? "collapse" : "expand") replies")
    }

    private var repliesList: some View {
        VStack(spacing: 2) {
            ForEach(thread.replies) { reply in
                PrismChatBubble(
                    text: reply.text,
                    timestamp: reply.timestamp,
                    isOutgoing: reply.isOutgoing,
                    style: bubbleStyle,
                    status: reply.status
                )
            }
        }
        .padding(.leading, SpacingToken.xl.rawValue)
    }
}
