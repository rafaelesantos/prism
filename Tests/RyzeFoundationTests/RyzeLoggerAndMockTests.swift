import Testing

@testable import RyzeFoundation

struct RyzeLoggerAndMockTests {
    @Test
    func foundationLogMessageBuildsMessageValues() {
        #expect(RyzeFoundationLogMessage.message("hello").value == "hello")
        #expect(
            RyzeFoundationLogMessage.error(BrokenEncodingError.forced).value
                == BrokenEncodingError.forced.localizedDescription
        )
    }

    @Test
    func foundationLoggerAcceptsAllLogLevels() {
        let logger = RyzeFoundationLogger()

        logger.info(.message("info"))
        logger.warning(.message("warning"))
        logger.error(.error(BrokenEncodingError.forced))
    }

    @Test
    func mockProtocolBuildsTenMocksByDefault() {
        let mocks = SampleMockValue.mocks

        #expect(mocks.count == 10)
        #expect(mocks.allSatisfy { $0 == .mock })
    }
}
