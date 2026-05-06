//
//  PrismAnalytics.swift
//  Prism
//
//  Created by Rafael Escaleira on 27/04/26.
//

import Foundation

public protocol PrismAnalyticsProvider: Sendable {
    func track(_ event: PrismAnalyticsEvent)
}

public struct PrismAnalyticsEvent: Sendable, Equatable {
    public let name: String
    public let parameters: [String: String]
    public let timestamp: Date

    public init(
        name: String,
        parameters: [String: String] = [:],
        timestamp: Date = .now
    ) {
        self.name = name
        self.parameters = parameters
        self.timestamp = timestamp
    }
}

// MARK: - Event Categories

extension PrismAnalyticsEvent {
    public static func buttonTap(
        label: String,
        testID: String = ""
    ) -> PrismAnalyticsEvent {
        PrismAnalyticsEvent(
            name: "button_tap",
            parameters: [
                "label": label,
                "test_id": testID,
            ]
        )
    }

    public static func screenView(
        name: String,
        route: String = ""
    ) -> PrismAnalyticsEvent {
        PrismAnalyticsEvent(
            name: "screen_view",
            parameters: [
                "screen_name": name,
                "route": route,
            ]
        )
    }

    public static func fieldInteraction(
        testID: String,
        action: String
    ) -> PrismAnalyticsEvent {
        PrismAnalyticsEvent(
            name: "field_interaction",
            parameters: [
                "test_id": testID,
                "action": action,
            ]
        )
    }

    public static func carouselScroll(
        testID: String,
        index: Int
    ) -> PrismAnalyticsEvent {
        PrismAnalyticsEvent(
            name: "carousel_scroll",
            parameters: [
                "test_id": testID,
                "index": String(index),
            ]
        )
    }

    public static func tabSelect(
        testID: String,
        tab: String
    ) -> PrismAnalyticsEvent {
        PrismAnalyticsEvent(
            name: "tab_select",
            parameters: [
                "test_id": testID,
                "tab": tab,
            ]
        )
    }

    public static func menuAction(
        testID: String,
        action: String
    ) -> PrismAnalyticsEvent {
        PrismAnalyticsEvent(
            name: "menu_action",
            parameters: [
                "test_id": testID,
                "action": action,
            ]
        )
    }

    public static func custom(
        _ name: String,
        parameters: [String: String] = [:]
    ) -> PrismAnalyticsEvent {
        PrismAnalyticsEvent(name: name, parameters: parameters)
    }
}
