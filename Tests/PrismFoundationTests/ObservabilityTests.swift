import Foundation
import Testing

@testable import PrismFoundation

@Suite("Observability")
struct ObservabilityTests {

    // MARK: - PrismLogLevel

    @Test
    func logLevelOrderingTraceIsLessThanCritical() {
        #expect(PrismLogLevel.trace < PrismLogLevel.critical)
    }

    @Test
    func logLevelHasSixCases() {
        #expect(PrismLogLevel.allCases.count == 6)
    }

    @Test
    func logLevelFullOrdering() {
        let levels = PrismLogLevel.allCases.sorted()
        #expect(levels == [.trace, .debug, .info, .warning, .error, .critical])
    }

    // MARK: - PrismLogEntry

    @Test
    func logEntryStoresAllProperties() {
        let date = Date.now
        let entry = PrismLogEntry(
            level: .warning,
            message: "disk full",
            category: "storage",
            metadata: ["partition": "/dev/sda1"],
            timestamp: date,
            file: "Test.swift",
            line: 42
        )

        #expect(entry.level == .warning)
        #expect(entry.message == "disk full")
        #expect(entry.category == "storage")
        #expect(entry.metadata["partition"] == "/dev/sda1")
        #expect(entry.timestamp == date)
        #expect(entry.file == "Test.swift")
        #expect(entry.line == 42)
    }

    // MARK: - PrismStructuredLogger

    @Test
    func structuredLoggerLogsEntry() async {
        let logger = PrismStructuredLogger()
        await logger.info("server started", category: "boot")
        let entries = await logger.entries
        #expect(entries.count == 1)
        #expect(entries.first?.message == "server started")
        #expect(entries.first?.level == .info)
        #expect(entries.first?.category == "boot")
    }

    @Test
    func structuredLoggerMinimumLevelFilter() async {
        let logger = PrismStructuredLogger(minimumLevel: .warning)
        await logger.debug("hidden")
        await logger.info("also hidden")
        await logger.warning("visible")
        await logger.error("also visible")
        let entries = await logger.entries
        #expect(entries.count == 2)
        #expect(entries[0].level == .warning)
        #expect(entries[1].level == .error)
    }

    @Test
    func structuredLoggerBufferLimit() async {
        let logger = PrismStructuredLogger(maxEntries: 3)
        await logger.info("one")
        await logger.info("two")
        await logger.info("three")
        await logger.info("four")
        let entries = await logger.entries
        #expect(entries.count == 3)
        #expect(entries.first?.message == "two")
    }

    @Test
    func structuredLoggerConvenienceMethods() async {
        let logger = PrismStructuredLogger()
        await logger.trace("t")
        await logger.debug("d")
        await logger.info("i")
        await logger.warning("w")
        await logger.error("e")
        await logger.critical("c")
        let entries = await logger.entries
        #expect(entries.count == 6)
        #expect(entries.map(\.level) == [.trace, .debug, .info, .warning, .error, .critical])
    }

    // MARK: - PrismCrashReport

    @Test
    func crashReportStoresProperties() {
        let id = UUID()
        let date = Date.now
        let report = PrismCrashReport(
            id: id,
            message: "EXC_BAD_ACCESS",
            stackTrace: "frame #0",
            timestamp: date,
            appVersion: "2.8.0",
            metadata: ["device": "iPhone"]
        )

        #expect(report.id == id)
        #expect(report.message == "EXC_BAD_ACCESS")
        #expect(report.stackTrace == "frame #0")
        #expect(report.timestamp == date)
        #expect(report.appVersion == "2.8.0")
        #expect(report.metadata["device"] == "iPhone")
    }

    // MARK: - PrismCrashReporter

    @Test
    func crashReporterRecordAndList() async {
        let reporter = PrismCrashReporter()
        let report = PrismCrashReport(message: "null pointer")
        await reporter.record(report)
        let reports = await reporter.reports
        #expect(reports.count == 1)
        #expect(reports.first?.message == "null pointer")
    }

    @Test
    func crashReporterClear() async {
        let reporter = PrismCrashReporter()
        await reporter.record(PrismCrashReport(message: "crash 1"))
        await reporter.record(PrismCrashReport(message: "crash 2"))
        await reporter.clear()
        let reports = await reporter.reports
        #expect(reports.isEmpty)
    }

    @Test
    func crashReporterCallbackFires() async {
        let box = CallbackBox()
        let reporter = PrismCrashReporter { _ in
            box.markFired()
        }
        await reporter.record(PrismCrashReport(message: "boom"))
        #expect(box.didFire)
    }

    // MARK: - PrismTraceSpan

    @Test
    func traceSpanStoresNameAndTimes() {
        let start = Date.now
        let span = PrismTraceSpan(name: "loadData", startTime: start)
        #expect(span.name == "loadData")
        #expect(span.startTime == start)
        #expect(span.endTime == nil)
        #expect(span.duration == nil)
    }

    // MARK: - PrismPerformanceTracer

    @Test
    func performanceTracerBeginEndSpan() async {
        let tracer = PrismPerformanceTracer()
        let spanID = await tracer.beginSpan(name: "network.fetch")
        var active = await tracer.activeSpans
        #expect(active.count == 1)
        #expect(active.first?.name == "network.fetch")

        await tracer.endSpan(id: spanID)
        active = await tracer.activeSpans
        let completed = await tracer.completedSpans
        #expect(active.isEmpty)
        #expect(completed.count == 1)
        #expect(completed.first?.endTime != nil)
        #expect(completed.first?.duration != nil)
    }

    @Test
    func performanceTracerMeasureAutoTraces() async {
        let tracer = PrismPerformanceTracer()
        let result = await tracer.measure(name: "compute") {
            42
        }
        #expect(result == 42)
        let completed = await tracer.completedSpans
        #expect(completed.count == 1)
        #expect(completed.first?.name == "compute")
        #expect(completed.first?.duration != nil)
    }

    // MARK: - PrismNetworkLog

    @Test
    func networkLogStoresAllFields() {
        let log = PrismNetworkLog(
            url: "https://api.example.com/users",
            method: "GET",
            statusCode: 200,
            requestSize: 0,
            responseSize: 4096,
            duration: .seconds(0.35),
            error: nil
        )

        #expect(log.url == "https://api.example.com/users")
        #expect(log.method == "GET")
        #expect(log.statusCode == 200)
        #expect(log.requestSize == 0)
        #expect(log.responseSize == 4096)
        #expect(log.duration == .seconds(0.35))
        #expect(log.error == nil)
    }

    // MARK: - PrismNetworkInspector

    @Test
    func networkInspectorRecordAndList() async {
        let inspector = PrismNetworkInspector()
        let log = PrismNetworkLog(url: "https://api.test.com", method: "POST", statusCode: 201)
        await inspector.record(log)
        let logs = await inspector.logs
        #expect(logs.count == 1)
        #expect(logs.first?.method == "POST")
    }

    @Test
    func networkInspectorErrorRateCalculation() async {
        let inspector = PrismNetworkInspector()
        await inspector.record(PrismNetworkLog(url: "https://a.com", method: "GET", statusCode: 200))
        await inspector.record(PrismNetworkLog(url: "https://b.com", method: "GET", error: "timeout"))
        await inspector.record(PrismNetworkLog(url: "https://c.com", method: "GET", statusCode: 200))
        await inspector.record(PrismNetworkLog(url: "https://d.com", method: "GET", error: "dns"))
        let rate = await inspector.errorRate
        #expect(rate == 0.5)
    }

    @Test
    func networkInspectorClear() async {
        let inspector = PrismNetworkInspector()
        await inspector.record(PrismNetworkLog(url: "https://a.com", method: "GET"))
        await inspector.clear()
        let logs = await inspector.logs
        #expect(logs.isEmpty)
    }

    @Test
    func networkInspectorAverageLatency() async {
        let inspector = PrismNetworkInspector()
        await inspector.record(PrismNetworkLog(url: "https://a.com", method: "GET", duration: .seconds(1)))
        await inspector.record(PrismNetworkLog(url: "https://b.com", method: "GET", duration: .seconds(3)))
        let avg = await inspector.averageLatency
        #expect(avg == .seconds(2))
    }

    // MARK: - PrismFunnelStep

    @Test
    func funnelStepStoresNameAndCount() {
        let step = PrismFunnelStep(name: "signup", count: 100, conversionRate: 0.75)
        #expect(step.name == "signup")
        #expect(step.count == 100)
        #expect(step.conversionRate == 0.75)
    }

    // MARK: - PrismAnalyticsFunnel

    @Test
    func analyticsFunnelDefineSteps() async {
        let funnel = PrismAnalyticsFunnel()
        await funnel.define(steps: ["visit", "signup", "purchase"])
        let report = await funnel.report()
        #expect(report.count == 3)
        #expect(report.map(\.name) == ["visit", "signup", "purchase"])
        #expect(report.allSatisfy { $0.count == 0 })
    }

    @Test
    func analyticsFunnelRecordAndReport() async {
        let funnel = PrismAnalyticsFunnel()
        await funnel.define(steps: ["visit", "signup", "purchase"])

        await funnel.record(step: "visit", userId: "u1")
        await funnel.record(step: "visit", userId: "u2")
        await funnel.record(step: "visit", userId: "u3")
        await funnel.record(step: "visit", userId: "u4")
        await funnel.record(step: "signup", userId: "u1")
        await funnel.record(step: "signup", userId: "u2")
        await funnel.record(step: "purchase", userId: "u1")

        let report = await funnel.report()
        #expect(report[0].count == 4)
        #expect(report[0].conversionRate == nil)
        #expect(report[1].count == 2)
        #expect(report[1].conversionRate == 0.5)
        #expect(report[2].count == 1)
        #expect(report[2].conversionRate == 0.5)
    }

    @Test
    func analyticsFunnelReset() async {
        let funnel = PrismAnalyticsFunnel()
        await funnel.define(steps: ["visit", "signup"])
        await funnel.record(step: "visit", userId: "u1")
        await funnel.reset()
        let report = await funnel.report()
        #expect(report[0].count == 0)
    }

    @Test
    func analyticsFunnelDeduplicatesUsers() async {
        let funnel = PrismAnalyticsFunnel()
        await funnel.define(steps: ["visit"])
        await funnel.record(step: "visit", userId: "u1")
        await funnel.record(step: "visit", userId: "u1")
        await funnel.record(step: "visit", userId: "u1")
        let report = await funnel.report()
        #expect(report[0].count == 1)
    }
}

// MARK: - Test Support

/// Thread-safe flag used to verify callback invocation from actor-isolated contexts.
final class CallbackBox: @unchecked Sendable {
    private var _didFire = false

    var didFire: Bool { _didFire }

    func markFired() {
        _didFire = true
    }
}
