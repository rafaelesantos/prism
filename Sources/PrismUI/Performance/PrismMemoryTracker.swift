import SwiftUI

public struct PrismMemorySnapshot: Sendable {
    public let timestamp: Date

    public let usedBytes: UInt64

    public let peakBytes: UInt64

    public init(timestamp: Date, usedBytes: UInt64, peakBytes: UInt64) {
        self.timestamp = timestamp
        self.usedBytes = usedBytes
        self.peakBytes = peakBytes
    }
}

@Observable @MainActor
public final class PrismMemoryTrackerV2 {
    public private(set) var snapshots: [PrismMemorySnapshot] = []

    public var currentUsage: UInt64 {
        snapshots.last?.usedBytes ?? 0
    }

    public init() {}

    @discardableResult
    public func takeSnapshot() -> PrismMemorySnapshot {
        let snapshot = Self.readMemory()
        snapshots.append(snapshot)
        return snapshot
    }

    public func reset() {
        snapshots.removeAll()
    }

    private static func readMemory() -> PrismMemorySnapshot {
        #if canImport(Darwin)
            var info = mach_task_basic_info()
            var count =
                mach_msg_type_number_t(
                    MemoryLayout<mach_task_basic_info>.size
                ) / 4
            let result = withUnsafeMutablePointer(to: &info) { infoPtr in
                infoPtr.withMemoryRebound(
                    to: integer_t.self, capacity: Int(count)
                ) { ptr in
                    task_info(
                        mach_task_self_,
                        task_flavor_t(MACH_TASK_BASIC_INFO),
                        ptr,
                        &count
                    )
                }
            }
            if result == KERN_SUCCESS {
                return PrismMemorySnapshot(
                    timestamp: Date(),
                    usedBytes: UInt64(info.resident_size),
                    peakBytes: UInt64(info.resident_size_max)
                )
            }
        #endif
        return PrismMemorySnapshot(timestamp: Date(), usedBytes: 0, peakBytes: 0)
    }
}

private struct PrismTrackMemoryModifier: ViewModifier {
    let tracker: PrismMemoryTrackerV2

    func body(content: Content) -> some View {
        let _ = tracker.takeSnapshot()
        content
    }
}

extension View {
    public func prismTrackMemory(tracker: PrismMemoryTrackerV2) -> some View {
        modifier(PrismTrackMemoryModifier(tracker: tracker))
    }
}
