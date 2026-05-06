import PrismFoundation
import SwiftUI

private struct AnalyticsTrackModifier: ViewModifier {
    @Environment(\.prismAnalyticsProvider) private var provider
    let event: PrismAnalyticsEvent

    func body(content: Content) -> some View {
        content.onAppear {
            provider?.track(event)
        }
    }
}

// MARK: - Environment

private struct PrismAnalyticsProviderKey: @preconcurrency EnvironmentKey {
    @MainActor static let defaultValue: (any PrismAnalyticsProvider)? = nil
}

extension EnvironmentValues {
    public var prismAnalyticsProvider: (any PrismAnalyticsProvider)? {
        get { self[PrismAnalyticsProviderKey.self] }
        set { self[PrismAnalyticsProviderKey.self] = newValue }
    }
}

extension View {

    public func prismAnalytics(_ provider: some PrismAnalyticsProvider) -> some View {
        environment(\.prismAnalyticsProvider, provider)
    }

    public func prismTrack(_ event: PrismAnalyticsEvent) -> some View {
        modifier(AnalyticsTrackModifier(event: event))
    }

    public func prismTrackScreen(_ name: String) -> some View {
        modifier(AnalyticsTrackModifier(event: .screenView(name: name)))
    }
}
