#if canImport(MetricKit)
    import MetricKit

    // MARK: - App Metrics

    public struct PrismAppMetrics: Sendable {
        public let launchDuration: Double?
        public let hangDuration: Double?
        public let peakMemory: Double?
        public let cpuTime: Double?
        public let diskWrites: Double?

        public init(
            launchDuration: Double? = nil, hangDuration: Double? = nil, peakMemory: Double? = nil,
            cpuTime: Double? = nil, diskWrites: Double? = nil
        ) {
            self.launchDuration = launchDuration
            self.hangDuration = hangDuration
            self.peakMemory = peakMemory
            self.cpuTime = cpuTime
            self.diskWrites = diskWrites
        }
    }

    // MARK: - Crash Diagnostic

    public struct PrismCrashDiagnostic: Sendable {
        public let id: UUID
        public let timestamp: Date
        public let exceptionType: String?
        public let signal: String?
        public let terminationReason: String?
        public let callStackTree: String?

        public init(
            id: UUID = UUID(), timestamp: Date, exceptionType: String? = nil, signal: String? = nil,
            terminationReason: String? = nil, callStackTree: String? = nil
        ) {
            self.id = id
            self.timestamp = timestamp
            self.exceptionType = exceptionType
            self.signal = signal
            self.terminationReason = terminationReason
            self.callStackTree = callStackTree
        }
    }

    // MARK: - MetricKit Client

    @MainActor @Observable
    public final class PrismMetricKitClient: NSObject, MXMetricManagerSubscriber {
        public private(set) var latestMetrics: PrismAppMetrics?
        public private(set) var crashDiagnostics: [PrismCrashDiagnostic] = []

        public override init() {
            super.init()
        }

        public func startReceiving() {
            MXMetricManager.shared.add(self)
        }

        public func stopReceiving() {
            MXMetricManager.shared.remove(self)
        }

        // MARK: - MXMetricManagerSubscriber

        nonisolated public func didReceive(_ payloads: [MXMetricPayload]) {
            let metrics = payloads.last.map { payload in
                PrismAppMetrics(
                    launchDuration: payload.applicationLaunchMetrics?.histogrammedTimeToFirstDraw.bucketEnumerator
                        .allObjects.isEmpty == false ? 1.0 : nil,
                    hangDuration: nil,
                    peakMemory: nil,
                    cpuTime: nil,
                    diskWrites: nil
                )
            }
            Task { @MainActor in
                self.latestMetrics = metrics
            }
        }

        nonisolated public func didReceive(_ payloads: [MXDiagnosticPayload]) {
            let diagnostics = payloads.flatMap { payload in
                (payload.crashDiagnostics ?? []).map { crash in
                    PrismCrashDiagnostic(
                        timestamp: payload.timeStampEnd,
                        exceptionType: crash.exceptionType?.description,
                        signal: crash.signal?.description,
                        terminationReason: crash.terminationReason,
                        callStackTree: String(
                            data: (try? crash.callStackTree.jsonRepresentation()) ?? Data(), encoding: .utf8)
                    )
                }
            }
            Task { @MainActor in
                self.crashDiagnostics.append(contentsOf: diagnostics)
            }
        }
    }
#endif
