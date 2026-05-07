import Foundation
import Testing

@testable import PrismStorage

@Suite("StoreErr")
struct PrismStorageErrorTests {
    @Test("All errors have descriptions")
    func descriptions() {
        let errors: [PrismStorageError] = [
            .encodingFailed("test"), .decodingFailed("test"),
            .writeFailed("test"), .readFailed("test"),
            .deleteFailed("test"), .keyNotFound("test"),
            .diskFull, .migrationFailed("test"),
            .containerNotAvailable, .transactionFailed("test"),
            .compressionFailed, .decompressionFailed,
            .encryptionFailed, .decryptionFailed,
            .quotaExceeded(1024), .invalidConfiguration("test"),
        ]
        for error in errors {
            #expect(error.errorDescription != nil)
        }
    }

    @Test("Errors are equatable")
    func equatable() {
        #expect(PrismStorageError.diskFull == .diskFull)
        #expect(PrismStorageError.encodingFailed("a") == .encodingFailed("a"))
        #expect(PrismStorageError.encodingFailed("a") != .encodingFailed("b"))
    }

    @Test("All error cases count")
    func allCases() {
        let errors: [PrismStorageError] = [
            .encodingFailed(""), .decodingFailed(""),
            .writeFailed(""), .readFailed(""),
            .deleteFailed(""), .keyNotFound(""),
            .diskFull, .migrationFailed(""),
            .containerNotAvailable, .transactionFailed(""),
            .compressionFailed, .decompressionFailed,
            .encryptionFailed, .decryptionFailed,
            .quotaExceeded(0), .invalidConfiguration(""),
        ]
        #expect(errors.count == 16)
    }
}

@Suite("StorageConfig")
struct PrismStorageConfigurationTests {
    @Test("Default configuration")
    func defaultConfig() {
        let config = PrismStorageConfiguration.default
        #expect(config.identifier == "default")
        #expect(config.maxSize == nil)
        #expect(config.defaultTTL == nil)
    }

    @Test("Custom configuration")
    func customConfig() {
        let config = PrismStorageConfiguration(
            identifier: "cache",
            maxSize: 1024 * 1024,
            defaultTTL: 300
        )
        #expect(config.identifier == "cache")
        #expect(config.maxSize == 1024 * 1024)
        #expect(config.defaultTTL == 300)
    }

    @Test("Configuration with nil optionals")
    func nilOptionals() {
        let config = PrismStorageConfiguration(identifier: "minimal")
        #expect(config.maxSize == nil)
        #expect(config.defaultTTL == nil)
    }
}

@Suite("StorageEvent")
struct PrismStorageEventTests {
    @Test("Event equatable")
    func equatable() {
        #expect(PrismStorageEvent.saved(key: "a") == .saved(key: "a"))
        #expect(PrismStorageEvent.saved(key: "a") != .saved(key: "b"))
        #expect(PrismStorageEvent.loaded(key: "x") == .loaded(key: "x"))
        #expect(PrismStorageEvent.deleted(key: "y") == .deleted(key: "y"))
        #expect(PrismStorageEvent.cleared == .cleared)
        #expect(PrismStorageEvent.expired(key: "z") == .expired(key: "z"))
        #expect(PrismStorageEvent.evicted(key: "w") == .evicted(key: "w"))
    }

    @Test("Different event kinds not equal")
    func differentKinds() {
        #expect(PrismStorageEvent.saved(key: "k") != .deleted(key: "k"))
        #expect(PrismStorageEvent.loaded(key: "k") != .expired(key: "k"))
        #expect(PrismStorageEvent.cleared != .saved(key: ""))
    }
}
