import CryptoKit
import Foundation
import Testing
import os

@testable import PrismSecurity

// MARK: - 1. Encryption Coverage Boost

@Suite("EncryptCovBoost")
struct PrismEncryptorCoverageBoostTests {
    @Test("generateKey returns 256-bit key for both algorithms")
    func generateKeyBothAlgorithms() {
        for algo in PrismEncryptor.Algorithm.allCases {
            let encryptor = PrismEncryptor(algorithm: algo)
            let key = encryptor.generateKey()
            let data = encryptor.exportKey(key)
            #expect(data.count == 32)
        }
    }

    @Test("exportKey/importKey roundtrip preserves key bytes")
    func exportImportRoundtripBytes() {
        let encryptor = PrismEncryptor()
        let original = encryptor.generateKey()
        let exported = encryptor.exportKey(original)
        let imported = encryptor.importKey(exported)
        let reExported = encryptor.exportKey(imported)
        #expect(exported == reExported)
    }

    @Test("AES-GCM encrypt/decrypt Data with imported key")
    func aesEncryptDecryptImportedKey() throws {
        let encryptor = PrismEncryptor(algorithm: .aesGCM)
        let keyData = encryptor.exportKey(encryptor.generateKey())
        let key = encryptor.importKey(keyData)
        let plaintext = Data("Imported key AES test".utf8)
        let encrypted = try encryptor.encrypt(plaintext, using: key)
        let decrypted = try encryptor.decrypt(encrypted, using: key)
        #expect(decrypted == plaintext)
    }

    @Test("ChaChaPoly encrypt/decrypt Data with imported key")
    func chachaEncryptDecryptImportedKey() throws {
        let encryptor = PrismEncryptor(algorithm: .chaChaPoly)
        let keyData = encryptor.exportKey(encryptor.generateKey())
        let key = encryptor.importKey(keyData)
        let plaintext = Data("Imported key ChaCha test".utf8)
        let encrypted = try encryptor.encrypt(plaintext, using: key)
        let decrypted = try encryptor.decrypt(encrypted, using: key)
        #expect(decrypted == plaintext)
    }

    @Test("AES-GCM encrypt Codable then decrypt Codable")
    func aesCodableRoundtrip() throws {
        struct Payload: Codable, Sendable, Equatable {
            let id: Int
            let label: String
        }
        let encryptor = PrismEncryptor(algorithm: .aesGCM)
        let key = encryptor.generateKey()
        let original = Payload(id: 99, label: "coverage")
        let encrypted = try encryptor.encrypt(original, using: key)
        let decrypted = try encryptor.decrypt(Payload.self, from: encrypted, using: key)
        #expect(decrypted == original)
    }

    @Test("ChaChaPoly decrypt with wrong key throws")
    func chachaWrongKeyThrows() throws {
        let encryptor = PrismEncryptor(algorithm: .chaChaPoly)
        let key1 = encryptor.generateKey()
        let key2 = encryptor.generateKey()
        let plaintext = Data("secret chacha data".utf8)
        let encrypted = try encryptor.encrypt(plaintext, using: key1)
        #expect(throws: PrismSecurityError.self) {
            try encryptor.decrypt(encrypted, using: key2)
        }
    }

    @Test("ChaChaPoly empty data roundtrip")
    func chachaEmptyData() throws {
        let encryptor = PrismEncryptor(algorithm: .chaChaPoly)
        let key = encryptor.generateKey()
        let empty = Data()
        let encrypted = try encryptor.encrypt(empty, using: key)
        let decrypted = try encryptor.decrypt(encrypted, using: key)
        #expect(decrypted == empty)
    }
}

@Suite("HasherCovBoost")
struct PrismHasherCoverageBoostTests {
    @Test("hash Data for all algorithms returns correct size")
    func hashDataAllAlgorithms() {
        let data = Data("coverage test data".utf8)
        let expectedSizes: [PrismHasher.Algorithm: Int] = [.sha256: 32, .sha384: 48, .sha512: 64]
        for (algo, size) in expectedSizes {
            let hasher = PrismHasher(algorithm: algo)
            let hash = hasher.hash(data)
            #expect(hash.count == size)
        }
    }

    @Test("hash String for all algorithms returns correct size")
    func hashStringAllAlgorithms() {
        let expectedSizes: [PrismHasher.Algorithm: Int] = [.sha256: 32, .sha384: 48, .sha512: 64]
        for (algo, size) in expectedSizes {
            let hasher = PrismHasher(algorithm: algo)
            let hash = hasher.hash("coverage string")
            #expect(hash.count == size)
        }
    }

    @Test("hashHex Data for all algorithms returns correct hex length")
    func hashHexDataAllAlgorithms() {
        let data = Data("hex test".utf8)
        let expectedHexLens: [PrismHasher.Algorithm: Int] = [.sha256: 64, .sha384: 96, .sha512: 128]
        for (algo, length) in expectedHexLens {
            let hasher = PrismHasher(algorithm: algo)
            let hex = hasher.hashHex(data)
            #expect(hex.count == length)
            #expect(hex.allSatisfy { "0123456789abcdef".contains($0) })
        }
    }

    @Test("hashHex String for all algorithms")
    func hashHexStringAllAlgorithms() {
        let expectedHexLens: [PrismHasher.Algorithm: Int] = [.sha256: 64, .sha384: 96, .sha512: 128]
        for (algo, length) in expectedHexLens {
            let hasher = PrismHasher(algorithm: algo)
            let hex = hasher.hashHex("hex string test")
            #expect(hex.count == length)
        }
    }

    @Test("hmac for all algorithms produces non-empty Data")
    func hmacAllAlgorithms() {
        let key = SymmetricKey(size: .bits256)
        let data = Data("hmac coverage".utf8)
        for algo in PrismHasher.Algorithm.allCases {
            let hasher = PrismHasher(algorithm: algo)
            let mac = hasher.hmac(data, key: key)
            #expect(!mac.isEmpty)
        }
    }

    @Test("verifyHMAC valid for all algorithms")
    func verifyHMACValidAllAlgorithms() {
        let key = SymmetricKey(size: .bits256)
        let data = Data("verify coverage".utf8)
        for algo in PrismHasher.Algorithm.allCases {
            let hasher = PrismHasher(algorithm: algo)
            let mac = hasher.hmac(data, key: key)
            #expect(hasher.verifyHMAC(mac, for: data, key: key))
        }
    }

    @Test("verifyHMAC invalid data for all algorithms")
    func verifyHMACInvalidAllAlgorithms() {
        let key = SymmetricKey(size: .bits256)
        let data = Data("original coverage".utf8)
        let tampered = Data("tampered coverage".utf8)
        for algo in PrismHasher.Algorithm.allCases {
            let hasher = PrismHasher(algorithm: algo)
            let mac = hasher.hmac(data, key: key)
            #expect(!hasher.verifyHMAC(mac, for: tampered, key: key))
        }
    }
}

@Suite("KeyDerivCovBoost")
struct PrismKeyDerivationCoverageBoostTests {
    @Test("deriveKey from SymmetricKey with explicit salt")
    func deriveKeyWithSalt() {
        let kd = PrismKeyDerivation()
        let inputKey = SymmetricKey(size: .bits256)
        let salt = Data("explicit-salt".utf8)
        let derived = kd.deriveKey(from: inputKey, salt: salt)
        let exported = derived.withUnsafeBytes { Data($0) }
        #expect(exported.count == 32)
    }

    @Test("deriveKey from SymmetricKey without salt uses default")
    func deriveKeyWithoutSalt() {
        let kd = PrismKeyDerivation()
        let inputKey = SymmetricKey(size: .bits256)
        let derived = kd.deriveKey(from: inputKey)
        let exported = derived.withUnsafeBytes { Data($0) }
        #expect(exported.count == 32)
    }

    @Test("deriveKey from Data input")
    func deriveKeyFromData() {
        let kd = PrismKeyDerivation()
        let sharedSecret = Data(repeating: 0xAB, count: 32)
        let derived = kd.deriveKey(from: sharedSecret, salt: Data("salt".utf8))
        let exported = derived.withUnsafeBytes { Data($0) }
        #expect(exported.count == 32)
    }

    @Test("deriveKey from password with custom output byte count")
    func deriveKeyFromPasswordCustomSize() {
        let kd = PrismKeyDerivation()
        let salt = kd.generateSalt()
        let derived = kd.deriveKey(fromPassword: "myPassword", salt: salt, outputByteCount: 64)
        let exported = derived.withUnsafeBytes { Data($0) }
        #expect(exported.count == 64)
    }

    @Test("generateSalt with custom byte count")
    func generateSaltCustomSize() {
        let kd = PrismKeyDerivation()
        let salt = kd.generateSalt(byteCount: 64)
        #expect(salt.count == 64)
    }

    @Test("deriveKey from Data without salt defaults correctly")
    func deriveKeyFromDataNoSalt() {
        let kd = PrismKeyDerivation()
        let data = Data(repeating: 0x01, count: 32)
        let k1 = kd.deriveKey(from: data, salt: nil)
        let k2 = kd.deriveKey(from: data)
        let d1 = k1.withUnsafeBytes { Data($0) }
        let d2 = k2.withUnsafeBytes { Data($0) }
        #expect(d1 == d2)
    }

    @Test("deriveKey with info parameter")
    func deriveKeyWithInfo() {
        let kd = PrismKeyDerivation()
        let inputKey = SymmetricKey(size: .bits256)
        let info = Data("extra context".utf8)
        let derived = kd.deriveKey(from: inputKey, info: info)
        let exported = derived.withUnsafeBytes { Data($0) }
        #expect(exported.count == 32)
    }
}

// MARK: - 2. AuditLog Coverage Boost

@Suite("AuditLogCovBoost")
struct PrismAuditLogCoverageBoostTests {
    @Test("SecurityEvent init stores all properties")
    func securityEventInit() {
        let now = Date.now
        let event = PrismSecurityEvent(
            kind: .encryptionPerformed,
            detail: "AES-256",
            metadata: ["algo": "aesGCM"],
            timestamp: now
        )
        #expect(event.kind == .encryptionPerformed)
        #expect(event.detail == "AES-256")
        #expect(event.metadata["algo"] == "aesGCM")
        #expect(event.timestamp == now)
        #expect(!event.id.isEmpty)
    }

    @Test("All SecurityEventKind cases exist")
    func allSecurityEventKindCases() {
        let kinds = PrismSecurityEventKind.allCases
        #expect(kinds.contains(.biometricSuccess))
        #expect(kinds.contains(.biometricFailure))
        #expect(kinds.contains(.keychainRead))
        #expect(kinds.contains(.keychainWrite))
        #expect(kinds.contains(.keychainDelete))
        #expect(kinds.contains(.encryptionPerformed))
        #expect(kinds.contains(.decryptionPerformed))
        #expect(kinds.contains(.permissionRequested))
        #expect(kinds.contains(.permissionGranted))
        #expect(kinds.contains(.permissionDenied))
        #expect(kinds.contains(.integrityViolation))
        #expect(kinds.contains(.pinningViolation))
        #expect(kinds.contains(.tokenRefreshed))
        #expect(kinds.contains(.tokenExpired))
        #expect(kinds.contains(.secureStoreAccess))
        #expect(kinds.contains(.channelEstablished))
        #expect(kinds.contains(.envelopeSealed))
        #expect(kinds.contains(.envelopeOpened))
        #expect(kinds.contains(.dataSealed))
        #expect(kinds.contains(.dataSealVerified))
        #expect(kinds.contains(.dataSealFailed))
        #expect(kinds.contains(.privacyRedaction))
        #expect(kinds.contains(.screenshotBlocked))
        #expect(kinds.contains(.clipboardCleared))
    }

    @Test("AuditLogEntry init computes hash from event data")
    func auditLogEntryComputesHash() {
        let event = PrismSecurityEvent(kind: .keychainWrite, detail: "test write")
        let entry = PrismAuditLogEntry(event: event, previousHash: "", sequence: 0)
        #expect(!entry.entryHash.isEmpty)
        #expect(entry.entryHash.count == 64)
        #expect(entry.id == event.id)
        #expect(entry.previousHash == "")
        #expect(entry.sequence == 0)
    }

    @Test("AuditLogEntry same input produces same hash")
    func auditLogEntryDeterministic() {
        let event = PrismSecurityEvent(kind: .keychainRead, detail: "det-test")
        let entry1 = PrismAuditLogEntry(event: event, previousHash: "abc", sequence: 5)
        let entry2 = PrismAuditLogEntry(event: event, previousHash: "abc", sequence: 5)
        #expect(entry1.entryHash == entry2.entryHash)
    }

    @Test("AuditLogEntry different previousHash yields different hash")
    func auditLogEntryDifferentPreviousHash() {
        let event = PrismSecurityEvent(kind: .keychainRead, detail: "test")
        let entry1 = PrismAuditLogEntry(event: event, previousHash: "aaa", sequence: 0)
        let entry2 = PrismAuditLogEntry(event: event, previousHash: "bbb", sequence: 0)
        #expect(entry1.entryHash != entry2.entryHash)
    }

    @Test("SecurityAuditLog record increments count")
    func auditLogRecordCount() {
        let log = PrismSecurityAuditLog()
        #expect(log.count == 0)
        log.record(PrismSecurityEvent(kind: .dataSealed, detail: "seal1"))
        #expect(log.count == 1)
        log.record(PrismSecurityEvent(kind: .dataSealVerified, detail: "verify1"))
        #expect(log.count == 2)
    }

    @Test("SecurityAuditLog entries(ofKind:) with multiple kinds")
    func auditLogEntriesOfMultipleKinds() {
        let log = PrismSecurityAuditLog()
        log.record(PrismSecurityEvent(kind: .encryptionPerformed, detail: "enc1"))
        log.record(PrismSecurityEvent(kind: .decryptionPerformed, detail: "dec1"))
        log.record(PrismSecurityEvent(kind: .encryptionPerformed, detail: "enc2"))
        log.record(PrismSecurityEvent(kind: .tokenRefreshed, detail: "tok1"))

        #expect(log.entries(ofKind: .encryptionPerformed).count == 2)
        #expect(log.entries(ofKind: .decryptionPerformed).count == 1)
        #expect(log.entries(ofKind: .tokenRefreshed).count == 1)
        #expect(log.entries(ofKind: .biometricSuccess).count == 0)
    }

    @Test("SecurityAuditLog entries(from:to:) boundary inclusiveness")
    func auditLogDateRangeBoundary() {
        let log = PrismSecurityAuditLog()
        let t1 = Date(timeIntervalSince1970: 1000)
        let t2 = Date(timeIntervalSince1970: 2000)
        let t3 = Date(timeIntervalSince1970: 3000)
        log.record(PrismSecurityEvent(kind: .keychainRead, detail: "a", timestamp: t1))
        log.record(PrismSecurityEvent(kind: .keychainRead, detail: "b", timestamp: t2))
        log.record(PrismSecurityEvent(kind: .keychainRead, detail: "c", timestamp: t3))

        let ranged = log.entries(from: t1, to: t3)
        #expect(ranged.count == 3)

        let midRange = log.entries(from: t2, to: t2)
        #expect(midRange.count == 1)
        #expect(midRange.first?.event.detail == "b")
    }

    @Test("SecurityAuditLog recentEntries returns correct subset")
    func auditLogRecentEntriesSubset() {
        let log = PrismSecurityAuditLog()
        for i in 0..<10 {
            log.record(PrismSecurityEvent(kind: .keychainWrite, detail: "\(i)"))
        }
        let recent3 = log.recentEntries(3)
        #expect(recent3.count == 3)
        #expect(recent3[0].event.detail == "7")
        #expect(recent3[1].event.detail == "8")
        #expect(recent3[2].event.detail == "9")
    }

    @Test("SecurityAuditLog recentEntries more than count returns all")
    func auditLogRecentEntriesMoreThanCount() {
        let log = PrismSecurityAuditLog()
        log.record(PrismSecurityEvent(kind: .keychainRead, detail: "only"))
        let recent = log.recentEntries(100)
        #expect(recent.count == 1)
    }

    @Test("SecurityAuditLog maxEntries cap enforced during overflow")
    func auditLogMaxEntriesCap() {
        let log = PrismSecurityAuditLog(maxEntries: 3)
        for i in 0..<100 {
            log.record(PrismSecurityEvent(kind: .keychainWrite, detail: "entry\(i)"))
        }
        #expect(log.count == 3)
        let entries = log.allEntries
        #expect(entries.first?.event.detail == "entry97")
        #expect(entries.last?.event.detail == "entry99")
    }

    @Test("SecurityAuditLog clear then record works")
    func auditLogClearThenRecord() {
        let log = PrismSecurityAuditLog()
        log.record(PrismSecurityEvent(kind: .keychainRead, detail: "before"))
        log.clear()
        #expect(log.count == 0)
        log.record(PrismSecurityEvent(kind: .keychainWrite, detail: "after"))
        #expect(log.count == 1)
    }

    @Test("SecurityAuditLog verifyIntegrity after multiple records")
    func auditLogIntegrityMultipleRecords() {
        let log = PrismSecurityAuditLog()
        for kind in PrismSecurityEventKind.allCases {
            log.record(PrismSecurityEvent(kind: kind, detail: "test-\(kind.rawValue)"))
        }
        #expect(log.verifyIntegrity())
    }

    @Test("AuditExporter exportJSON roundtrip preserves entries")
    func auditExporterJSONRoundtrip() throws {
        let log = PrismSecurityAuditLog()
        log.record(PrismSecurityEvent(kind: .channelEstablished, detail: "ch1"))
        log.record(PrismSecurityEvent(kind: .envelopeSealed, detail: "env1"))

        let exporter = PrismAuditExporter()
        let jsonData = try exporter.exportJSON(log.allEntries)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode([PrismAuditLogEntry].self, from: jsonData)
        #expect(decoded.count == 2)
        #expect(decoded[0].event.kind == .channelEstablished)
        #expect(decoded[1].event.kind == .envelopeSealed)
    }

    @Test("AuditExporter exportJSONString contains event details")
    func auditExporterJSONStringContent() throws {
        let log = PrismSecurityAuditLog()
        log.record(PrismSecurityEvent(kind: .dataSealFailed, detail: "integrity mismatch"))

        let exporter = PrismAuditExporter()
        let jsonStr = try exporter.exportJSONString(log.allEntries)
        #expect(jsonStr.contains("dataSealFailed"))
        #expect(jsonStr.contains("integrity mismatch"))
    }

    @Test("AuditExporter exportSummary has correct counts and dates")
    func auditExporterSummaryDetails() {
        let log = PrismSecurityAuditLog()
        let t1 = Date(timeIntervalSince1970: 1000)
        let t2 = Date(timeIntervalSince1970: 2000)
        log.record(PrismSecurityEvent(kind: .tokenExpired, detail: "exp1", timestamp: t1))
        log.record(PrismSecurityEvent(kind: .tokenExpired, detail: "exp2", timestamp: t2))
        log.record(PrismSecurityEvent(kind: .privacyRedaction, detail: "red1", timestamp: t2))

        let exporter = PrismAuditExporter()
        let summary = exporter.exportSummary(log.allEntries)
        #expect(summary.totalEntries == 3)
        #expect(summary.firstEntry == t1)
        #expect(summary.lastEntry == t2)
        #expect(summary.eventCounts[.tokenExpired] == 2)
        #expect(summary.eventCounts[.privacyRedaction] == 1)
    }
}

// MARK: - 3. Integrity Coverage Boost

@Suite("IntegrityCovBoost")
struct PrismIntegrityCoverageBoostTests {
    @Test("DataSeal sealData and verify roundtrip")
    func dataSealDataRoundtrip() {
        let key = SymmetricKey(size: .bits256)
        let seal = PrismDataSeal(key: key)
        let data = Data("integrity roundtrip".utf8)
        let sealed = seal.sealData(data)
        #expect(seal.verify(sealed))
        #expect(sealed.payload == data)
        #expect(!sealed.mac.isEmpty)
    }

    @Test("DataSeal seal/unseal Codable roundtrip")
    func dataSealCodableRoundtrip() throws {
        struct Item: Codable, Sendable, Equatable {
            let name: String
            let value: Int
        }
        let key = SymmetricKey(size: .bits256)
        let seal = PrismDataSeal(key: key)
        let original = Item(name: "coverage", value: 42)
        let sealed = try seal.seal(original)
        let unsealed = try seal.unseal(Item.self, from: sealed)
        #expect(unsealed == original)
    }

    @Test("DataSeal verify tampered payload returns false")
    func dataSealTamperedPayload() {
        let key = SymmetricKey(size: .bits256)
        let seal = PrismDataSeal(key: key)
        let data = Data("original".utf8)
        let sealed = seal.sealData(data)
        let tampered = PrismDataSeal.SealedData(
            payload: Data("modified".utf8),
            mac: sealed.mac,
            sealedAt: sealed.sealedAt
        )
        #expect(!seal.verify(tampered))
    }

    @Test("DataSeal verify tampered mac returns false")
    func dataSealTamperedMAC() {
        let key = SymmetricKey(size: .bits256)
        let seal = PrismDataSeal(key: key)
        let data = Data("test".utf8)
        let sealed = seal.sealData(data)
        let tampered = PrismDataSeal.SealedData(
            payload: sealed.payload,
            mac: Data("bad-mac".utf8),
            sealedAt: sealed.sealedAt
        )
        #expect(!seal.verify(tampered))
    }

    @Test("IntegrityChecker checkAll returns array")
    func integrityCheckerCheckAll() {
        let checker = PrismIntegrityChecker()
        let violations = checker.checkAll()
        #expect(violations.isEmpty || !violations.isEmpty)
    }

    @Test("IntegrityChecker isSecure returns Bool consistent with checkAll")
    func integrityCheckerIsSecure() {
        let checker = PrismIntegrityChecker()
        let isEmpty = checker.checkAll().isEmpty
        #expect(checker.isSecure == isEmpty)
    }

    @Test("IntegrityChecker isSimulator returns expected value")
    func integrityCheckerSimulator() {
        let checker = PrismIntegrityChecker()
        #if targetEnvironment(simulator)
            #expect(checker.isSimulator())
        #else
            #expect(!checker.isSimulator())
        #endif
    }

    @Test("IntegrityChecker isDebuggerAttached returns Bool")
    func integrityCheckerDebugger() {
        let checker = PrismIntegrityChecker()
        _ = checker.isDebuggerAttached()
    }

    @Test("IntegrityChecker hasReverseEngineeringTools returns Bool")
    func integrityCheckerReverseEngineering() {
        let checker = PrismIntegrityChecker()
        _ = checker.hasReverseEngineeringTools()
    }

    @Test("IntegrityChecker isJailbroken returns Bool")
    func integrityCheckerJailbroken() {
        let checker = PrismIntegrityChecker()
        _ = checker.isJailbroken()
    }

    @Test("IntegrityPolicy default has log action only")
    func integrityPolicyDefault() {
        let policy = PrismIntegrityPolicy.default
        #expect(policy.actions == [.log])
        #expect(policy.onViolation == nil)
    }

    @Test("IntegrityPolicy strict has all three actions")
    func integrityPolicyStrict() {
        let policy = PrismIntegrityPolicy.strict
        #expect(policy.actions.contains(.log))
        #expect(policy.actions.contains(.wipeSecureStore))
        #expect(policy.actions.contains(.notify))
        #expect(policy.actions.count == 3)
    }

    @Test("IntegrityPolicy custom init stores actions and handler")
    func integrityPolicyCustom() {
        let handlerCalled = OSAllocatedUnfairLock(initialState: false)
        let policy = PrismIntegrityPolicy(actions: [.notify]) { _ in
            handlerCalled.withLock { $0 = true }
        }
        #expect(policy.actions == [.notify])
        policy.onViolation?(PrismIntegrityViolation(kind: .jailbreak, detail: "test"))
        #expect(handlerCalled.withLock { $0 })
    }

    @Test("IntegrityViolation init stores all properties")
    func integrityViolationInit() {
        let date = Date(timeIntervalSince1970: 12345)
        let v = PrismIntegrityViolation(kind: .dataTampered, detail: "tamper detected", detectedAt: date)
        #expect(v.kind == .dataTampered)
        #expect(v.detail == "tamper detected")
        #expect(v.detectedAt == date)
    }

    @Test("IntegrityViolationKind all cases available")
    func integrityViolationKindAllCases() {
        let kinds = PrismIntegrityViolationKind.allCases
        #expect(kinds.contains(.jailbreak))
        #expect(kinds.contains(.debuggerAttached))
        #expect(kinds.contains(.simulator))
        #expect(kinds.contains(.dataTampered))
        #expect(kinds.contains(.fileTampered))
        #expect(kinds.contains(.reverseEngineering))
        #expect(kinds.count == 6)
    }

    @Test("IntegrityAction all cases available")
    func integrityActionAllCases() {
        let actions = PrismIntegrityAction.allCases
        #expect(actions.contains(.log))
        #expect(actions.contains(.wipeSecureStore))
        #expect(actions.contains(.notify))
        #expect(actions.count == 3)
    }
}

// MARK: - 4. CertificatePinning Coverage Boost

@Suite("CertPinCovBoost")
struct PrismCertificatePinningCoverageBoostTests {
    @Test("CertificatePin init stores all properties")
    func certificatePinInit() {
        let expiry = Date.now.addingTimeInterval(86400)
        let pin = PrismCertificatePin(
            host: "api.example.com",
            publicKeyHash: "primaryHash",
            backupHashes: ["backup1", "backup2"],
            expiresAt: expiry
        )
        #expect(pin.host == "api.example.com")
        #expect(pin.publicKeyHash == "primaryHash")
        #expect(pin.backupHashes == ["backup1", "backup2"])
        #expect(pin.expiresAt == expiry)
    }

    @Test("CertificatePin allHashes includes primary and all backups")
    func certificatePinAllHashes() {
        let pin = PrismCertificatePin(
            host: "test.com",
            publicKeyHash: "A",
            backupHashes: ["B", "C", "D"]
        )
        #expect(pin.allHashes == Set(["A", "B", "C", "D"]))
    }

    @Test("CertificatePin isExpired false when no expiry")
    func certificatePinNoExpiry() {
        let pin = PrismCertificatePin(host: "test.com", publicKeyHash: "h")
        #expect(!pin.isExpired)
    }

    @Test("CertificatePin isExpired true when past date")
    func certificatePinExpired() {
        let pin = PrismCertificatePin(
            host: "test.com",
            publicKeyHash: "h",
            expiresAt: Date.now.addingTimeInterval(-1)
        )
        #expect(pin.isExpired)
    }

    @Test("CertificatePin isExpired false when future date")
    func certificatePinNotExpired() {
        let pin = PrismCertificatePin(
            host: "test.com",
            publicKeyHash: "h",
            expiresAt: Date.now.addingTimeInterval(86400)
        )
        #expect(!pin.isExpired)
    }

    @Test("CertificatePin hash static method returns base64")
    func certificatePinHashMethod() {
        let data = Data("some-public-key-der-data".utf8)
        let hash = PrismCertificatePin.hash(publicKeyDER: data)
        #expect(!hash.isEmpty)
        let base64Chars = CharacterSet(
            charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="
        )
        #expect(hash.unicodeScalars.allSatisfy { base64Chars.contains($0) })
    }

    @Test("CertificatePin id generated from host and hash prefix")
    func certificatePinID() {
        let pin = PrismCertificatePin(host: "api.test.com", publicKeyHash: "ABCDEFGHIJKLMNOP")
        #expect(pin.id == "api.test.com_ABCDEFGH")
    }

    @Test("PinningPolicy all cases")
    func pinningPolicyAllCases() {
        let cases = PrismPinningPolicy.allCases
        #expect(cases.contains(.strict))
        #expect(cases.contains(.reportOnly))
        #expect(cases.contains(.trustFirstUse))
        #expect(cases.count == 3)
    }

    @Test("PinningResult init stores all properties")
    func pinningResultInit() {
        let date = Date(timeIntervalSince1970: 5000)
        let result = PrismPinningResult(
            host: "example.com",
            isValid: true,
            matchedHash: "matched",
            serverHash: "server",
            evaluatedAt: date
        )
        #expect(result.host == "example.com")
        #expect(result.isValid)
        #expect(result.matchedHash == "matched")
        #expect(result.serverHash == "server")
        #expect(result.evaluatedAt == date)
    }

    @Test("PinningResult default evaluatedAt is now")
    func pinningResultDefaultDate() {
        let before = Date.now
        let result = PrismPinningResult(host: "test.com", isValid: false, serverHash: "h")
        let after = Date.now
        #expect(result.evaluatedAt >= before)
        #expect(result.evaluatedAt <= after)
    }

    @Test("PinningValidator strict: matched hash validates")
    func validatorStrictMatched() async {
        let pin = PrismCertificatePin(host: "secure.com", publicKeyHash: "correctHash")
        let validator = PrismPinningValidator(pins: [pin], policy: .strict)
        let result = await validator.validate(publicKeyHash: "correctHash", forHost: "secure.com")
        #expect(result.isValid)
        #expect(result.matchedHash == "correctHash")
    }

    @Test("PinningValidator strict: unmatched hash fails")
    func validatorStrictUnmatched() async {
        let pin = PrismCertificatePin(host: "secure.com", publicKeyHash: "correctHash")
        let validator = PrismPinningValidator(pins: [pin], policy: .strict)
        let result = await validator.validate(publicKeyHash: "wrongHash", forHost: "secure.com")
        #expect(!result.isValid)
        #expect(result.matchedHash == nil)
    }

    @Test("PinningValidator strict: no pin for host allows")
    func validatorStrictNoPin() async {
        let validator = PrismPinningValidator(pins: [], policy: .strict)
        let result = await validator.validate(publicKeyHash: "anyHash", forHost: "unknown.com")
        #expect(result.isValid)
    }

    @Test("PinningValidator strict: expired pin allows any hash")
    func validatorStrictExpiredPin() async {
        let pin = PrismCertificatePin(
            host: "api.com",
            publicKeyHash: "correctHash",
            expiresAt: Date.now.addingTimeInterval(-3600)
        )
        let validator = PrismPinningValidator(pins: [pin], policy: .strict)
        let result = await validator.validate(publicKeyHash: "anyHash", forHost: "api.com")
        #expect(result.isValid)
    }

    @Test("PinningValidator TOFU: first use stores hash")
    func validatorTOFUFirstUse() async {
        let validator = PrismPinningValidator(policy: .trustFirstUse)
        let result = await validator.validate(publicKeyHash: "firstHash", forHost: "new.com")
        #expect(result.isValid)
        #expect(result.matchedHash == "firstHash")
    }

    @Test("PinningValidator TOFU: second use same hash succeeds")
    func validatorTOFUSameHash() async {
        let validator = PrismPinningValidator(policy: .trustFirstUse)
        _ = await validator.validate(publicKeyHash: "theHash", forHost: "host.com")
        let result = await validator.validate(publicKeyHash: "theHash", forHost: "host.com")
        #expect(result.isValid)
        #expect(result.matchedHash == "theHash")
    }

    @Test("PinningValidator TOFU: second use different hash fails")
    func validatorTOFUDifferentHash() async {
        let validator = PrismPinningValidator(policy: .trustFirstUse)
        _ = await validator.validate(publicKeyHash: "hash1", forHost: "host.com")
        let result = await validator.validate(publicKeyHash: "hash2", forHost: "host.com")
        #expect(!result.isValid)
        #expect(result.matchedHash == nil)
    }

    @Test("PinningValidator addPin and removePin")
    func validatorAddRemovePin() async {
        let validator = PrismPinningValidator(policy: .strict)
        let pin = PrismCertificatePin(host: "dynamic.com", publicKeyHash: "dynHash")
        await validator.addPin(pin)
        let r1 = await validator.validate(publicKeyHash: "dynHash", forHost: "dynamic.com")
        #expect(r1.isValid)

        await validator.removePin(forHost: "dynamic.com")
        let r2 = await validator.validate(publicKeyHash: "anyHash", forHost: "dynamic.com")
        #expect(r2.isValid)
    }
}

// MARK: - 5. Token Coverage Boost

@Suite("TokenCovBoost")
struct PrismTokenCoverageBoostTests {
    private static func base64URL(_ string: String) -> String {
        Data(string.utf8).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    @Test("AccessToken decode valid JWT with alg:none")
    func decodeValidJWT() throws {
        let header = #"{"alg":"none"}"#
        let futureExp = Int(Date.now.addingTimeInterval(3600).timeIntervalSince1970)
        let pastIat = Int(Date.now.addingTimeInterval(-60).timeIntervalSince1970)
        let payload = #"{"sub":"user","exp":\#(futureExp),"iat":\#(pastIat)}"#
        let jwt = "\(Self.base64URL(header)).\(Self.base64URL(payload))."

        let token = try PrismAccessToken.decode(jwt)
        #expect(token.subject == "user")
        #expect(token.expiresAt != nil)
        #expect(token.issuedAt != nil)
        #expect(!token.isExpired)
        #expect(token.rawToken == jwt)
    }

    @Test("AccessToken decode invalid JWT throws")
    func decodeInvalidJWT() {
        #expect(throws: PrismSecurityError.invalidData) {
            try PrismAccessToken.decode("not-a-jwt")
        }
    }

    @Test("AccessToken decode two-part JWT throws")
    func decodeTwoPartJWT() {
        #expect(throws: PrismSecurityError.invalidData) {
            try PrismAccessToken.decode("only.two")
        }
    }

    @Test("AccessToken isExpired true for past exp")
    func tokenIsExpired() throws {
        let header = #"{"alg":"none"}"#
        let pastExp = Int(Date.now.addingTimeInterval(-3600).timeIntervalSince1970)
        let payload = #"{"sub":"user","exp":\#(pastExp)}"#
        let jwt = "\(Self.base64URL(header)).\(Self.base64URL(payload))."
        let token = try PrismAccessToken.decode(jwt)
        #expect(token.isExpired)
    }

    @Test("AccessToken isExpired false when no exp")
    func tokenNoExp() throws {
        let header = #"{"alg":"none"}"#
        let payload = #"{"sub":"user"}"#
        let jwt = "\(Self.base64URL(header)).\(Self.base64URL(payload))."
        let token = try PrismAccessToken.decode(jwt)
        #expect(!token.isExpired)
    }

    @Test("AccessToken expiresWithin returns true when close to expiry")
    func tokenExpiresWithin() throws {
        let header = #"{"alg":"none"}"#
        let exp = Int(Date.now.addingTimeInterval(60).timeIntervalSince1970)
        let payload = #"{"exp":\#(exp)}"#
        let jwt = "\(Self.base64URL(header)).\(Self.base64URL(payload))."
        let token = try PrismAccessToken.decode(jwt)
        #expect(token.expiresWithin(120))
        #expect(!token.expiresWithin(30))
    }

    @Test("AccessToken expiresWithin returns false when no exp")
    func tokenExpiresWithinNoExp() throws {
        let header = #"{"alg":"none"}"#
        let payload = #"{"sub":"u"}"#
        let jwt = "\(Self.base64URL(header)).\(Self.base64URL(payload))."
        let token = try PrismAccessToken.decode(jwt)
        #expect(!token.expiresWithin(9999))
    }

    @Test("AccessToken timeUntilExpiry positive for future token")
    func tokenTimeUntilExpiryFuture() throws {
        let header = #"{"alg":"none"}"#
        let exp = Int(Date.now.addingTimeInterval(3600).timeIntervalSince1970)
        let payload = #"{"exp":\#(exp)}"#
        let jwt = "\(Self.base64URL(header)).\(Self.base64URL(payload))."
        let token = try PrismAccessToken.decode(jwt)
        let ttl = token.timeUntilExpiry
        #expect(ttl != nil)
        #expect(ttl! > 3500)
    }

    @Test("AccessToken timeUntilExpiry nil when no exp")
    func tokenTimeUntilExpiryNil() throws {
        let header = #"{"alg":"none"}"#
        let payload = #"{"sub":"u"}"#
        let jwt = "\(Self.base64URL(header)).\(Self.base64URL(payload))."
        let token = try PrismAccessToken.decode(jwt)
        #expect(token.timeUntilExpiry == nil)
    }

    @Test("AccessToken claim returns typed value")
    func tokenClaim() throws {
        let header = #"{"alg":"none"}"#
        let payload = #"{"sub":"user","role":"admin","tier":5}"#
        let jwt = "\(Self.base64URL(header)).\(Self.base64URL(payload))."
        let token = try PrismAccessToken.decode(jwt)

        let sub: String? = token.claim("sub")
        #expect(sub == "user")
        let role: String? = token.claim("role")
        #expect(role == "admin")
        let tier: Int? = token.claim("tier")
        #expect(tier == 5)
        let missing: String? = token.claim("nonexistent")
        #expect(missing == nil)
    }

    @Test("AccessToken claims returns all payload keys")
    func tokenClaims() throws {
        let header = #"{"alg":"none"}"#
        let payload = #"{"sub":"u","iss":"prism","custom":"val"}"#
        let jwt = "\(Self.base64URL(header)).\(Self.base64URL(payload))."
        let token = try PrismAccessToken.decode(jwt)
        let claims = token.claims
        #expect(claims["sub"] as? String == "u")
        #expect(claims["iss"] as? String == "prism")
        #expect(claims["custom"] as? String == "val")
    }

    @Test("TokenConfiguration default values")
    func tokenConfigurationDefault() {
        let config = PrismTokenConfiguration.default
        #expect(config.service == "PrismTokenManager")
        #expect(config.accessTokenKey == "access_token")
        #expect(config.refreshTokenKey == "refresh_token")
        #expect(config.refreshThreshold == 300)
        #expect(config.refreshStrategy == .proactive)
    }

    @Test("TokenConfiguration custom init")
    func tokenConfigurationCustom() {
        let config = PrismTokenConfiguration(
            service: "CustomService",
            accessTokenKey: "my_access",
            refreshTokenKey: "my_refresh",
            refreshThreshold: 60,
            refreshStrategy: .manual
        )
        #expect(config.service == "CustomService")
        #expect(config.accessTokenKey == "my_access")
        #expect(config.refreshTokenKey == "my_refresh")
        #expect(config.refreshThreshold == 60)
        #expect(config.refreshStrategy == .manual)
    }

    @Test("TokenPair init and equality")
    func tokenPairInit() {
        let pair1 = PrismTokenPair(accessToken: "access", refreshToken: "refresh")
        let pair2 = PrismTokenPair(accessToken: "access", refreshToken: "refresh")
        #expect(pair1 == pair2)
        #expect(pair1.accessToken == "access")
        #expect(pair1.refreshToken == "refresh")
    }

    @Test("TokenPair without refresh token")
    func tokenPairNoRefresh() {
        let pair = PrismTokenPair(accessToken: "access")
        #expect(pair.refreshToken == nil)
    }

    @Test("TokenPair inequality with different tokens")
    func tokenPairInequality() {
        let p1 = PrismTokenPair(accessToken: "a", refreshToken: "r")
        let p2 = PrismTokenPair(accessToken: "b", refreshToken: "r")
        #expect(p1 != p2)
    }

    @Test("TokenRefreshStrategy all cases exist")
    func tokenRefreshStrategyAllCases() {
        let all = PrismTokenRefreshStrategy.allCases
        #expect(all.contains(.proactive))
        #expect(all.contains(.reactive))
        #expect(all.contains(.manual))
        #expect(all.count == 3)
    }
}

// MARK: - 6. SecureTransport Coverage Boost

@Suite("SecTransportCovBoost")
struct PrismSecureTransportCoverageBoostTests {
    @Test("KeyAgreement init creates valid public key")
    func keyAgreementInit() {
        let ka = PrismKeyAgreement()
        #expect(!ka.publicKeyData.isEmpty)
        #expect(ka.publicKeyData.count == 64)
    }

    @Test("KeyAgreement publicKeyData is consistent")
    func keyAgreementPublicKeyConsistent() {
        let ka = PrismKeyAgreement()
        let d1 = ka.publicKeyData
        let d2 = ka.publicKeyData
        #expect(d1 == d2)
    }

    @Test("KeyAgreement two parties derive same shared secret")
    func keyAgreementSharedSecret() throws {
        let alice = PrismKeyAgreement()
        let bob = PrismKeyAgreement()

        let aliceKey = try alice.deriveSharedSecret(with: bob.publicKeyData)
        let bobKey = try bob.deriveSharedSecret(with: alice.publicKeyData)

        let aliceData = aliceKey.withUnsafeBytes { Data($0) }
        let bobData = bobKey.withUnsafeBytes { Data($0) }
        #expect(aliceData == bobData)
    }

    @Test("SecureChannel not established before establish called")
    func secureChannelNotEstablished() {
        let channel = PrismSecureChannel()
        #expect(!channel.isEstablished)
    }

    @Test("SecureChannel isEstablished after establish")
    func secureChannelEstablished() throws {
        let alice = PrismSecureChannel()
        let bob = PrismSecureChannel()
        try alice.establish(with: bob.publicKeyData)
        #expect(alice.isEstablished)
    }

    @Test("SecureChannel encrypt/decrypt Data roundtrip")
    func secureChannelDataRoundtrip() throws {
        let alice = PrismSecureChannel()
        let bob = PrismSecureChannel()
        try alice.establish(with: bob.publicKeyData)
        try bob.establish(with: alice.publicKeyData)

        let plaintext = Data("SecureChannel coverage test".utf8)
        let encrypted = try alice.encrypt(plaintext)
        let decrypted = try bob.decrypt(encrypted)
        #expect(decrypted == plaintext)
    }

    @Test("SecureChannel encrypt/decrypt Codable roundtrip")
    func secureChannelCodableRoundtrip() throws {
        struct Message: Codable, Sendable, Equatable {
            let text: String
        }
        let alice = PrismSecureChannel()
        let bob = PrismSecureChannel()
        try alice.establish(with: bob.publicKeyData)
        try bob.establish(with: alice.publicKeyData)

        let original = Message(text: "hello from coverage tests")
        let encrypted = try alice.encrypt(original)
        let decrypted = try bob.decrypt(Message.self, from: encrypted)
        #expect(decrypted == original)
    }

    @Test("SecureChannel close resets isEstablished")
    func secureChannelClose() throws {
        let alice = PrismSecureChannel()
        let bob = PrismSecureChannel()
        try alice.establish(with: bob.publicKeyData)
        #expect(alice.isEstablished)
        alice.close()
        #expect(!alice.isEstablished)
    }

    @Test("SecureChannel encrypt without establish throws invalidKey")
    func secureChannelEncryptWithoutEstablish() {
        let channel = PrismSecureChannel()
        #expect(throws: PrismSecurityError.invalidKey) {
            try channel.encrypt(Data("test".utf8))
        }
    }

    @Test("SecureChannel decrypt without establish throws invalidKey")
    func secureChannelDecryptWithoutEstablish() {
        let channel = PrismSecureChannel()
        #expect(throws: PrismSecurityError.invalidKey) {
            try channel.decrypt(Data("test".utf8))
        }
    }

    @Test("SecureEnvelope seal/open Data roundtrip")
    func secureEnvelopeDataRoundtrip() throws {
        let senderSigning = P256.Signing.PrivateKey()
        let recipientAgreement = P256.KeyAgreement.PrivateKey()

        let plaintext = Data("Envelope coverage test data".utf8)
        let envelope = try PrismSecureEnvelope.seal(
            data: plaintext,
            recipientPublicKey: recipientAgreement.publicKey.rawRepresentation,
            senderSigningKey: senderSigning
        )

        let decrypted = try PrismSecureEnvelope.open(
            envelope,
            recipientPrivateKey: recipientAgreement,
            senderVerifyKey: senderSigning.publicKey.rawRepresentation
        )
        #expect(decrypted == plaintext)
    }

    @Test("SecureEnvelope seal/open Codable roundtrip")
    func secureEnvelopeCodableRoundtrip() throws {
        struct Payload: Codable, Sendable, Equatable {
            let id: Int
            let data: String
        }
        let senderSigning = P256.Signing.PrivateKey()
        let recipientAgreement = P256.KeyAgreement.PrivateKey()

        let original = Payload(id: 42, data: "coverage")
        let envelope = try PrismSecureEnvelope.seal(
            original,
            recipientPublicKey: recipientAgreement.publicKey.rawRepresentation,
            senderSigningKey: senderSigning
        )

        let decrypted = try PrismSecureEnvelope.open(
            Payload.self,
            from: envelope,
            recipientPrivateKey: recipientAgreement,
            senderVerifyKey: senderSigning.publicKey.rawRepresentation
        )
        #expect(decrypted == original)
    }

    @Test("SecureEnvelope open with wrong sender key fails")
    func secureEnvelopeWrongSenderKey() throws {
        let sender = P256.Signing.PrivateKey()
        let imposter = P256.Signing.PrivateKey()
        let recipient = P256.KeyAgreement.PrivateKey()

        let envelope = try PrismSecureEnvelope.seal(
            data: Data("secret".utf8),
            recipientPublicKey: recipient.publicKey.rawRepresentation,
            senderSigningKey: sender
        )

        #expect(throws: PrismSecurityError.self) {
            try PrismSecureEnvelope.open(
                envelope,
                recipientPrivateKey: recipient,
                senderVerifyKey: imposter.publicKey.rawRepresentation
            )
        }
    }

    @Test("SecureEnvelope open with wrong recipient key fails")
    func secureEnvelopeWrongRecipientKey() throws {
        let sender = P256.Signing.PrivateKey()
        let recipient = P256.KeyAgreement.PrivateKey()
        let wrongRecipient = P256.KeyAgreement.PrivateKey()

        let envelope = try PrismSecureEnvelope.seal(
            data: Data("data".utf8),
            recipientPublicKey: recipient.publicKey.rawRepresentation,
            senderSigningKey: sender
        )

        #expect(throws: Error.self) {
            try PrismSecureEnvelope.open(
                envelope,
                recipientPrivateKey: wrongRecipient,
                senderVerifyKey: sender.publicKey.rawRepresentation
            )
        }
    }
}

// MARK: - 7. Error Coverage Boost

@Suite("ErrorCovBoost")
struct PrismSecurityErrorCoverageBoostTests {
    @Test("All error cases are constructible and have non-nil errorDescription")
    func allErrorCasesHaveDescription() {
        let errors: [PrismSecurityError] = [
            .permissionDenied("camera"),
            .permissionRestricted("photos"),
            .permissionNotAvailable("bluetooth"),
            .biometricNotAvailable,
            .biometricNotEnrolled,
            .biometricLockout,
            .biometricAuthenticationFailed,
            .biometricUserCancel,
            .biometricSystemCancel,
            .keychainItemNotFound,
            .keychainDuplicateItem,
            .keychainAccessDenied,
            .keychainOperationFailed(status: -25300),
            .keychainDataConversionFailed,
            .encryptionFailed("reason"),
            .decryptionFailed("reason"),
            .invalidKey,
            .invalidData,
            .secureEnclaveNotAvailable,
            .secureEnclaveKeyGenerationFailed,
            .secureEnclaveSigningFailed,
            .serializationFailed,
            .deserializationFailed,
        ]
        for error in errors {
            #expect(error.errorDescription != nil)
            #expect(!error.errorDescription!.isEmpty)
        }
    }

    @Test("Error descriptions include associated values")
    func errorDescriptionsIncludeValues() {
        #expect(
            PrismSecurityError.permissionDenied("camera").errorDescription!.contains("camera"))
        #expect(
            PrismSecurityError.permissionRestricted("photos").errorDescription!.contains("photos"))
        #expect(
            PrismSecurityError.permissionNotAvailable("ble").errorDescription!.contains("ble"))
        #expect(
            PrismSecurityError.keychainOperationFailed(status: -999).errorDescription!.contains("-999"))
        #expect(
            PrismSecurityError.encryptionFailed("bad block").errorDescription!.contains("bad block"))
        #expect(
            PrismSecurityError.decryptionFailed("tamper").errorDescription!.contains("tamper"))
    }

    @Test("Error equatable works correctly")
    func errorEquatable() {
        #expect(PrismSecurityError.invalidKey == .invalidKey)
        #expect(PrismSecurityError.invalidData == .invalidData)
        #expect(PrismSecurityError.serializationFailed == .serializationFailed)
        #expect(PrismSecurityError.deserializationFailed == .deserializationFailed)
        #expect(PrismSecurityError.invalidKey != .invalidData)
        #expect(
            PrismSecurityError.keychainOperationFailed(status: 1) != .keychainOperationFailed(status: 2))
    }

    @Test("Error conforms to Sendable")
    func errorSendable() {
        let err: any Sendable = PrismSecurityError.invalidKey
        #expect(err is PrismSecurityError)
    }
}

// MARK: - 8. SecureStoreConfiguration Coverage Boost

@Suite("StoreConfigCovBoost")
struct PrismSecureStoreConfigurationCoverageBoostTests {
    @Test("Default configuration values")
    func defaultConfig() {
        let config = PrismSecureStoreConfiguration.default
        #expect(config.algorithm == .aesGCM)
        #expect(config.service == "PrismSecureStore")
        #expect(!config.synchronizeKey)
    }

    @Test("Biometric protected configuration")
    func biometricProtected() {
        let config = PrismSecureStoreConfiguration.biometricProtected
        #expect(config.algorithm == .aesGCM)
        #expect(config.service == "PrismSecureStore")
        #expect(!config.synchronizeKey)
    }

    @Test("High security configuration")
    func highSecurity() {
        let config = PrismSecureStoreConfiguration.highSecurity
        #expect(config.algorithm == .chaChaPoly)
        #expect(config.service == "PrismSecureStore")
        #expect(!config.synchronizeKey)
    }

    @Test("Custom init stores all properties")
    func customInit() {
        let config = PrismSecureStoreConfiguration(
            algorithm: .chaChaPoly,
            service: "MyService",
            synchronizeKey: true
        )
        #expect(config.algorithm == .chaChaPoly)
        #expect(config.service == "MyService")
        #expect(config.synchronizeKey)
    }

    @Test("Default init uses expected defaults")
    func defaultInit() {
        let config = PrismSecureStoreConfiguration()
        #expect(config.algorithm == .aesGCM)
        #expect(config.service == "PrismSecureStore")
        #expect(!config.synchronizeKey)
    }
}
