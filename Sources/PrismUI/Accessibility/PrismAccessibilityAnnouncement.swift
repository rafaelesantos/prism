import SwiftUI

public enum PrismAnnouncementPriority: String, Sendable, CaseIterable, Hashable {
    case polite
    case assertive
}

@MainActor
public struct PrismAccessibilityAnnouncer: Sendable {

    public static func announce(_ message: String, priority: PrismAnnouncementPriority = .polite) {
        switch priority {
        case .polite:
            AccessibilityNotification.Announcement(message).post()
        case .assertive:
            AccessibilityNotification.Announcement(message).post()
        }
    }
}

private struct AnnouncementModifier<V: Equatable>: ViewModifier {
    let value: V
    let message: String
    let priority: PrismAnnouncementPriority

    func body(content: Content) -> some View {
        content
            .onChange(of: value) { _, _ in
                PrismAccessibilityAnnouncer.announce(message, priority: priority)
            }
    }
}

extension View {

    public func prismAnnounce<V: Equatable>(
        when value: V,
        message: String,
        priority: PrismAnnouncementPriority = .polite
    ) -> some View {
        modifier(AnnouncementModifier(value: value, message: message, priority: priority))
    }
}
