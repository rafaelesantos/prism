import SwiftUI

public enum PrismMessageStatus: String, Sendable, CaseIterable {
    case sending
    case sent
    case delivered
    case read
    case failed
}

public struct PrismMessage: Identifiable, Sendable, Equatable {
    public let id: UUID
    public let text: String
    public let sender: String
    public let timestamp: Date
    public let isOutgoing: Bool
    public let status: PrismMessageStatus

    public init(
        id: UUID = UUID(),
        text: String,
        sender: String,
        timestamp: Date = .now,
        isOutgoing: Bool = false,
        status: PrismMessageStatus = .sent
    ) {
        self.id = id
        self.text = text
        self.sender = sender
        self.timestamp = timestamp
        self.isOutgoing = isOutgoing
        self.status = status
    }
}

public struct PrismMessageGroup: Identifiable, Sendable {
    public var id: UUID { messages.first?.id ?? UUID() }
    public let sender: String
    public let isOutgoing: Bool
    public let messages: [PrismMessage]

    public init(sender: String, isOutgoing: Bool, messages: [PrismMessage]) {
        self.sender = sender
        self.isOutgoing = isOutgoing
        self.messages = messages
    }
}

@MainActor
public struct PrismMessageList: View {
    @Environment(\.prismTheme) private var theme

    private let messages: [PrismMessage]
    private let bubbleStyle: PrismBubbleStyle

    public init(messages: [PrismMessage], bubbleStyle: PrismBubbleStyle = .filled) {
        self.messages = messages
        self.bubbleStyle = bubbleStyle
    }

    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: SpacingToken.sm.rawValue) {
                    ForEach(groupedByDate, id: \.key) { date, dayMessages in
                        dateSeparator(for: date)

                        ForEach(groupConsecutive(dayMessages)) { group in
                            messageGroupView(group)
                        }
                    }
                }
                .padding(.horizontal, SpacingToken.md.rawValue)
                .padding(.vertical, SpacingToken.sm.rawValue)
            }
            .onChange(of: messages.count) {
                if let lastID = messages.last?.id {
                    withAnimation(.easeOut(duration: 0.25)) {
                        proxy.scrollTo(lastID, anchor: .bottom)
                    }
                }
            }
        }
        .accessibilityLabel("Message list, \(messages.count) messages")
    }

    // MARK: - Subviews

    private func dateSeparator(for date: String) -> some View {
        Text(date)
            .font(TypographyToken.caption.font(weight: .medium))
            .foregroundStyle(theme.color(.onBackgroundSecondary))
            .padding(.vertical, SpacingToken.sm.rawValue)
            .frame(maxWidth: .infinity)
            .accessibilityAddTraits(.isHeader)
    }

    private func messageGroupView(_ group: PrismMessageGroup) -> some View {
        VStack(alignment: group.isOutgoing ? .trailing : .leading, spacing: 2) {
            if !group.isOutgoing {
                Text(group.sender)
                    .font(TypographyToken.caption.font(weight: .semibold))
                    .foregroundStyle(theme.color(.brand))
                    .padding(.horizontal, SpacingToken.sm.rawValue)
            }

            ForEach(group.messages) { message in
                PrismChatBubble(
                    text: message.text,
                    timestamp: message.timestamp,
                    isOutgoing: message.isOutgoing,
                    style: bubbleStyle,
                    status: message.status
                )
                .id(message.id)
            }
        }
    }

    // MARK: - Helpers

    private var groupedByDate: [(key: String, value: [PrismMessage])] {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        let grouped = Dictionary(grouping: messages) { formatter.string(from: $0.timestamp) }
        return grouped.sorted { lhs, rhs in
            guard let l = lhs.value.first?.timestamp, let r = rhs.value.first?.timestamp else {
                return false
            }
            return l < r
        }
    }

    private func groupConsecutive(_ messages: [PrismMessage]) -> [PrismMessageGroup] {
        var groups: [PrismMessageGroup] = []
        var current: [PrismMessage] = []

        for message in messages {
            if let last = current.last, last.sender == message.sender {
                current.append(message)
            } else {
                if let first = current.first {
                    groups.append(
                        PrismMessageGroup(
                            sender: first.sender,
                            isOutgoing: first.isOutgoing,
                            messages: current
                        ))
                }
                current = [message]
            }
        }

        if let first = current.first {
            groups.append(
                PrismMessageGroup(
                    sender: first.sender,
                    isOutgoing: first.isOutgoing,
                    messages: current
                ))
        }

        return groups
    }
}
