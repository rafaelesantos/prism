#if canImport(Network)
    import Foundation
    import Network

    public struct PrismHTTP2Configuration: Sendable {
        public let maxConcurrentStreams: Int
        public let initialWindowSize: Int
        public let maxFrameSize: Int

        public init(
            maxConcurrentStreams: Int = 100,
            initialWindowSize: Int = 65535,
            maxFrameSize: Int = 16384
        ) {
            self.maxConcurrentStreams = maxConcurrentStreams
            self.initialWindowSize = initialWindowSize
            self.maxFrameSize = maxFrameSize
        }

        public func configureALPN(_ tlsOptions: NWProtocolTLS.Options) {
            sec_protocol_options_add_tls_application_protocol(
                tlsOptions.securityProtocolOptions,
                "h2"
            )
            sec_protocol_options_add_tls_application_protocol(
                tlsOptions.securityProtocolOptions,
                "http/1.1"
            )
        }
    }

    extension PrismHTTPServer {
        public static func http2(
            host: String = "0.0.0.0",
            port: UInt16 = 443,
            tlsConfig: PrismTLSConfiguration,
            http2Config: PrismHTTP2Configuration = PrismHTTP2Configuration()
        ) -> PrismHTTPServer {
            PrismHTTPServer(host: host, port: port, tlsConfig: tlsConfig)
        }
    }
#endif
