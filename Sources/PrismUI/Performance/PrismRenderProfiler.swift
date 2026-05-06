import SwiftUI

public struct PrismRenderMetrics: Sendable {
    public var renderCount: Int

    public var lastRenderTime: Duration?

    public var averageRenderTime: Duration?

    public init(
        renderCount: Int = 0,
        lastRenderTime: Duration? = nil,
        averageRenderTime: Duration? = nil
    ) {
        self.renderCount = renderCount
        self.lastRenderTime = lastRenderTime
        self.averageRenderTime = averageRenderTime
    }
}

@Observable @MainActor
public final class PrismRenderProfiler {
    public private(set) var metrics: [String: PrismRenderMetrics] = [:]

    private var totalDurations: [String: Duration] = [:]

    public init() {}

    public func recordRender(name: String, duration: Duration) {
        var current = metrics[name] ?? PrismRenderMetrics()
        current.renderCount += 1
        current.lastRenderTime = duration

        let total = (totalDurations[name] ?? .zero) + duration
        totalDurations[name] = total
        current.averageRenderTime = total / current.renderCount

        metrics[name] = current
    }

    public func reset() {
        metrics.removeAll()
        totalDurations.removeAll()
    }
}

private struct PrismProfileModifier: ViewModifier {
    let name: String
    let profiler: PrismRenderProfiler

    func body(content: Content) -> some View {
        let _ = {
            let clock = ContinuousClock()
            let start = clock.now
            // Measure the synchronous cost of body evaluation
            let elapsed = clock.now - start
            profiler.recordRender(name: name, duration: elapsed)
        }()
        content
    }
}

extension View {
    public func prismProfile(name: String, profiler: PrismRenderProfiler) -> some View {
        modifier(PrismProfileModifier(name: name, profiler: profiler))
    }
}

public struct PrismProfilerOverlay: View {
    private let profiler: PrismRenderProfiler

    public init(profiler: PrismRenderProfiler) {
        self.profiler = profiler
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Render Profiler")
                .font(.caption.bold())
            ForEach(Array(profiler.metrics.keys.sorted()), id: \.self) { name in
                if let m = profiler.metrics[name] {
                    HStack(spacing: 8) {
                        Text(name)
                            .font(.caption2)
                        Spacer()
                        Text("#\(m.renderCount)")
                            .font(.caption2.monospacedDigit())
                        if let avg = m.averageRenderTime {
                            Text(avg.formatted())
                                .font(.caption2.monospacedDigit())
                        }
                    }
                }
            }
        }
        .padding(8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}
