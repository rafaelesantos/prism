#if canImport(SwiftData)
    import Foundation
    import SwiftData

    @Model
    public final class PrismAnalyticsRecord {
        @Attribute(.unique)
        public var recordID: String

        public var eventType: String

        public var entityID: String

        public var timestamp: Date

        public var metadata: String

        public var completionDuration: Double?

        public init(
            recordID: String = UUID().uuidString,
            eventType: String,
            entityID: String,
            timestamp: Date = .now,
            metadata: String = "{}",
            completionDuration: Double? = nil
        ) {
            self.recordID = recordID
            self.eventType = eventType
            self.entityID = entityID
            self.timestamp = timestamp
            self.metadata = metadata
            self.completionDuration = completionDuration
        }
    }
#endif
