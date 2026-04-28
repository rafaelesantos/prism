import Foundation

/// MIME type resolution for common file extensions.
public struct PrismMIMEType: Sendable {

    private static let types: [String: String] = [
        // Text
        "html": "text/html; charset=utf-8",
        "htm": "text/html; charset=utf-8",
        "css": "text/css; charset=utf-8",
        "js": "application/javascript; charset=utf-8",
        "mjs": "application/javascript; charset=utf-8",
        "json": "application/json; charset=utf-8",
        "xml": "application/xml; charset=utf-8",
        "txt": "text/plain; charset=utf-8",
        "csv": "text/csv; charset=utf-8",
        "md": "text/markdown; charset=utf-8",
        "yaml": "text/yaml; charset=utf-8",
        "yml": "text/yaml; charset=utf-8",

        // Images
        "png": "image/png",
        "jpg": "image/jpeg",
        "jpeg": "image/jpeg",
        "gif": "image/gif",
        "svg": "image/svg+xml",
        "ico": "image/x-icon",
        "webp": "image/webp",
        "avif": "image/avif",

        // Fonts
        "woff": "font/woff",
        "woff2": "font/woff2",
        "ttf": "font/ttf",
        "otf": "font/otf",
        "eot": "application/vnd.ms-fontobject",

        // Media
        "mp3": "audio/mpeg",
        "mp4": "video/mp4",
        "webm": "video/webm",
        "ogg": "audio/ogg",
        "wav": "audio/wav",
        "m4a": "audio/mp4",

        // Archives
        "zip": "application/zip",
        "gz": "application/gzip",
        "tar": "application/x-tar",

        // Documents
        "pdf": "application/pdf",
        "doc": "application/msword",
        "docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        "xls": "application/vnd.ms-excel",
        "xlsx": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",

        // Web
        "wasm": "application/wasm",
        "map": "application/json",
    ]

    /// Returns the MIME type for a file extension, defaulting to application/octet-stream.
    public static func forExtension(_ ext: String) -> String {
        types[ext.lowercased()] ?? "application/octet-stream"
    }
}
