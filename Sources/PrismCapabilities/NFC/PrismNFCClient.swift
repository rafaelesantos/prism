import Foundation

// MARK: - NFC Tag Type

public enum PrismNFCTagType: Sendable, CaseIterable {
    case ndefTag
    case iso7816
    case iso15693
    case felica
    case mifareUltralight
    case mifareDesfire
}

// MARK: - NDEF Type Name Format

public enum PrismNDEFTypeNameFormat: Sendable, CaseIterable {
    case empty
    case wellKnown
    case media
    case absoluteURI
    case external
    case unknown
    case unchanged
}

// MARK: - NDEF Record

public struct PrismNDEFRecord: Sendable {
    public let typeNameFormat: PrismNDEFTypeNameFormat
    public let type: Data
    public let payload: Data
    public let identifier: Data

    public init(typeNameFormat: PrismNDEFTypeNameFormat, type: Data, payload: Data, identifier: Data = Data()) {
        self.typeNameFormat = typeNameFormat
        self.type = type
        self.payload = payload
        self.identifier = identifier
    }
}

// MARK: - NDEF Message

public struct PrismNDEFMessage: Sendable {
    public let records: [PrismNDEFRecord]

    public init(records: [PrismNDEFRecord]) {
        self.records = records
    }
}

// MARK: - NFC Read Result

public struct PrismNFCReadResult: Sendable {
    public let tagType: PrismNFCTagType
    public let message: PrismNDEFMessage?
    public let identifier: Data?

    public init(tagType: PrismNFCTagType, message: PrismNDEFMessage? = nil, identifier: Data? = nil) {
        self.tagType = tagType
        self.message = message
        self.identifier = identifier
    }
}

// MARK: - NFC Client

#if canImport(CoreNFC)
    import CoreNFC

    @MainActor @Observable
    public final class PrismNFCClient {
        public var isAvailable: Bool {
            NFCNDEFReaderSession.readingAvailable
        }

        public init() {}

        public func readNDEF(alertMessage: String) async throws -> PrismNFCReadResult {
            try await withCheckedThrowingContinuation { continuation in
                let delegate = NDEFReaderDelegate { result in
                    continuation.resume(with: result)
                }
                let session = NFCNDEFReaderSession(delegate: delegate, queue: nil, invalidateAfterFirstRead: true)
                session.alertMessage = alertMessage
                // Keep delegate alive for the duration of the session
                objc_setAssociatedObject(session, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN)
                session.begin()
            }
        }

        public func writeNDEF(message: PrismNDEFMessage, alertMessage: String) async throws {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                let delegate = NDEFWriterDelegate(message: message) { result in
                    continuation.resume(with: result)
                }
                let session = NFCNDEFReaderSession(delegate: delegate, queue: nil, invalidateAfterFirstRead: false)
                session.alertMessage = alertMessage
                objc_setAssociatedObject(session, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN)
                session.begin()
            }
        }

        public func readISO7816(aid: Data, alertMessage: String) async throws -> Data {
            try await withCheckedThrowingContinuation { continuation in
                let delegate = ISO7816ReaderDelegate(aid: aid) { result in
                    continuation.resume(with: result)
                }
                let session = NFCTagReaderSession(pollingOption: .iso14443, delegate: delegate, queue: nil)
                session?.alertMessage = alertMessage
                if let session {
                    objc_setAssociatedObject(session, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN)
                    session.begin()
                } else {
                    continuation.resume(throwing: NFCReaderError(.readerSessionInvalidationErrorSystemIsBusy))
                }
            }
        }
    }

    // MARK: - Private NDEF Reader Delegate

    private final class NDEFReaderDelegate: NSObject, NFCNDEFReaderSessionDelegate, @unchecked Sendable {
        private let completion: (Result<PrismNFCReadResult, Error>) -> Void

        init(completion: @escaping (Result<PrismNFCReadResult, Error>) -> Void) {
            self.completion = completion
        }

        func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {}

        func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
            // Only report non-cancellation errors
            let nfcError = error as? NFCReaderError
            if nfcError?.code != .readerSessionInvalidationErrorFirstNDEFTagRead {
                completion(.failure(error))
            }
        }

        func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
            guard let nfcMessage = messages.first else {
                completion(.success(PrismNFCReadResult(tagType: .ndefTag)))
                return
            }

            let records = nfcMessage.records.map { record in
                PrismNDEFRecord(
                    typeNameFormat: record.typeNameFormat.toPrism,
                    type: record.type,
                    payload: record.payload,
                    identifier: record.identifier
                )
            }

            let result = PrismNFCReadResult(
                tagType: .ndefTag,
                message: PrismNDEFMessage(records: records)
            )
            completion(.success(result))
        }
    }

    // MARK: - Private NDEF Writer Delegate

    private final class NDEFWriterDelegate: NSObject, NFCNDEFReaderSessionDelegate, @unchecked Sendable {
        private let message: PrismNDEFMessage
        private let completion: (Result<Void, Error>) -> Void

        init(message: PrismNDEFMessage, completion: @escaping (Result<Void, Error>) -> Void) {
            self.message = message
            self.completion = completion
        }

        func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {}

        func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
            completion(.failure(error))
        }

        func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {}

        func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [any NFCNDEFTag]) {
            guard let tag = tags.first else {
                session.invalidate(errorMessage: "No writable tag found.")
                return
            }

            session.connect(to: tag) { [weak self] error in
                guard let self else { return }
                if let error {
                    session.invalidate(errorMessage: error.localizedDescription)
                    completion(.failure(error))
                    return
                }

                let nfcRecords = message.records.map { record in
                    NFCNDEFPayload(
                        format: record.typeNameFormat.toNFC,
                        type: record.type,
                        identifier: record.identifier,
                        payload: record.payload
                    )
                }
                let nfcMessage = NFCNDEFMessage(records: nfcRecords)

                tag.writeNDEF(nfcMessage) { [weak self] error in
                    if let error {
                        session.invalidate(errorMessage: error.localizedDescription)
                        self?.completion(.failure(error))
                    } else {
                        session.invalidate()
                        self?.completion(.success(()))
                    }
                }
            }
        }
    }

    // MARK: - Private ISO 7816 Reader Delegate

    private final class ISO7816ReaderDelegate: NSObject, NFCTagReaderSessionDelegate, @unchecked Sendable {
        private let aid: Data
        private let completion: (Result<Data, Error>) -> Void

        init(aid: Data, completion: @escaping (Result<Data, Error>) -> Void) {
            self.aid = aid
            self.completion = completion
        }

        func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {}

        func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
            completion(.failure(error))
        }

        func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
            guard let tag = tags.first, case .iso7816(let iso7816Tag) = tag else {
                session.invalidate(errorMessage: "No ISO 7816 tag found.")
                return
            }

            session.connect(to: tag) { [weak self] error in
                guard let self else { return }
                if let error {
                    session.invalidate(errorMessage: error.localizedDescription)
                    completion(.failure(error))
                    return
                }

                let apdu = NFCISO7816APDU(
                    instructionClass: 0x00,
                    instructionCode: 0xA4,
                    p1Parameter: 0x04,
                    p2Parameter: 0x00,
                    data: aid,
                    expectedResponseLength: -1
                )

                iso7816Tag.sendCommand(apdu: apdu) { [weak self] data, _, _, error in
                    if let error {
                        session.invalidate(errorMessage: error.localizedDescription)
                        self?.completion(.failure(error))
                    } else {
                        session.invalidate()
                        self?.completion(.success(data))
                    }
                }
            }
        }
    }

    // MARK: - NFCTypeNameFormat Conversion

    extension NFCTypeNameFormat {
        fileprivate var toPrism: PrismNDEFTypeNameFormat {
            switch self {
            case .empty: .empty
            case .nfcWellKnown: .wellKnown
            case .media: .media
            case .absoluteURI: .absoluteURI
            case .nfcExternal: .external
            case .unknown: .unknown
            case .unchanged: .unchanged
            @unknown default: .unknown
            }
        }
    }

    extension PrismNDEFTypeNameFormat {
        fileprivate var toNFC: NFCTypeNameFormat {
            switch self {
            case .empty: .empty
            case .wellKnown: .nfcWellKnown
            case .media: .media
            case .absoluteURI: .absoluteURI
            case .external: .nfcExternal
            case .unknown: .unknown
            case .unchanged: .unchanged
            }
        }
    }
#endif
