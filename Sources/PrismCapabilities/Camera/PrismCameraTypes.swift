#if canImport(AVFoundation)
    import AVFoundation
    import CoreGraphics

    // MARK: - Camera Position

    public enum PrismCameraPosition: Sendable, CaseIterable {
        case front
        case back
        case external
    }

    // MARK: - Capture Mode

    public enum PrismCaptureMode: Sendable {
        case photo
        case video
    }

    // MARK: - Flash Mode

    public enum PrismFlashMode: Sendable, CaseIterable {
        case off
        case on
        case auto
    }

    // MARK: - Camera Permission

    public enum PrismCameraPermission: Sendable, CaseIterable {
        case notDetermined
        case restricted
        case denied
        case authorized
    }

    // MARK: - Photo Quality

    public enum PrismPhotoQuality: Sendable, CaseIterable {
        case low
        case medium
        case high
        case maximum
    }

    // MARK: - Photo Settings

    public struct PrismPhotoSettings: Sendable {
        public let flashMode: PrismFlashMode
        public let isHDREnabled: Bool
        public let quality: PrismPhotoQuality

        public init(flashMode: PrismFlashMode = .auto, isHDREnabled: Bool = false, quality: PrismPhotoQuality = .high) {
            self.flashMode = flashMode
            self.isHDREnabled = isHDREnabled
            self.quality = quality
        }
    }

    // MARK: - Video Resolution

    public enum PrismVideoResolution: Sendable, CaseIterable {
        case hd720
        case hd1080
        case uhd4K
    }

    // MARK: - Video Settings

    public struct PrismVideoSettings: Sendable {
        public let resolution: PrismVideoResolution
        public let frameRate: Int
        public let stabilization: Bool

        public init(resolution: PrismVideoResolution = .hd1080, frameRate: Int = 30, stabilization: Bool = true) {
            self.resolution = resolution
            self.frameRate = frameRate
            self.stabilization = stabilization
        }
    }

    // MARK: - Captured Photo

    public struct PrismCapturedPhoto: Sendable {
        public let imageData: Data?
        public let metadata: [String: String]

        public init(imageData: Data? = nil, metadata: [String: String] = [:]) {
            self.imageData = imageData
            self.metadata = metadata
        }
    }

    // MARK: - Barcode Symbology

    public enum PrismBarcodeSymbology: Sendable, CaseIterable {
        case qr
        case ean13
        case ean8
        case code128
        case code39
        case dataMatrix
        case pdf417
        case aztec
    }

    // MARK: - Barcode Result

    public struct PrismBarcodeResult: Sendable {
        public let payload: String
        public let symbology: PrismBarcodeSymbology
        public let bounds: CGRect?

        public init(payload: String, symbology: PrismBarcodeSymbology, bounds: CGRect? = nil) {
            self.payload = payload
            self.symbology = symbology
            self.bounds = bounds
        }
    }

    // MARK: - Camera Error

    public enum CameraError: Error, Sendable {
        case deviceNotFound
        case outputNotConfigured
        case sessionNotRunning
        case torchUnavailable
        case recordingFailed
    }
#endif
