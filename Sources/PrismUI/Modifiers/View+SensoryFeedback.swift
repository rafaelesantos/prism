import SwiftUI

public enum PrismSensoryFeedback: Sendable {
    case success
    case warning
    case error
    case selection
    case increase
    case decrease
    case start
    case stop
    case alignment
    case levelChange
    case impact

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    var native: SensoryFeedback {
        switch self {
        case .success: .success
        case .warning: .warning
        case .error: .error
        case .selection: .selection
        case .increase: .increase
        case .decrease: .decrease
        case .start: .start
        case .stop: .stop
        case .alignment: .alignment
        case .levelChange: .levelChange
        case .impact: .impact
        }
    }
}

extension View {

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    public func prismSensoryFeedback<T: Equatable>(
        _ feedback: PrismSensoryFeedback,
        trigger: T
    ) -> some View {
        sensoryFeedback(feedback.native, trigger: trigger)
    }
}
