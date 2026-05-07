import Foundation
import PrismFoundation
import Testing

@testable import PrismServer

@Suite("PrismLoggingMiddleware Tests")
struct PrismLoggingMiddlewareTests {

    @Test("Passes request through and returns response")
    func passThrough() async throws {
        let middleware = PrismLoggingMiddleware()
        let request = PrismHTTPRequest(method: .GET, uri: "/test")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        #expect(response.status == .ok)
        #expect(String(data: response.body.data, encoding: .utf8) == "ok")
    }

    @Test("Propagates errors from next handler")
    func propagatesErrors() async {
        let middleware = PrismLoggingMiddleware()
        let request = PrismHTTPRequest(method: .POST, uri: "/fail")
        do {
            _ = try await middleware.handle(request) { _ in
                throw PrismHTTPError.timeout
            }
            #expect(Bool(false), "Should have thrown")
        } catch {
            #expect(error is PrismHTTPError)
        }
    }

    @Test("Returns same status code as next handler")
    func preservesStatusCode() async throws {
        let middleware = PrismLoggingMiddleware()
        let request = PrismHTTPRequest(method: .GET, uri: "/notfound")
        let response = try await middleware.handle(request) { _ in
            PrismHTTPResponse(status: .notFound)
        }
        #expect(response.status == .notFound)
    }
}
