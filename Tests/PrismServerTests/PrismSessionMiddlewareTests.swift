import Foundation
import Testing

@testable import PrismServer

private actor CapturedValue<T: Sendable> {
    var value: T?
    func set(_ v: T) { value = v }
}

@Suite("PrismSessionMiddleware Tests")
struct PrismSessionMiddlewareTests {

    @Test("Creates new session on first request")
    func createsNewSession() async throws {
        let store = PrismMemorySessionStore()
        let middleware = PrismSessionMiddleware(store: store, secret: "test-secret")
        let request = PrismHTTPRequest(method: .GET, uri: "/")
        let capture = CapturedValue<String>()
        let response = try await middleware.handle(request) { req in
            if let id = req.userInfo["sessionID"] as? String {
                await capture.set(id)
            }
            return .text("ok")
        }
        let setCookie = response.headers.values(for: "Set-Cookie")
        #expect(!setCookie.isEmpty)
        #expect(setCookie[0].contains("prism_session="))
        #expect(setCookie[0].contains("HttpOnly"))
        #expect(setCookie[0].contains("Secure"))
        #expect(await capture.value != nil)
    }

    @Test("Reuses existing session from cookie")
    func reusesExistingSession() async throws {
        let store = PrismMemorySessionStore()
        let middleware = PrismSessionMiddleware(store: store, secret: "test-secret")

        let firstCapture = CapturedValue<String>()
        let firstRequest = PrismHTTPRequest(method: .GET, uri: "/")
        let firstResponse = try await middleware.handle(firstRequest) { req in
            if let id = req.userInfo["sessionID"] as? String {
                await firstCapture.set(id)
            }
            return .text("ok")
        }

        let setCookie = firstResponse.headers.values(for: "Set-Cookie").first ?? ""
        let cookieValue =
            setCookie.split(separator: "=", maxSplits: 1).last?
            .split(separator: ";").first.map(String.init) ?? ""

        var headers = PrismHTTPHeaders()
        headers.set(name: "Cookie", value: "prism_session=\(cookieValue)")
        let secondRequest = PrismHTTPRequest(method: .GET, uri: "/", headers: headers)

        let secondCapture = CapturedValue<String>()
        let secondResponse = try await middleware.handle(secondRequest) { req in
            if let id = req.userInfo["sessionID"] as? String {
                await secondCapture.set(id)
            }
            return .text("ok")
        }

        let first = await firstCapture.value
        let second = await secondCapture.value
        #expect(first == second)
        #expect(secondResponse.headers.values(for: "Set-Cookie").isEmpty)
    }

    @Test("Invalid cookie creates new session")
    func invalidCookieCreatesNewSession() async throws {
        let store = PrismMemorySessionStore()
        let middleware = PrismSessionMiddleware(store: store, secret: "test-secret")
        var headers = PrismHTTPHeaders()
        headers.set(name: "Cookie", value: "prism_session=invalid-value")
        let request = PrismHTTPRequest(method: .GET, uri: "/", headers: headers)
        let response = try await middleware.handle(request) { _ in .text("ok") }
        let setCookie = response.headers.values(for: "Set-Cookie")
        #expect(!setCookie.isEmpty)
    }

    @Test("Custom cookie name")
    func customCookieName() async throws {
        let middleware = PrismSessionMiddleware(cookieName: "my_session", secret: "s")
        let request = PrismHTTPRequest(method: .GET, uri: "/")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        let setCookie = response.headers.values(for: "Set-Cookie").first ?? ""
        #expect(setCookie.contains("my_session="))
    }

    @Test("Session is saved to store after request")
    func sessionSavedToStore() async throws {
        let store = PrismMemorySessionStore()
        let middleware = PrismSessionMiddleware(store: store, secret: "s")
        let request = PrismHTTPRequest(method: .GET, uri: "/")
        let capture = CapturedValue<String>()
        _ = try await middleware.handle(request) { req in
            if let id = req.userInfo["sessionID"] as? String {
                await capture.set(id)
            }
            return .text("ok")
        }
        let sessionID = await capture.value!
        let session = await store.load(id: sessionID)
        #expect(session != nil)
    }

    @Test("Cookie has correct Max-Age")
    func cookieMaxAge() async throws {
        let middleware = PrismSessionMiddleware(ttl: 7200, secret: "s")
        let request = PrismHTTPRequest(method: .GET, uri: "/")
        let response = try await middleware.handle(request) { _ in .text("ok") }
        let setCookie = response.headers.values(for: "Set-Cookie").first ?? ""
        #expect(setCookie.contains("Max-Age=7200"))
    }
}
