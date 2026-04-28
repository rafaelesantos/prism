#if canImport(AVFoundation)
import AVFoundation
import CoreGraphics

// MARK: - Camera Position

/// The physical position of the camera on the device.
public enum PrismCameraPosition: Sendable, CaseIterable {
    case front
    case back
    case external
}

// MARK: - Capture Mode

/// The capture mode for the camera session.
public enum PrismCaptureMode: Sendable {
    case photo
    case video
}

// MARK: - Flash Mode

/// The flash mode used when capturing a photo.
public enum PrismFlashMode: Sendable, CaseIterable {
    case off
    case on
    case auto
}

// MARK: - Camera Permission

/// The current camera authorization status.
public enum PrismCameraPermission: Sendable, CaseIterable {
    case notDetermined
    case restricted
    case denied
    case authorized
}

// MARK: - Photo Quality

/// The quality level for captured photos.
public enum PrismPhotoQuality: Sendable, CaseIterable {
    case low
    case medium
    case high
    case maximum
}

// MARK: - Photo Settings

/// Configuration for capturing a photo.
public struct PrismPhotoSettings: Sendable {
    /// The flash mode to use during capture.
    public let flashMode: PrismFlashMode
    /// Whether HDR is enabled for the capture.
    public let isHDREnabled: Bool
    /// The quality level of the captured image.
    public let quality: PrismPhotoQuality

    public init(flashMode: PrismFlashMode = .auto, isHDREnabled: Bool = false, quality: PrismPhotoQuality = .high) {
        self.flashMode = flashMode
        self.isHDREnabled = isHDREnabled
        self.quality = quality
    }
}

// MARK: - Video Resolution

/// The resolution preset for video recording.
public enum PrismVideoResolution: Sendable, CaseIterable {
    case hd720
    case hd1080
    case uhd4K
}

// MARK: - Video Settings

/// Configuration for video recording.
public struct PrismVideoSettings: Sendable {
    /// The target video resolution.
    public let resolution: PrismVideoResolution
    /// The target frame rate in frames per second.
    public let frameRate: Int
    /// Whether video stabilization is enabled.
    public let stabilization: Bool

    public init(resolution: PrismVideoResolution = .hd1080, frameRate: Int = 30, stabilization: Bool = true) {
        self.resolution = resolution
        self.frameRate = frameRate
        self.stabilization = stabilization
    }
}

// MARK: - Captured Photo

/// The result of a photo capture operation.
public struct PrismCapturedPhoto: Sendable {
    /// The raw image data of the captured photo.
    public let imageData: Data?
    /// Metadata key-value pairs associated with the captured photo.
    public let metadata: [String: String]

    public init(imageData: Data? = nil, metadata: [String: String] = [:]) {
        self.imageData = imageData
        self.metadata = metadata
    }
}

// MARK: - Barcode Symbology

/// The barcode symbology types supported for scanning.
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

/// The result of a barcode detection.
public struct PrismBarcodeResult: Sendable {
    /// The decoded payload string from the barcode.
    public let payload: String
    /// The symbology type of the detected barcode.
    public let symbology: PrismBarcodeSymbology
    /// The bounding rectangle of the barcode in the camera preview coordinate space.
    public let bounds: CGRect?

    public init(payload: String, symbology: PrismBarcodeSymbology, bounds: CGRect? = nil) {
        self.payload = payload
        self.symbology = symbology
        self.bounds = bounds
    }
}

// MARK: - Camera Client

/// Observable client for managing AVFoundation camera sessions, photo/video capture, and barcode scanning.
///
/// Usage:
/// ```swift
/// let camera = PrismCameraClient()
/// let permission = await camera.requestPermission()
/// if permission == .authorized {
///     try await camera.startSession(position: .back, mode: .photo)
///     let photo = try await camera.capturePhoto(settings: PrismPhotoSettings())
/// }
/// ```
@MainActor @Observable
public final class PrismCameraClient {

    // MARK: - Public Properties

    /// The current camera authorization status.
    public private(set) var permissionStatus: PrismCameraPermission = .notDetermined

    /// Barcodes detected in the current scanning session.
    public private(set) var detectedBarcodes: [PrismBarcodeResult] = []

    // MARK: - Private Properties

    private var captureSession: AVCaptureSession?
    private var currentInput: AVCaptureDeviceInput?
    private var photoOutput: AVCapturePhotoOutput?
    private var movieOutput: AVCaptureMovieFileOutput?
    private var metadataOutput: AVCaptureMetadataOutput?
    private var metadataDelegate: MetadataDelegate?
    private var currentPosition: PrismCameraPosition = .back
    private var currentMode: PrismCaptureMode = .photo

    // MARK: - Init

    public init() {
        updatePermissionStatus()
    }

    // MARK: - Permission

    /// Requests camera access from the user and returns the resulting permission status.
    public func requestPermission() async -> PrismCameraPermission {
        await AVCaptureDevice.requestAccess(for: .video)
        updatePermissionStatus()
        return permissionStatus
    }

    // MARK: - Session Management

    /// Starts a camera capture session with the specified position and mode.
    ///
    /// - Parameters:
    ///   - position: The camera position to use (front, back, or external).
    ///   - mode: The capture mode (photo or video).
    /// - Throws: An error if the session cannot be configured.
    public func startSession(position: PrismCameraPosition, mode: PrismCaptureMode) async throws {
        let session = AVCaptureSession()
        session.beginConfiguration()

        // Configure session preset based on mode
        session.sessionPreset = mode == .photo ? .photo : .high

        // Add input
        let avPosition = avCapturePosition(from: position)
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: avPosition) else {
            session.commitConfiguration()
            throw CameraError.deviceNotFound
        }
        let input = try AVCaptureDeviceInput(device: device)
        if session.canAddInput(input) {
            session.addInput(input)
            currentInput = input
        }

        // Add output based on mode
        switch mode {
        case .photo:
            let output = AVCapturePhotoOutput()
            if session.canAddOutput(output) {
                session.addOutput(output)
                photoOutput = output
            }
        case .video:
            let output = AVCaptureMovieFileOutput()
            if session.canAddOutput(output) {
                session.addOutput(output)
                movieOutput = output
            }
        }

        session.commitConfiguration()
        session.startRunning()

        captureSession = session
        currentPosition = position
        currentMode = mode
    }

    /// Stops the current capture session and releases resources.
    public func stopSession() {
        captureSession?.stopRunning()
        captureSession = nil
        currentInput = nil
        photoOutput = nil
        movieOutput = nil
        metadataOutput = nil
        metadataDelegate = nil
        detectedBarcodes = []
    }

    // MARK: - Photo Capture

    /// Captures a photo with the specified settings.
    ///
    /// - Parameter settings: The photo capture configuration.
    /// - Returns: The captured photo including image data and metadata.
    /// - Throws: An error if the photo output is unavailable or capture fails.
    public func capturePhoto(settings: PrismPhotoSettings) async throws -> PrismCapturedPhoto {
        guard let photoOutput else {
            throw CameraError.outputNotConfigured
        }

        let avSettings = AVCapturePhotoSettings()
        avSettings.flashMode = avFlashMode(from: settings.flashMode)

        return try await withCheckedThrowingContinuation { continuation in
            let delegate = PhotoCaptureDelegate { result in
                continuation.resume(with: result)
            }
            // Retain delegate for the duration of the capture
            objc_setAssociatedObject(photoOutput, "captureDelegate", delegate, .OBJC_ASSOCIATION_RETAIN)
            photoOutput.capturePhoto(with: avSettings, delegate: delegate)
        }
    }

    // MARK: - Video Recording

    /// Starts recording video to a temporary file.
    ///
    /// - Throws: An error if the movie output is unavailable.
    public func startRecording() async throws {
        guard let movieOutput else {
            throw CameraError.outputNotConfigured
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
        let delegate = MovieRecordingDelegate()
        objc_setAssociatedObject(movieOutput, "recordingDelegate", delegate, .OBJC_ASSOCIATION_RETAIN)
        movieOutput.startRecording(to: url, recordingDelegate: delegate)
    }

    /// Stops the current video recording and returns the file URL.
    ///
    /// - Returns: The URL of the recorded video file, or nil if no recording was active.
    /// - Throws: An error if stopping the recording fails.
    public func stopRecording() async throws -> URL? {
        guard let movieOutput, movieOutput.isRecording else {
            return nil
        }
        return await withCheckedContinuation { continuation in
            let delegate = objc_getAssociatedObject(movieOutput, "recordingDelegate") as? MovieRecordingDelegate
            delegate?.onFinish = { url in
                continuation.resume(returning: url)
            }
            movieOutput.stopRecording()
        }
    }

    // MARK: - Camera Switching

    /// Switches the camera to the specified position while maintaining the current session.
    ///
    /// - Parameter position: The camera position to switch to.
    /// - Throws: An error if the target device is unavailable.
    public func switchCamera(to position: PrismCameraPosition) async throws {
        guard let session = captureSession else {
            throw CameraError.sessionNotRunning
        }

        session.beginConfiguration()

        // Remove current input
        if let currentInput {
            session.removeInput(currentInput)
        }

        // Add new input
        let avPosition = avCapturePosition(from: position)
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: avPosition) else {
            session.commitConfiguration()
            throw CameraError.deviceNotFound
        }
        let input = try AVCaptureDeviceInput(device: device)
        if session.canAddInput(input) {
            session.addInput(input)
            currentInput = input
            currentPosition = position
        }

        session.commitConfiguration()
    }

    // MARK: - Barcode Scanning

    /// Starts barcode scanning for the specified symbologies.
    ///
    /// - Parameter symbologies: The barcode symbology types to scan for.
    public func startBarcodeScanning(symbologies: [PrismBarcodeSymbology]) {
        guard let session = captureSession else { return }

        let output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            let delegate = MetadataDelegate { [weak self] barcodes in
                self?.detectedBarcodes = barcodes
            }
            output.setMetadataObjectsDelegate(delegate, queue: .main)
            let avTypes = symbologies.compactMap { avMetadataType(from: $0) }
            let available = output.availableMetadataObjectTypes
            output.metadataObjectTypes = avTypes.filter { available.contains($0) }
            metadataOutput = output
            metadataDelegate = delegate
        }
    }

    /// Stops barcode scanning and clears detected results.
    public func stopBarcodeScanning() {
        if let metadataOutput, let session = captureSession {
            session.removeOutput(metadataOutput)
        }
        metadataOutput = nil
        metadataDelegate = nil
        detectedBarcodes = []
    }

    // MARK: - Zoom & Torch

    /// Sets the zoom factor on the current camera device.
    ///
    /// - Parameter factor: The zoom factor, where 1.0 is no zoom.
    public func setZoom(factor: CGFloat) {
        #if !os(macOS)
        guard let device = currentInput?.device else { return }
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = max(1.0, min(factor, device.activeFormat.videoMaxZoomFactor))
            device.unlockForConfiguration()
        } catch {
            // Zoom configuration failed silently — device may not support the requested factor.
        }
        #endif
    }

    /// Enables or disables the torch (flashlight) on the current camera device.
    ///
    /// - Parameter enabled: Whether the torch should be turned on.
    /// - Throws: An error if the device does not support torch mode.
    public func setTorch(enabled: Bool) throws {
        guard let device = currentInput?.device, device.hasTorch else {
            throw CameraError.torchUnavailable
        }
        try device.lockForConfiguration()
        device.torchMode = enabled ? .on : .off
        device.unlockForConfiguration()
    }

    // MARK: - Private Helpers

    private func updatePermissionStatus() {
        permissionStatus = switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined: .notDetermined
        case .restricted: .restricted
        case .denied: .denied
        case .authorized: .authorized
        @unknown default: .notDetermined
        }
    }

    private func avCapturePosition(from position: PrismCameraPosition) -> AVCaptureDevice.Position {
        switch position {
        case .front: .front
        case .back: .back
        case .external: .unspecified
        }
    }

    private func avFlashMode(from mode: PrismFlashMode) -> AVCaptureDevice.FlashMode {
        switch mode {
        case .off: .off
        case .on: .on
        case .auto: .auto
        }
    }

    private func avMetadataType(from symbology: PrismBarcodeSymbology) -> AVMetadataObject.ObjectType? {
        switch symbology {
        case .qr: .qr
        case .ean13: .ean13
        case .ean8: .ean8
        case .code128: .code128
        case .code39: .code39
        case .dataMatrix: .dataMatrix
        case .pdf417: .pdf417
        case .aztec: .aztec
        }
    }

    private func prismSymbology(from type: AVMetadataObject.ObjectType) -> PrismBarcodeSymbology? {
        switch type {
        case .qr: .qr
        case .ean13: .ean13
        case .ean8: .ean8
        case .code128: .code128
        case .code39: .code39
        case .dataMatrix: .dataMatrix
        case .pdf417: .pdf417
        case .aztec: .aztec
        default: nil
        }
    }
}

// MARK: - Camera Error

/// Errors that can occur during camera operations.
public enum CameraError: Error, Sendable {
    case deviceNotFound
    case outputNotConfigured
    case sessionNotRunning
    case torchUnavailable
    case recordingFailed
}

// MARK: - Photo Capture Delegate

private final class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate, @unchecked Sendable {
    private let completion: (Result<PrismCapturedPhoto, Error>) -> Void

    init(completion: @escaping (Result<PrismCapturedPhoto, Error>) -> Void) {
        self.completion = completion
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error {
            completion(.failure(error))
            return
        }
        let data = photo.fileDataRepresentation()
        var metadata: [String: String] = [:]
        #if !os(macOS)
        metadata = photo.metadata.reduce(into: [String: String]()) { result, pair in
            result["\(pair.key)"] = "\(pair.value)"
        }
        #endif
        completion(.success(PrismCapturedPhoto(imageData: data, metadata: metadata)))
    }
}

// MARK: - Movie Recording Delegate

private final class MovieRecordingDelegate: NSObject, AVCaptureFileOutputRecordingDelegate, @unchecked Sendable {
    var onFinish: ((URL?) -> Void)?

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        onFinish?(error == nil ? outputFileURL : nil)
    }
}

// MARK: - Metadata Delegate

private final class MetadataDelegate: NSObject, AVCaptureMetadataOutputObjectsDelegate, @unchecked Sendable {
    private let onDetected: ([PrismBarcodeResult]) -> Void

    init(onDetected: @escaping ([PrismBarcodeResult]) -> Void) {
        self.onDetected = onDetected
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        let results = metadataObjects.compactMap { object -> PrismBarcodeResult? in
            guard let readable = object as? AVMetadataMachineReadableCodeObject,
                  let payload = readable.stringValue else {
                return nil
            }
            let symbology: PrismBarcodeSymbology = switch readable.type {
            case .qr: .qr
            case .ean13: .ean13
            case .ean8: .ean8
            case .code128: .code128
            case .code39: .code39
            case .dataMatrix: .dataMatrix
            case .pdf417: .pdf417
            case .aztec: .aztec
            default: .qr
            }
            return PrismBarcodeResult(payload: payload, symbology: symbology, bounds: readable.bounds)
        }
        onDetected(results)
    }
}
#endif
