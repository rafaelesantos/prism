#if canImport(Network)
    import Foundation
    import PrismFoundation

    public struct PrismServerBuilder: Sendable {
        private let host: String
        private let port: UInt16
        private let middlewares: [any PrismMiddleware]
        private let routes: [PrismRoute]
        private let groups: [PrismRouteGroup]
        private let webSocketHandlers: [(String, any PrismWebSocketHandler)]
        private let tlsConfig: PrismTLSConfiguration?
        private let logLevel: PrismLogLevel

        public init(
            host: String = "0.0.0.0",
            port: UInt16 = 8080,
            tlsConfig: PrismTLSConfiguration? = nil,
            logLevel: PrismLogLevel = .info
        ) {
            self.host = host
            self.port = port
            self.middlewares = []
            self.routes = []
            self.groups = []
            self.webSocketHandlers = []
            self.tlsConfig = tlsConfig
            self.logLevel = logLevel
        }

        private init(
            host: String,
            port: UInt16,
            middlewares: [any PrismMiddleware],
            routes: [PrismRoute],
            groups: [PrismRouteGroup],
            webSocketHandlers: [(String, any PrismWebSocketHandler)],
            tlsConfig: PrismTLSConfiguration?,
            logLevel: PrismLogLevel
        ) {
            self.host = host
            self.port = port
            self.middlewares = middlewares
            self.routes = routes
            self.groups = groups
            self.webSocketHandlers = webSocketHandlers
            self.tlsConfig = tlsConfig
            self.logLevel = logLevel
        }

        public func middleware(_ m: any PrismMiddleware) -> PrismServerBuilder {
            PrismServerBuilder(
                host: host, port: port, middlewares: middlewares + [m], routes: routes, groups: groups,
                webSocketHandlers: webSocketHandlers, tlsConfig: tlsConfig, logLevel: logLevel)
        }

        public func route(_ method: PrismHTTPMethod, _ pattern: String, handler: @escaping PrismRouteHandler)
            -> PrismServerBuilder
        {
            let route = PrismRoute(method: method, pattern: pattern, handler: handler)
            return PrismServerBuilder(
                host: host, port: port, middlewares: middlewares, routes: routes + [route], groups: groups,
                webSocketHandlers: webSocketHandlers, tlsConfig: tlsConfig, logLevel: logLevel)
        }

        public func get(_ pattern: String, handler: @escaping PrismRouteHandler) -> PrismServerBuilder {
            route(.GET, pattern, handler: handler)
        }

        public func post(_ pattern: String, handler: @escaping PrismRouteHandler) -> PrismServerBuilder {
            route(.POST, pattern, handler: handler)
        }

        public func put(_ pattern: String, handler: @escaping PrismRouteHandler) -> PrismServerBuilder {
            route(.PUT, pattern, handler: handler)
        }

        public func delete(_ pattern: String, handler: @escaping PrismRouteHandler) -> PrismServerBuilder {
            route(.DELETE, pattern, handler: handler)
        }

        public func start() async throws -> PrismHTTPServer {
            let logger = PrismStructuredLogger(
                minimumLevel: logLevel,
                destinations: [PrismConsoleLogDestination()]
            )

            let server = PrismHTTPServer(host: host, port: port, tlsConfig: tlsConfig, logger: logger)

            for m in middlewares {
                await server.use(m)
            }

            for route in routes {
                await server.route(route.method, route.pattern, handler: route.handler)
            }

            for (path, handler) in webSocketHandlers {
                await server.webSocket(path, handler: handler)
            }

            try await server.start()
            return server
        }
    }
#endif
