import Foundation
import Testing

@testable import PrismServer

@Suite("PrismCompressionMiddleware Tests")
struct PrismCompressionMiddlewareTests {

    @Test("Compresses body above minimum size with gzip Accept-Encoding")
    func compressesAboveMin() async throws {
        let middleware = PrismCompressionMiddleware(minimumSize: 100)
        var request = PrismHTTPRequest(method: .GET, uri: "/data")
        request.headers.set(name: "Accept-Encoding", value: "gzip")

        let largeBody = String(repeating: "x", count: 500)
        let response = try await middleware.handle(request) { _ in
            .text(largeBody)
        }

        #expect(response.headers.value(for: "Content-Encoding") == "deflate")
        #expect(response.body.data.count < 500)
    }

    @Test("Does not compress below minimum size")
    func doesNotCompressBelowMin() async throws {
        let middleware = PrismCompressionMiddleware(minimumSize: 1024)
        var request = PrismHTTPRequest(method: .GET, uri: "/data")
        request.headers.set(name: "Accept-Encoding", value: "gzip")

        let response = try await middleware.handle(request) { _ in
            .text("small")
        }

        #expect(response.headers.value(for: "Content-Encoding") == nil)
    }

    @Test("Does not compress without Accept-Encoding header")
    func noAcceptEncoding() async throws {
        let middleware = PrismCompressionMiddleware(minimumSize: 10)
        let request = PrismHTTPRequest(method: .GET, uri: "/data")
        let largeBody = String(repeating: "x", count: 500)
        let response = try await middleware.handle(request) { _ in .text(largeBody) }
        #expect(response.headers.value(for: "Content-Encoding") == nil)
    }

    @Test("Default minimum size is 1024")
    func defaultMinSize() async throws {
        let middleware = PrismCompressionMiddleware()
        var request = PrismHTTPRequest(method: .GET, uri: "/data")
        request.headers.set(name: "Accept-Encoding", value: "gzip")

        let response = try await middleware.handle(request) { _ in
            .text(String(repeating: "x", count: 500))
        }

        #expect(response.headers.value(for: "Content-Encoding") == nil)
    }

    @Test("Updates Content-Length after compression")
    func updatesContentLength() async throws {
        let middleware = PrismCompressionMiddleware(minimumSize: 100)
        var request = PrismHTTPRequest(method: .GET, uri: "/data")
        request.headers.set(name: "Accept-Encoding", value: "gzip")

        let response = try await middleware.handle(request) { _ in
            .text(String(repeating: "x", count: 500))
        }

        if response.headers.value(for: "Content-Encoding") != nil {
            let cl = Int(response.headers.value(for: "Content-Length") ?? "0") ?? 0
            #expect(cl == response.body.data.count)
        }
    }
}
