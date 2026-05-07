import Foundation
import Testing

@testable import PrismServer

@Suite("PrismMCPHTTPTransport Tests")
struct PrismMCPHTTPTransportTests {

    private func makeServer() -> PrismMCPServer {
        let server = PrismMCPServer(name: "TestServer", version: "1.0.0")
        return server
    }

    private func makeRequest(method: String, params: [String: Any] = [:], id: Int = 1) -> Data {
        let dict: [String: Any] = [
            "jsonrpc": "2.0",
            "method": method,
            "params": params,
            "id": id,
        ]
        return (try? JSONSerialization.data(withJSONObject: dict)) ?? Data()
    }

    @Test("POST to /mcp handles JSON-RPC request")
    func postHandlesJSONRPC() async throws {
        let server = makeServer()
        let transport = PrismMCPHTTPTransport(server: server)
        let body = makeRequest(method: "initialize")
        let request = PrismHTTPRequest(method: .POST, uri: "/mcp", body: body)
        let response = try await transport.handle(request) { _ in .text("fallback") }
        #expect(response.status == .ok)
        #expect(response.headers.value(for: "Content-Type")?.contains("application/json") == true)
        let json = try JSONSerialization.jsonObject(with: response.body.data) as? [String: Any]
        #expect(json?["result"] != nil)
    }

    @Test("POST with empty body returns parse error")
    func postEmptyBody() async throws {
        let server = makeServer()
        let transport = PrismMCPHTTPTransport(server: server)
        let request = PrismHTTPRequest(method: .POST, uri: "/mcp")
        let response = try await transport.handle(request) { _ in .text("fallback") }
        #expect(response.status == .badRequest)
        let json = try JSONSerialization.jsonObject(with: response.body.data) as? [String: Any]
        let error = json?["error"] as? [String: Any]
        #expect(error?["code"] as? Int == -32700)
    }

    @Test("POST with nil body returns parse error")
    func postNilBody() async throws {
        let server = makeServer()
        let transport = PrismMCPHTTPTransport(server: server)
        let request = PrismHTTPRequest(method: .POST, uri: "/mcp", body: nil)
        let response = try await transport.handle(request) { _ in .text("fallback") }
        #expect(response.status == .badRequest)
    }

    @Test("GET to /mcp/sse returns SSE endpoint")
    func getSSE() async throws {
        let server = makeServer()
        let transport = PrismMCPHTTPTransport(server: server)
        let request = PrismHTTPRequest(method: .GET, uri: "/mcp/sse")
        let response = try await transport.handle(request) { _ in .text("fallback") }
        #expect(response.status == .ok)
        #expect(response.headers.value(for: "Content-Type") == "text/event-stream")
        #expect(response.headers.value(for: "Cache-Control") == "no-cache")
        let body = String(data: response.body.data, encoding: .utf8) ?? ""
        #expect(body.contains("event: endpoint"))
        #expect(body.contains("/mcp"))
    }

    @Test("Non-matching path passes through")
    func passThrough() async throws {
        let server = makeServer()
        let transport = PrismMCPHTTPTransport(server: server)
        let request = PrismHTTPRequest(method: .GET, uri: "/api/users")
        let response = try await transport.handle(request) { _ in .text("fallback") }
        #expect(String(data: response.body.data, encoding: .utf8) == "fallback")
    }

    @Test("Custom base path")
    func customBasePath() async throws {
        let server = makeServer()
        let transport = PrismMCPHTTPTransport(server: server, path: "/api/mcp")
        let body = makeRequest(method: "ping")
        let request = PrismHTTPRequest(method: .POST, uri: "/api/mcp", body: body)
        let response = try await transport.handle(request) { _ in .text("fallback") }
        #expect(response.status == .ok)
    }

    @Test("Custom base path SSE endpoint")
    func customBasePathSSE() async throws {
        let server = makeServer()
        let transport = PrismMCPHTTPTransport(server: server, path: "/api/mcp")
        let request = PrismHTTPRequest(method: .GET, uri: "/api/mcp/sse")
        let response = try await transport.handle(request) { _ in .text("fallback") }
        let body = String(data: response.body.data, encoding: .utf8) ?? ""
        #expect(body.contains("/api/mcp"))
    }

    @Test("Tool call through HTTP transport")
    func toolCallViaHTTP() async throws {
        let server = makeServer()
        await server.registerTool("echo", description: "Echo") { args in
            .text(args.string("msg") ?? "empty")
        }
        let transport = PrismMCPHTTPTransport(server: server)
        let body = makeRequest(
            method: "tools/call",
            params: ["name": "echo", "arguments": ["msg": "hello"]]
        )
        let request = PrismHTTPRequest(method: .POST, uri: "/mcp", body: body)
        let response = try await transport.handle(request) { _ in .text("fallback") }
        let json = try JSONSerialization.jsonObject(with: response.body.data) as? [String: Any]
        let result = json?["result"] as? [String: Any]
        let content = result?["content"] as? [[String: Any]]
        #expect(content?.first?["text"] as? String == "hello")
    }
}
