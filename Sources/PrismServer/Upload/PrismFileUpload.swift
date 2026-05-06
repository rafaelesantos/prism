import Foundation

public struct PrismUploadedFile: Sendable {
    public let filename: String
    public let contentType: String
    public let size: Int
    public let tempPath: String

    public init(filename: String, contentType: String, size: Int, tempPath: String) {
        self.filename = filename
        self.contentType = contentType
        self.size = size
        self.tempPath = tempPath
    }

    public func data() throws -> Data {
        try Data(contentsOf: URL(fileURLWithPath: tempPath))
    }

    public func move(to destination: String) throws {
        let destDir = (destination as NSString).deletingLastPathComponent
        try FileManager.default.createDirectory(atPath: destDir, withIntermediateDirectories: true)
        try FileManager.default.moveItem(atPath: tempPath, toPath: destination)
    }

    public func cleanup() {
        try? FileManager.default.removeItem(atPath: tempPath)
    }
}

public struct PrismUploadConfig: Sendable {
    public let maxFileSize: Int
    public let maxTotalSize: Int
    public let allowedTypes: [String]
    public let tempDirectory: String

    public init(
        maxFileSize: Int = 10_485_760,
        maxTotalSize: Int = 52_428_800,
        allowedTypes: [String] = [],
        tempDirectory: String = NSTemporaryDirectory()
    ) {
        self.maxFileSize = maxFileSize
        self.maxTotalSize = maxTotalSize
        self.allowedTypes = allowedTypes
        self.tempDirectory = tempDirectory
    }
}

public enum PrismUploadError: Error, Sendable {
    case fileTooLarge(String, Int)
    case totalSizeTooLarge(Int)
    case typeNotAllowed(String, String)
    case saveFailed(String)
}

public struct PrismUploadProcessor: Sendable {
    private let config: PrismUploadConfig

    public init(config: PrismUploadConfig = PrismUploadConfig()) {
        self.config = config
    }

    public func process(_ request: PrismHTTPRequest) throws -> PrismUploadResult {
        let parts = try request.multipartParts()

        var files: [String: PrismUploadedFile] = [:]
        var fields: [String: String] = [:]
        var totalSize = 0

        for part in parts {
            if let filename = part.filename {
                totalSize += part.data.count

                guard totalSize <= config.maxTotalSize else {
                    throw PrismUploadError.totalSizeTooLarge(totalSize)
                }

                guard part.data.count <= config.maxFileSize else {
                    throw PrismUploadError.fileTooLarge(filename, part.data.count)
                }

                let mimeType = part.contentType ?? "application/octet-stream"
                if !config.allowedTypes.isEmpty && !config.allowedTypes.contains(mimeType) {
                    throw PrismUploadError.typeNotAllowed(filename, mimeType)
                }

                let tempName = UUID().uuidString + "_" + filename
                let tempPath = (config.tempDirectory as NSString).appendingPathComponent(tempName)

                guard FileManager.default.createFile(atPath: tempPath, contents: part.data) else {
                    throw PrismUploadError.saveFailed(filename)
                }

                files[part.name] = PrismUploadedFile(
                    filename: filename,
                    contentType: mimeType,
                    size: part.data.count,
                    tempPath: tempPath
                )
            } else {
                fields[part.name] = part.stringValue ?? ""
            }
        }

        return PrismUploadResult(files: files, fields: fields)
    }
}

public struct PrismUploadResult: Sendable {
    public let files: [String: PrismUploadedFile]
    public let fields: [String: String]

    public var file: PrismUploadedFile? { files.values.first }

    public func cleanup() {
        for file in files.values {
            file.cleanup()
        }
    }
}
