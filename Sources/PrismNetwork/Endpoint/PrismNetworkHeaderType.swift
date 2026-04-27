//
//  PrismNetworkHeaderType.swift
//  Prism
//
//  Created by Rafael Escaleira on 29/03/25.
//

/// HTTP header content types.
public enum PrismNetworkHeaderType: String, Sendable, CaseIterable {
    /// JSON content type (`application/json`).
    case json = "application/json"
    /// XML content type (`application/xml`).
    case xml = "application/xml"
    /// URL-encoded form data (`application/x-www-form-urlencoded`).
    case formURLEncoded = "application/x-www-form-urlencoded"
    /// Multipart form data (`multipart/form-data`).
    case multipartFormData = "multipart/form-data"
    /// Plain text content type (`text/plain`).
    case plainText = "text/plain"
    /// HTML content type (`text/html`).
    case html = "text/html"
    /// CSS content type (`text/css`).
    case css = "text/css"
    /// JavaScript content type (`application/javascript`).
    case javascript = "application/javascript"
    /// Binary octet stream (`application/octet-stream`).
    case octetStream = "application/octet-stream"
    /// PDF document (`application/pdf`).
    case pdf = "application/pdf"
    /// ZIP archive (`application/zip`).
    case zip = "application/zip"
    /// JPEG image (`image/jpeg`).
    case jpeg = "image/jpeg"
    /// PNG image (`image/png`).
    case png = "image/png"
    /// GIF image (`image/gif`).
    case gif = "image/gif"
    /// SVG image (`image/svg+xml`).
    case svg = "image/svg+xml"
    /// MP3 audio (`audio/mpeg`).
    case mp3 = "audio/mpeg"
    /// MP4 video (`video/mp4`).
    case mp4 = "video/mp4"
    /// Wildcard accepting any content type (`*/*`).
    case any = "*/*"
    /// Wildcard accepting any image type (`image/*`).
    case image = "image/*"
    /// Wildcard accepting any audio type (`audio/*`).
    case audio = "audio/*"
    /// Wildcard accepting any video type (`video/*`).
    case video = "video/*"
}
