import Foundation
import Testing

@testable import PrismServer

@Suite("PrismGraphQLMiddleware Tests")
struct PrismGraphQLMiddlewareTests {

    private func makeSchema() -> PrismGraphQLSchema {
        let helloField = PrismGraphQLField(name: "hello", type: .string, resolve: { _ in "world" })
        let queryType = PrismGraphQLObjectType(name: "Query", fields: [helloField])
        return PrismGraphQLSchema(query: queryType)
    }

    @Test("POST with valid query returns data")
    func postValidQuery() async throws {
        let middleware = PrismGraphQLMiddleware(schema: makeSchema())
        let body = try JSONSerialization.data(withJSONObject: ["query": "{ hello }"])
        var headers = PrismHTTPHeaders()
        headers.set(name: "Content-Type", value: "application/json")
        let request = PrismHTTPRequest(method: .POST, uri: "/graphql", headers: headers, body: body)
        let response = try await middleware.handle(request) { _ in .text("fallback") }
        #expect(response.status == .ok)
        let json = try JSONSerialization.jsonObject(with: response.body.data) as? [String: Any]
        let data = json?["data"] as? [String: Any]
        #expect(data?["hello"] as? String == "world")
    }

    @Test("POST with variables")
    func postWithVariables() async throws {
        let field = PrismGraphQLField(
            name: "greet",
            type: .string,
            args: [PrismGraphQLArgument(name: "name", type: .string)],
            resolve: { info in
                let name: String = info.arg("name") ?? "stranger"
                return "Hi \(name)"
            }
        )
        let schema = PrismGraphQLSchema(query: PrismGraphQLObjectType(name: "Query", fields: [field]))
        let middleware = PrismGraphQLMiddleware(schema: schema)
        let body = try JSONSerialization.data(
            withJSONObject: [
                "query": "query($n: String) { greet(name: $n) }",
                "variables": ["n": "Alice"],
            ] as [String: Any])
        let request = PrismHTTPRequest(method: .POST, uri: "/graphql", body: body)
        let response = try await middleware.handle(request) { _ in .text("fallback") }
        let json = try JSONSerialization.jsonObject(with: response.body.data) as? [String: Any]
        let data = json?["data"] as? [String: Any]
        #expect(data?["greet"] as? String == "Hi Alice")
    }

    @Test("POST with invalid body returns error")
    func postInvalidBody() async throws {
        let middleware = PrismGraphQLMiddleware(schema: makeSchema())
        let request = PrismHTTPRequest(method: .POST, uri: "/graphql", body: Data("not json".utf8))
        let response = try await middleware.handle(request) { _ in .text("fallback") }
        let json = try JSONSerialization.jsonObject(with: response.body.data) as? [String: Any]
        let errors = json?["errors"] as? [[String: Any]]
        #expect(errors?.first?["message"] != nil)
    }

    @Test("POST with nil body returns error")
    func postNilBody() async throws {
        let middleware = PrismGraphQLMiddleware(schema: makeSchema())
        let request = PrismHTTPRequest(method: .POST, uri: "/graphql")
        let response = try await middleware.handle(request) { _ in .text("fallback") }
        let json = try JSONSerialization.jsonObject(with: response.body.data) as? [String: Any]
        let errors = json?["errors"] as? [[String: Any]]
        #expect(errors != nil)
    }

    @Test("GET with query parameter returns data")
    func getValidQuery() async throws {
        let middleware = PrismGraphQLMiddleware(schema: makeSchema())
        let encoded = "%7B%20hello%20%7D"
        let request = PrismHTTPRequest(method: .GET, uri: "/graphql?query=\(encoded)")
        let response = try await middleware.handle(request) { _ in .text("fallback") }
        let json = try JSONSerialization.jsonObject(with: response.body.data) as? [String: Any]
        let data = json?["data"] as? [String: Any]
        #expect(data?["hello"] as? String == "world")
    }

    @Test("GET with missing query parameter returns error")
    func getMissingQuery() async throws {
        let middleware = PrismGraphQLMiddleware(schema: makeSchema())
        let request = PrismHTTPRequest(method: .GET, uri: "/graphql")
        let response = try await middleware.handle(request) { _ in .text("fallback") }
        let json = try JSONSerialization.jsonObject(with: response.body.data) as? [String: Any]
        let errors = json?["errors"] as? [[String: Any]]
        #expect(errors != nil)
    }

    @Test("GET with empty query parameter returns error")
    func getEmptyQuery() async throws {
        let middleware = PrismGraphQLMiddleware(schema: makeSchema())
        let request = PrismHTTPRequest(method: .GET, uri: "/graphql?query=")
        let response = try await middleware.handle(request) { _ in .text("fallback") }
        let json = try JSONSerialization.jsonObject(with: response.body.data) as? [String: Any]
        let errors = json?["errors"] as? [[String: Any]]
        #expect(errors != nil)
    }

    @Test("GET with variables and operationName")
    func getWithVariablesAndOp() async throws {
        let field = PrismGraphQLField(
            name: "greet",
            type: .string,
            args: [PrismGraphQLArgument(name: "name", type: .string)],
            resolve: { info in info.arg("name") as String? ?? "world" }
        )
        let schema = PrismGraphQLSchema(query: PrismGraphQLObjectType(name: "Query", fields: [field]))
        let middleware = PrismGraphQLMiddleware(schema: schema)
        let query = "query%20Greet(%24n%3A%20String)%20%7B%20greet(name%3A%20%24n)%20%7D"
        let vars = "%7B%22n%22%3A%22Bob%22%7D"
        let request = PrismHTTPRequest(
            method: .GET,
            uri: "/graphql?query=\(query)&variables=\(vars)&operationName=Greet"
        )
        let response = try await middleware.handle(request) { _ in .text("fallback") }
        let json = try JSONSerialization.jsonObject(with: response.body.data) as? [String: Any]
        let data = json?["data"] as? [String: Any]
        #expect(data?["greet"] as? String == "Bob")
    }

    @Test("Non-matching path passes through")
    func nonMatchingPath() async throws {
        let middleware = PrismGraphQLMiddleware(schema: makeSchema())
        let request = PrismHTTPRequest(method: .GET, uri: "/api/users")
        let response = try await middleware.handle(request) { _ in .text("fallback") }
        #expect(String(data: response.body.data, encoding: .utf8) == "fallback")
    }

    @Test("Non-matching method passes through")
    func nonMatchingMethod() async throws {
        let middleware = PrismGraphQLMiddleware(schema: makeSchema())
        let request = PrismHTTPRequest(method: .DELETE, uri: "/graphql")
        let response = try await middleware.handle(request) { _ in .text("fallback") }
        #expect(String(data: response.body.data, encoding: .utf8) == "fallback")
    }

    @Test("Custom path")
    func customPath() async throws {
        let middleware = PrismGraphQLMiddleware(schema: makeSchema(), path: "/api/graphql")
        let body = try JSONSerialization.data(withJSONObject: ["query": "{ hello }"])
        let request = PrismHTTPRequest(method: .POST, uri: "/api/graphql", body: body)
        let response = try await middleware.handle(request) { _ in .text("fallback") }
        let json = try JSONSerialization.jsonObject(with: response.body.data) as? [String: Any]
        let data = json?["data"] as? [String: Any]
        #expect(data?["hello"] as? String == "world")
    }

    @Test("Parse error returns error response")
    func parseError() async throws {
        let middleware = PrismGraphQLMiddleware(schema: makeSchema())
        let body = try JSONSerialization.data(withJSONObject: ["query": "{{{{"])
        let request = PrismHTTPRequest(method: .POST, uri: "/graphql", body: body)
        let response = try await middleware.handle(request) { _ in .text("fallback") }
        let json = try JSONSerialization.jsonObject(with: response.body.data) as? [String: Any]
        let errors = json?["errors"] as? [[String: Any]]
        let msg = errors?.first?["message"] as? String
        #expect(msg?.contains("Parse error") == true)
    }

    @Test("Response has correct content type header")
    func contentTypeHeader() async throws {
        let middleware = PrismGraphQLMiddleware(schema: makeSchema())
        let body = try JSONSerialization.data(withJSONObject: ["query": "{ hello }"])
        let request = PrismHTTPRequest(method: .POST, uri: "/graphql", body: body)
        let response = try await middleware.handle(request) { _ in .text("fallback") }
        #expect(response.headers.value(for: "Content-Type")?.contains("application/json") == true)
    }
}

@Suite("PrismGraphQLPlayground Tests")
struct PrismGraphQLPlaygroundTests {

    @Test("Returns HTML on matching path")
    func returnsHTML() async throws {
        let playground = PrismGraphQLPlayground()
        let request = PrismHTTPRequest(method: .GET, uri: "/graphql/playground")
        let response = try await playground.handle(request) { _ in .text("fallback") }
        #expect(response.status == .ok)
        let body = String(data: response.body.data, encoding: .utf8) ?? ""
        #expect(body.contains("<!DOCTYPE html>"))
        #expect(body.contains("GraphQL Playground"))
        #expect(response.headers.value(for: "Content-Type")?.contains("text/html") == true)
    }

    @Test("Passes through non-matching path")
    func passThrough() async throws {
        let playground = PrismGraphQLPlayground()
        let request = PrismHTTPRequest(method: .GET, uri: "/other")
        let response = try await playground.handle(request) { _ in .text("fallback") }
        #expect(String(data: response.body.data, encoding: .utf8) == "fallback")
    }

    @Test("Passes through POST on matching path")
    func postPassThrough() async throws {
        let playground = PrismGraphQLPlayground()
        let request = PrismHTTPRequest(method: .POST, uri: "/graphql/playground")
        let response = try await playground.handle(request) { _ in .text("fallback") }
        #expect(String(data: response.body.data, encoding: .utf8) == "fallback")
    }

    @Test("Custom path and endpoint")
    func customPathAndEndpoint() async throws {
        let playground = PrismGraphQLPlayground(path: "/play", endpoint: "/api/gql")
        let request = PrismHTTPRequest(method: .GET, uri: "/play")
        let response = try await playground.handle(request) { _ in .text("fallback") }
        let body = String(data: response.body.data, encoding: .utf8) ?? ""
        #expect(body.contains("/api/gql"))
    }

    @Test("Content-Length header is set")
    func contentLength() async throws {
        let playground = PrismGraphQLPlayground()
        let request = PrismHTTPRequest(method: .GET, uri: "/graphql/playground")
        let response = try await playground.handle(request) { _ in .text("fallback") }
        let cl = Int(response.headers.value(for: "Content-Length") ?? "0") ?? 0
        #expect(cl == response.body.data.count)
    }
}
