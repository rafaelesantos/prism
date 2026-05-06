import Foundation

public struct PrismServerScaffold: Sendable {

    public init() {}

    public func packageSwift(name: String) -> String {
        """
        // swift-tools-version: 6.3
        import PackageDescription

        let package = Package(
            name: "\(name)",
            platforms: [.macOS(.v26)],
            dependencies: [
                .package(url: "https://github.com/rafaelesantos/prism.git", from: "4.0.0")
            ],
            targets: [
                .executableTarget(
                    name: "\(name)",
                    dependencies: [
                        .product(name: "PrismServer", package: "prism"),
                    ]
                ),
            ]
        )
        """
    }

    public func mainSwift(name: String) -> String {
        """
        import PrismServer

        let server = PrismHTTPServer(port: 8080)

        await server.use(PrismCORSMiddleware())
        await server.use(PrismLoggingMiddleware())

        await server.get("/") { _ in
            .json(["message": "Welcome to \\(name)!"])
        }

        await server.get("/health") { _ in
            .json(["status": "up"])
        }

        try await server.start()

        // Keep the server running
        try await Task.sleep(for: .seconds(.max))
        """
    }

    public func gitignore() -> String {
        """
        .DS_Store
        /.build
        /Packages
        xcuserdata/
        DerivedData/
        .swiftpm/xcode/package.xcworkspace/contents.xcworkspacedata
        .env
        """
    }

    public func dockerfile(name: String) -> String {
        """
        FROM swift:6.3-jammy AS build
        WORKDIR /app
        COPY . .
        RUN swift build -c release

        FROM swift:6.3-jammy-slim
        WORKDIR /app
        COPY --from=build /app/.build/release/\(name) .
        EXPOSE 8080
        CMD ["./\(name)"]
        """
    }

    public func generate(name: String) -> [String: String] {
        [
            "Package.swift": packageSwift(name: name),
            "Sources/\(name)/main.swift": mainSwift(name: name),
            ".gitignore": gitignore(),
            "Dockerfile": dockerfile(name: name),
        ]
    }
}
