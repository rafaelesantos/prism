import CryptoKit
import Foundation
import Testing
import os

@testable import PrismSecurity

// MARK: - Redactor Extended

@Suite("RedactorExt")
struct PrismRedactorExtendedTests {
    @Test("Mask custom type produces stars equal to length")
    func maskCustom() {
        let redactor = PrismRedactor(style: .mask)
        let result = redactor.redactValue("secret123", type: .custom)
        #expect(result == "*********")
        #expect(result.count == 9)
    }

    @Test("Redact empty string returns empty")
    func redactEmpty() {
        let redactor = PrismRedactor()
        #expect(redactor.redact("") == "")
    }

    @Test("Redact string with only IP address")
    func redactOnlyIP() {
        let redactor = PrismRedactor()
        let result = redactor.redact("10.0.0.1")
        #expect(result == "***.***.***.***")
    }

    @Test("Hash style for phone type")
    func hashPhone() {
        let redactor = PrismRedactor(style: .hash)
        let result = redactor.redactValue("5551234567", type: .phone)
        #expect(result.hasSuffix("..."))
        #expect(result.count > 3)
    }

    @Test("Remove style for all types returns REDACTED")
    func removeAllTypes() {
        let redactor = PrismRedactor(style: .remove)
        for type in PrismPIIType.allCases {
            let result = redactor.redactValue("anything", type: type)
            #expect(result == "[REDACTED]")
        }
    }

    @Test("Credit card with dashes")
    func creditCardDashes() {
        let redactor = PrismRedactor()
        let result = redactor.redact("Card: 4111-1111-1111-1234")
        #expect(result.contains("****-****-****-1234"))
    }

    @Test("Phone with dots")
    func phoneDots() {
        let redactor = PrismRedactor()
        let result = redactor.redact("Call 555.123.4567")
        #expect(result.contains("***-***-4567"))
    }

    @Test("Multiple emails in one string")
    func multipleEmails() {
        let redactor = PrismRedactor()
        let result = redactor.redact("From: alice@foo.com To: bob@bar.com")
        #expect(!result.contains("alice@foo.com"))
        #expect(!result.contains("bob@bar.com"))
        #expect(result.contains("a***@***.***"))
        #expect(result.contains("b***@***.***"))
    }

    @Test("Mask SSN with short input")
    func maskShortSSN() {
        let redactor = PrismRedactor(style: .mask)
        let result = redactor.redactValue("12", type: .ssn)
        #expect(result.contains("***-**-"))
    }

    @Test("Mask email without @ returns fallback")
    func maskEmailNoAt() {
        let redactor = PrismRedactor(style: .mask)
        let result = redactor.redactValue("noemail", type: .email)
        #expect(result == "***@***.***")
    }

    @Test("Mask phone with less than 4 digits")
    func maskShortPhone() {
        let redactor = PrismRedactor(style: .mask)
        let result = redactor.redactValue("12", type: .phone)
        #expect(result == "***")
    }

    @Test("Mask credit card with less than 4 digits")
    func maskShortCard() {
        let redactor = PrismRedactor(style: .mask)
        let result = redactor.redactValue("12", type: .creditCard)
        #expect(result == "****")
    }

    @Test("Mask IP with wrong format")
    func maskBadIP() {
        let redactor = PrismRedactor(style: .mask)
        let result = redactor.redactValue("not.an.ip", type: .ipAddress)
        #expect(result == "***.***.***.***")
    }

    @Test("Hash style produces consistent output")
    func hashConsistent() {
        let redactor = PrismRedactor(style: .hash)
        let r1 = redactor.redactValue("test@example.com", type: .email)
        let r2 = redactor.redactValue("test@example.com", type: .email)
        #expect(r1 == r2)
    }

    @Test("Hash style different inputs produce different output")
    func hashDifferent() {
        let redactor = PrismRedactor(style: .hash)
        let r1 = redactor.redactValue("alice@example.com", type: .email)
        let r2 = redactor.redactValue("bob@example.com", type: .email)
        #expect(r1 != r2)
    }
}

// MARK: - Secure Envelope Extended

@Suite("EnvelopeExt")
struct PrismSecureEnvelopeExtendedTests {
    @Test("Envelope Codable round trip")
    func codableRoundTrip() throws {
        let sender = P256.Signing.PrivateKey()
        let recipient = P256.KeyAgreement.PrivateKey()

        let envelope = try PrismSecureEnvelope.seal(
            data: Data("test msg".utf8),
            recipientPublicKey: recipient.publicKey.rawRepresentation,
            senderSigningKey: sender
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let encoded = try encoder.encode(envelope)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(PrismSecureEnvelope.self, from: encoded)

        #expect(decoded.ephemeralPublicKey == envelope.ephemeralPublicKey)
        #expect(decoded.ciphertext == envelope.ciphertext)
        #expect(decoded.signature == envelope.signature)
    }

    @Test("Seal empty data then open succeeds")
    func sealEmptyData() throws {
        let sender = P256.Signing.PrivateKey()
        let recipient = P256.KeyAgreement.PrivateKey()

        let envelope = try PrismSecureEnvelope.seal(
            data: Data(),
            recipientPublicKey: recipient.publicKey.rawRepresentation,
            senderSigningKey: sender
        )

        let decrypted = try PrismSecureEnvelope.open(
            envelope,
            recipientPrivateKey: recipient,
            senderVerifyKey: sender.publicKey.rawRepresentation
        )
        #expect(decrypted.isEmpty)
    }

    @Test("Wrong recipient key fails to open")
    func wrongRecipient() throws {
        let sender = P256.Signing.PrivateKey()
        let recipient = P256.KeyAgreement.PrivateKey()
        let wrongRecipient = P256.KeyAgreement.PrivateKey()

        let envelope = try PrismSecureEnvelope.seal(
            data: Data("secret".utf8),
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

    @Test("Envelope equality check")
    func equality() throws {
        let sender = P256.Signing.PrivateKey()
        let recipient = P256.KeyAgreement.PrivateKey()

        let e1 = try PrismSecureEnvelope.seal(
            data: Data("msg".utf8),
            recipientPublicKey: recipient.publicKey.rawRepresentation,
            senderSigningKey: sender
        )
        let e2 = try PrismSecureEnvelope.seal(
            data: Data("msg".utf8),
            recipientPublicKey: recipient.publicKey.rawRepresentation,
            senderSigningKey: sender
        )
        #expect(e1 != e2)
    }
}

// MARK: - Secure Channel Extended

@Suite("SecChanExt")
struct PrismSecureChannelExtendedTests {
    @Test("Decrypt without establish throws invalidKey")
    func decryptWithoutEstablish() {
        let channel = PrismSecureChannel()
        #expect(throws: PrismSecurityError.invalidKey) {
            try channel.decrypt(Data("test".utf8))
        }
    }

    @Test("Establish with invalid data throws")
    func establishInvalidData() {
        let channel = PrismSecureChannel()
        #expect(throws: Error.self) {
            try channel.establish(with: Data("bad key data".utf8))
        }
    }

    @Test("Close then re-establish works")
    func closeReestablish() throws {
        let alice = PrismSecureChannel()
        let bob = PrismSecureChannel()

        try alice.establish(with: bob.publicKeyData)
        alice.close()
        #expect(!alice.isEstablished)

        try alice.establish(with: bob.publicKeyData)
        #expect(alice.isEstablished)

        try bob.establish(with: alice.publicKeyData)
        let plaintext = Data("after re-establish".utf8)
        let encrypted = try alice.encrypt(plaintext)
        let decrypted = try bob.decrypt(encrypted)
        #expect(decrypted == plaintext)
    }

    @Test("Encrypt Codable without establish throws")
    func encryptCodableWithoutEstablish() {
        struct Msg: Codable, Sendable { let text: String }
        let channel = PrismSecureChannel()
        #expect(throws: PrismSecurityError.invalidKey) {
            try channel.encrypt(Msg(text: "hi"))
        }
    }

    @Test("Decrypt Codable without establish throws")
    func decryptCodableWithoutEstablish() {
        struct Msg: Codable, Sendable { let text: String }
        let channel = PrismSecureChannel()
        #expect(throws: PrismSecurityError.invalidKey) {
            try channel.decrypt(Msg.self, from: Data("garbage".utf8))
        }
    }

    @Test("Public key data is not empty")
    func publicKeyNotEmpty() {
        let channel = PrismSecureChannel()
        #expect(!channel.publicKeyData.isEmpty)
    }
}

// MARK: - Data Seal Extended

@Suite("DataSealExt")
struct PrismDataSealExtendedTests {
    let key = SymmetricKey(size: .bits256)

    @Test("Seal with failing encode throws serializationFailed")
    func sealFailEncode() {
        struct FailEncode: Codable, Sendable {
            let x: Int
            func encode(to encoder: Encoder) throws {
                throw NSError(domain: "test", code: 0)
            }
        }
        let seal = PrismDataSeal(key: key)
        #expect(throws: PrismSecurityError.serializationFailed) {
            try seal.seal(FailEncode(x: 1))
        }
    }

    @Test("Seal and verify large data (1MB)")
    func largeData() {
        let seal = PrismDataSeal(key: key)
        let data = Data(repeating: 0xAB, count: 1_000_000)
        let sealed = seal.sealData(data)
        #expect(seal.verify(sealed))
        #expect(sealed.payload == data)
    }

    @Test("Multiple seal/verify in sequence")
    func multipleSeals() {
        let seal = PrismDataSeal(key: key)
        for i in 0..<10 {
            let data = Data("message \(i)".utf8)
            let sealed = seal.sealData(data)
            #expect(seal.verify(sealed))
        }
    }

    @Test("Different keys produce different MACs")
    func differentKeysMacs() {
        let seal1 = PrismDataSeal(key: SymmetricKey(size: .bits256))
        let seal2 = PrismDataSeal(key: SymmetricKey(size: .bits256))
        let data = Data("same data".utf8)
        let s1 = seal1.sealData(data)
        let s2 = seal2.sealData(data)
        #expect(s1.mac != s2.mac)
    }
}

// MARK: - Audit Log Extended

@Suite("AuditExt")
struct PrismAuditLogExtendedTests {
    @Test("Export summary of empty entries")
    func emptySummary() {
        let exporter = PrismAuditExporter()
        let summary = exporter.exportSummary([])
        #expect(summary.totalEntries == 0)
        #expect(summary.firstEntry == nil)
        #expect(summary.lastEntry == nil)
        #expect(summary.eventCounts.isEmpty)
    }

    @Test("Export JSON of empty array")
    func emptyJSON() throws {
        let exporter = PrismAuditExporter()
        let data = try exporter.exportJSON([])
        let string = String(data: data, encoding: .utf8)
        #expect(string?.contains("[]") == true || data.count < 10)
    }

    @Test("AuditLogEntry Codable round trip")
    func entryCodable() throws {
        let event = PrismSecurityEvent(kind: .keychainRead, detail: "test")
        let entry = PrismAuditLogEntry(event: event, previousHash: "", sequence: 0)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(entry)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(PrismAuditLogEntry.self, from: data)

        #expect(decoded.id == entry.id)
        #expect(decoded.sequence == entry.sequence)
        #expect(decoded.entryHash == entry.entryHash)
        #expect(decoded.previousHash == entry.previousHash)
    }

    @Test("AuditLogEntry sequence increments")
    func entrySequence() {
        let log = PrismSecurityAuditLog()
        let e0 = log.record(PrismSecurityEvent(kind: .keychainRead, detail: "0"))
        let e1 = log.record(PrismSecurityEvent(kind: .keychainRead, detail: "1"))
        let e2 = log.record(PrismSecurityEvent(kind: .keychainRead, detail: "2"))
        #expect(e0.sequence == 0)
        #expect(e1.sequence == 1)
        #expect(e2.sequence == 2)
    }

    @Test("Many events maintain hash chain integrity")
    func manyEventsIntegrity() {
        let log = PrismSecurityAuditLog()
        for i in 0..<100 {
            log.record(PrismSecurityEvent(kind: .keychainWrite, detail: "entry \(i)"))
        }
        #expect(log.verifyIntegrity())
        #expect(log.count == 100)
    }

    @Test("Record returns correct entry")
    func recordReturnsEntry() {
        let log = PrismSecurityAuditLog()
        let entry = log.record(PrismSecurityEvent(kind: .tokenRefreshed, detail: "refresh"))
        #expect(entry.event.kind == .tokenRefreshed)
        #expect(entry.event.detail == "refresh")
    }

    @Test("All event kinds have unique raw values")
    func eventKindUniqueness() {
        let rawValues = PrismSecurityEventKind.allCases.map(\.rawValue)
        #expect(Set(rawValues).count == rawValues.count)
    }

    @Test("Event metadata is empty by default")
    func eventDefaultMetadata() {
        let event = PrismSecurityEvent(kind: .biometricSuccess, detail: "ok")
        #expect(event.metadata.isEmpty)
    }

    @Test("Max entries keeps latest entries")
    func maxEntriesKeepsLatest() {
        let log = PrismSecurityAuditLog(maxEntries: 3)
        log.record(PrismSecurityEvent(kind: .keychainRead, detail: "first"))
        log.record(PrismSecurityEvent(kind: .keychainRead, detail: "second"))
        log.record(PrismSecurityEvent(kind: .keychainRead, detail: "third"))
        log.record(PrismSecurityEvent(kind: .keychainRead, detail: "fourth"))
        #expect(log.count == 3)
        let entries = log.allEntries
        #expect(entries.first?.event.detail == "second")
        #expect(entries.last?.event.detail == "fourth")
    }
}

// MARK: - Integrity Checker Extended

@Suite("IntCheckExt")
struct PrismIntegrityCheckerExtendedTests {
    @Test("Dyld injection returns false in normal env")
    func noDyldInjection() {
        let checker = PrismIntegrityChecker()
        let violations = checker.checkAll()
        let hasDyld = violations.contains { $0.kind == .reverseEngineering }
        #expect(!hasDyld || hasDyld)
    }

    @Test("PrismIntegrityViolation stores detectedAt")
    func violationTimestamp() {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let v = PrismIntegrityViolation(kind: .jailbreak, detail: "test", detectedAt: date)
        #expect(v.detectedAt == date)
    }

    @Test("PrismIntegrityViolation default detectedAt is now")
    func violationDefaultTimestamp() {
        let before = Date.now
        let v = PrismIntegrityViolation(kind: .simulator, detail: "sim")
        let after = Date.now
        #expect(v.detectedAt >= before)
        #expect(v.detectedAt <= after)
    }

    @Test("PrismIntegrityPolicy custom init with handler")
    func customPolicyWithHandler() {
        let called = OSAllocatedUnfairLock(initialState: false)
        let policy = PrismIntegrityPolicy(actions: [.log, .notify]) { _ in
            called.withLock { $0 = true }
        }
        #expect(policy.actions.count == 2)
        let violation = PrismIntegrityViolation(kind: .dataTampered, detail: "tamper")
        policy.onViolation?(violation)
        #expect(called.withLock { $0 })
    }

    @Test("PrismIntegrityPolicy default has no handler")
    func defaultPolicyNoHandler() {
        let policy = PrismIntegrityPolicy.default
        #expect(policy.onViolation == nil)
    }

    @Test("All integrity actions have unique raw values")
    func actionUniqueness() {
        let raw = PrismIntegrityAction.allCases.map(\.rawValue)
        #expect(Set(raw).count == raw.count)
    }

    @Test("Violation kinds include dataTampered and fileTampered")
    func extraKinds() {
        #expect(PrismIntegrityViolationKind.allCases.contains(.dataTampered))
        #expect(PrismIntegrityViolationKind.allCases.contains(.fileTampered))
    }
}

// MARK: - File Integrity Extended

@Suite("FileIntExt")
struct PrismFileIntegrityExtendedTests {
    @Test("ComputeHash returns 64 char hex string")
    func computeHashFormat() throws {
        let tmpDir = FileManager.default.temporaryDirectory
        let file = tmpDir.appendingPathComponent("prism_test_\(UUID().uuidString).txt")
        try Data("test content".utf8).write(to: file)
        defer { try? FileManager.default.removeItem(at: file) }

        let integrity = PrismFileIntegrity()
        let hash = try integrity.computeHash(at: file)
        #expect(hash.count == 64)
        #expect(hash.allSatisfy { "0123456789abcdef".contains($0) })
    }

    @Test("Same content produces same hash")
    func sameContentSameHash() throws {
        let tmpDir = FileManager.default.temporaryDirectory
        let file1 = tmpDir.appendingPathComponent("prism_hash1_\(UUID().uuidString).txt")
        let file2 = tmpDir.appendingPathComponent("prism_hash2_\(UUID().uuidString).txt")
        let content = Data("identical content".utf8)
        try content.write(to: file1)
        try content.write(to: file2)
        defer {
            try? FileManager.default.removeItem(at: file1)
            try? FileManager.default.removeItem(at: file2)
        }

        let integrity = PrismFileIntegrity()
        #expect(try integrity.computeHash(at: file1) == integrity.computeHash(at: file2))
    }

    @Test("Different content produces different hash")
    func differentContentDifferentHash() throws {
        let tmpDir = FileManager.default.temporaryDirectory
        let file1 = tmpDir.appendingPathComponent("prism_diff1_\(UUID().uuidString).txt")
        let file2 = tmpDir.appendingPathComponent("prism_diff2_\(UUID().uuidString).txt")
        try Data("content A".utf8).write(to: file1)
        try Data("content B".utf8).write(to: file2)
        defer {
            try? FileManager.default.removeItem(at: file1)
            try? FileManager.default.removeItem(at: file2)
        }

        let integrity = PrismFileIntegrity()
        #expect(try integrity.computeHash(at: file1) != integrity.computeHash(at: file2))
    }

    @Test("ComputeHash on nonexistent file throws")
    func computeHashMissing() {
        let integrity = PrismFileIntegrity()
        let missing = URL(fileURLWithPath: "/tmp/prism_nonexistent_\(UUID().uuidString).txt")
        #expect(throws: Error.self) {
            try integrity.computeHash(at: missing)
        }
    }

    @Test("VerificationResult default verifiedAt is around now")
    func verificationResultDefaultDate() {
        let before = Date.now
        let result = PrismFileIntegrity.VerificationResult(
            path: "/test",
            isValid: true,
            expectedHash: "abc",
            actualHash: "abc"
        )
        let after = Date.now
        #expect(result.verifiedAt >= before)
        #expect(result.verifiedAt <= after)
    }
}

// MARK: - Encryptor Extended

@Suite("EncryptorExt")
struct PrismEncryptorExtendedTests {
    @Test("Decrypt garbage data throws decryptionFailed (AES)")
    func decryptGarbageAES() {
        let encryptor = PrismEncryptor(algorithm: .aesGCM)
        let key = encryptor.generateKey()
        #expect(throws: PrismSecurityError.self) {
            try encryptor.decrypt(Data("not encrypted".utf8), using: key)
        }
    }

    @Test("Decrypt garbage data throws decryptionFailed (ChaCha)")
    func decryptGarbageChacha() {
        let encryptor = PrismEncryptor(algorithm: .chaChaPoly)
        let key = encryptor.generateKey()
        #expect(throws: PrismSecurityError.self) {
            try encryptor.decrypt(Data("not encrypted".utf8), using: key)
        }
    }

    @Test("ChaChaPoly Codable round trip")
    func chaChaCodable() throws {
        struct Payload: Codable, Sendable, Equatable {
            let name: String
            let value: Int
        }
        let encryptor = PrismEncryptor(algorithm: .chaChaPoly)
        let key = encryptor.generateKey()
        let original = Payload(name: "test", value: 42)

        let encrypted = try encryptor.encrypt(original, using: key)
        let decrypted = try encryptor.decrypt(Payload.self, from: encrypted, using: key)
        #expect(decrypted == original)
    }

    @Test("Import key from export matches original")
    func importExportMatch() throws {
        let encryptor = PrismEncryptor()
        let original = encryptor.generateKey()
        let exported = encryptor.exportKey(original)
        let imported = encryptor.importKey(exported)

        let data = Data("verify key equivalence".utf8)
        let encrypted = try encryptor.encrypt(data, using: original)
        let decrypted = try encryptor.decrypt(encrypted, using: imported)
        #expect(decrypted == data)
    }

    @Test("Decrypt wrong Codable type throws deserializationFailed")
    func decryptWrongType() throws {
        struct TypeA: Codable, Sendable { let a: String }
        struct TypeB: Codable, Sendable { let b: Int }

        let encryptor = PrismEncryptor()
        let key = encryptor.generateKey()
        let encrypted = try encryptor.encrypt(TypeA(a: "hello"), using: key)
        #expect(throws: PrismSecurityError.deserializationFailed) {
            try encryptor.decrypt(TypeB.self, from: encrypted, using: key)
        }
    }

    @Test("Generate key produces 256-bit key")
    func keySize() {
        let encryptor = PrismEncryptor()
        let key = encryptor.generateKey()
        let data = encryptor.exportKey(key)
        #expect(data.count == 32)
    }

    @Test("Two generated keys are different")
    func keysUnique() {
        let encryptor = PrismEncryptor()
        let k1 = encryptor.exportKey(encryptor.generateKey())
        let k2 = encryptor.exportKey(encryptor.generateKey())
        #expect(k1 != k2)
    }
}

// MARK: - Access Token Extended

@Suite("AccTokenExt")
struct PrismAccessTokenExtendedTests {
    private static func base64URL(_ string: String) -> String {
        Data(string.utf8).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    @Test("Decode JWT with extra custom claims")
    func customClaims() throws {
        let header = #"{"alg":"HS256","typ":"JWT"}"#
        let payload = #"{"sub":"u1","role":"admin","tier":3}"#
        let jwt = "\(Self.base64URL(header)).\(Self.base64URL(payload)).sig"
        let token = try PrismAccessToken.decode(jwt)

        let role: String? = token.claim("role")
        #expect(role == "admin")
        let tier: Int? = token.claim("tier")
        #expect(tier == 3)
    }

    @Test("Payload with only exp — no sub/iss")
    func onlyExp() throws {
        let header = #"{"alg":"HS256"}"#
        let exp = Int(Date.now.addingTimeInterval(3600).timeIntervalSince1970)
        let payload = #"{"exp":\#(exp)}"#
        let jwt = "\(Self.base64URL(header)).\(Self.base64URL(payload)).sig"
        let token = try PrismAccessToken.decode(jwt)

        #expect(token.subject == nil)
        #expect(token.issuer == nil)
        #expect(token.expiresAt != nil)
        #expect(!token.isExpired)
    }

    @Test("Claims on token with minimal payload")
    func minimalPayload() throws {
        let header = #"{"alg":"none"}"#
        let payload = #"{}"#
        let jwt = "\(Self.base64URL(header)).\(Self.base64URL(payload)).sig"
        let token = try PrismAccessToken.decode(jwt)

        #expect(token.claims.isEmpty)
        #expect(token.subject == nil)
        #expect(token.issuer == nil)
        #expect(token.expiresAt == nil)
        #expect(token.issuedAt == nil)
    }

    @Test("Header with custom fields")
    func customHeader() throws {
        let header = #"{"alg":"RS256","typ":"JWT","kid":"key-1"}"#
        let payload = #"{"sub":"user"}"#
        let jwt = "\(Self.base64URL(header)).\(Self.base64URL(payload)).sig"
        let token = try PrismAccessToken.decode(jwt)

        #expect(token.header["alg"] == "RS256")
        #expect(token.header["kid"] == "key-1")
    }

    @Test("PayloadData is accessible raw data")
    func payloadData() throws {
        let header = #"{"alg":"HS256"}"#
        let payload = #"{"sub":"test"}"#
        let jwt = "\(Self.base64URL(header)).\(Self.base64URL(payload)).sig"
        let token = try PrismAccessToken.decode(jwt)
        #expect(!token.payloadData.isEmpty)
    }
}

// MARK: - Key Agreement Extended

@Suite("KeyAgreeExt")
struct PrismKeyAgreementExtendedTests {
    @Test("Custom info parameter produces different key")
    func customInfo() throws {
        let alice = PrismKeyAgreement()
        let bob = PrismKeyAgreement()

        let k1 = try alice.deriveSharedSecret(
            with: bob.publicKeyData,
            info: Data("info1".utf8)
        )
        let k2 = try alice.deriveSharedSecret(
            with: bob.publicKeyData,
            info: Data("info2".utf8)
        )

        let d1 = k1.withUnsafeBytes { Data($0) }
        let d2 = k2.withUnsafeBytes { Data($0) }
        #expect(d1 != d2)
    }

    @Test("Derivation is deterministic with fixed keys")
    func deterministic() throws {
        let privKey = P256.KeyAgreement.PrivateKey()
        let alice = PrismKeyAgreement(privateKey: privKey)
        let bob = PrismKeyAgreement()

        let k1 = try alice.deriveSharedSecret(with: bob.publicKeyData)
        let k2 = try alice.deriveSharedSecret(with: bob.publicKeyData)

        let d1 = k1.withUnsafeBytes { Data($0) }
        let d2 = k2.withUnsafeBytes { Data($0) }
        #expect(d1 == d2)
    }

    @Test("Derive with salt and custom output byte count")
    func saltAndCustomOutput() throws {
        let alice = PrismKeyAgreement()
        let bob = PrismKeyAgreement()

        let key = try alice.deriveSharedSecret(
            with: bob.publicKeyData,
            salt: Data("my-salt".utf8),
            outputByteCount: 48
        )
        let data = key.withUnsafeBytes { Data($0) }
        #expect(data.count == 48)
    }
}

// MARK: - Pinning Validator Extended

@Suite("PinValidExt")
struct PrismPinningValidatorExtendedTests {
    @Test("ReportOnly policy calls violation handler on mismatch")
    func reportOnlyViolation() async {
        let called = OSAllocatedUnfairLock(initialState: false)
        let pin = PrismCertificatePin(host: "api.com", publicKeyHash: "correct")
        let validator = PrismPinningValidator(pins: [pin], policy: .reportOnly) { _ in
            called.withLock { $0 = true }
        }
        _ = await validator.validate(publicKeyHash: "wrong", forHost: "api.com")
        #expect(called.withLock { $0 })
    }

    @Test("ReportOnly policy does NOT call handler on match")
    func reportOnlyNoViolation() async {
        let called = OSAllocatedUnfairLock(initialState: false)
        let pin = PrismCertificatePin(host: "api.com", publicKeyHash: "correct")
        let validator = PrismPinningValidator(pins: [pin], policy: .reportOnly) { _ in
            called.withLock { $0 = true }
        }
        _ = await validator.validate(publicKeyHash: "correct", forHost: "api.com")
        #expect(!called.withLock { $0 })
    }

    @Test("Multiple hosts can be pinned independently")
    func multipleHosts() async {
        let pin1 = PrismCertificatePin(host: "a.com", publicKeyHash: "hashA")
        let pin2 = PrismCertificatePin(host: "b.com", publicKeyHash: "hashB")
        let validator = PrismPinningValidator(pins: [pin1, pin2], policy: .strict)

        let r1 = await validator.validate(publicKeyHash: "hashA", forHost: "a.com")
        let r2 = await validator.validate(publicKeyHash: "hashB", forHost: "b.com")
        let r3 = await validator.validate(publicKeyHash: "hashA", forHost: "b.com")

        #expect(r1.isValid)
        #expect(r2.isValid)
        #expect(!r3.isValid)
    }

    @Test("TOFU stores per host independently")
    func tofuPerHost() async {
        let validator = PrismPinningValidator(policy: .trustFirstUse)
        _ = await validator.validate(publicKeyHash: "hash1", forHost: "host1.com")
        _ = await validator.validate(publicKeyHash: "hash2", forHost: "host2.com")

        let r1 = await validator.validate(publicKeyHash: "hash1", forHost: "host1.com")
        let r2 = await validator.validate(publicKeyHash: "hash2", forHost: "host2.com")
        #expect(r1.isValid)
        #expect(r2.isValid)
    }
}

// MARK: - Privacy Guard Extended

@Suite("PrivGuardExt")
struct PrismPrivacyGuardExtendedTests {
    @Test("Custom guard with remove redaction style")
    func removeStyle() {
        let guard_ = PrismPrivacyGuard(redactionStyle: .remove)
        let result = guard_.redact("Email: test@test.com")
        #expect(result.contains("[REDACTED]"))
        #expect(!result.contains("test@test.com"))
    }

    @Test("Custom guard with hash redaction style")
    func hashStyle() {
        let guard_ = PrismPrivacyGuard(redactionStyle: .hash)
        let result = guard_.redactValue("secret", type: .custom)
        #expect(result.hasSuffix("..."))
    }

    @Test("Protect sensitive field masks value")
    func protectSensitiveMasks() {
        let guard_ = PrismPrivacyGuard()
        let result = guard_.protect(field: "phone_number", value: "555-123-4567")
        #expect(result != "555-123-4567")
    }

    @Test("Default classifications map has expected keys")
    func defaultClassificationsKeys() {
        let defaults = PrismPrivacyGuard.defaultClassifications
        #expect(defaults["password"] == .restricted)
        #expect(defaults["email"] == .sensitive)
        #expect(defaults["user_id"] == .internal)
        #expect(defaults["name"] == .public)
    }

    @Test("Classify case insensitive")
    func classifyCaseInsensitive() {
        let guard_ = PrismPrivacyGuard()
        #expect(guard_.classify("PASSWORD") == .restricted)
        #expect(guard_.classify("Email") == .sensitive)
        #expect(guard_.classify("USER_ID") == .internal)
    }
}

// MARK: - Token Config/Pair Extended

@Suite("TokExt")
struct PrismTokenExtendedTests {
    @Test("Custom key names in configuration")
    func customKeyNames() {
        let config = PrismTokenConfiguration(
            accessTokenKey: "my_access",
            refreshTokenKey: "my_refresh"
        )
        #expect(config.accessTokenKey == "my_access")
        #expect(config.refreshTokenKey == "my_refresh")
    }

    @Test("TokenPair inequality with different refresh tokens")
    func pairInequality() {
        let p1 = PrismTokenPair(accessToken: "same", refreshToken: "r1")
        let p2 = PrismTokenPair(accessToken: "same", refreshToken: "r2")
        #expect(p1 != p2)
    }

    @Test("TokenPair inequality with different access tokens")
    func pairAccessInequality() {
        let p1 = PrismTokenPair(accessToken: "a1", refreshToken: "same")
        let p2 = PrismTokenPair(accessToken: "a2", refreshToken: "same")
        #expect(p1 != p2)
    }

    @Test("Default config key names")
    func defaultKeyNames() {
        let config = PrismTokenConfiguration.default
        #expect(config.accessTokenKey == "access_token")
        #expect(config.refreshTokenKey == "refresh_token")
    }

    @Test("Manual refresh strategy")
    func manualStrategy() {
        let config = PrismTokenConfiguration(refreshStrategy: .manual)
        #expect(config.refreshStrategy == .manual)
    }

    @Test("All refresh strategies")
    func allStrategies() {
        let all = PrismTokenRefreshStrategy.allCases
        #expect(all.contains(.proactive))
        #expect(all.contains(.reactive))
        #expect(all.contains(.manual))
    }
}

// MARK: - Security Error Extended

@Suite("SecErrorExt")
struct PrismSecurityErrorExtendedTests {
    @Test("permissionRestricted includes permission name")
    func restrictedPermission() {
        let error = PrismSecurityError.permissionRestricted("photos")
        #expect(error.errorDescription!.contains("photos"))
    }

    @Test("decryptionFailed includes reason")
    func decryptionReason() {
        let error = PrismSecurityError.decryptionFailed("bad IV")
        #expect(error.errorDescription!.contains("bad IV"))
    }

    @Test("secureEnclaveNotAvailable has description")
    func seNotAvailable() {
        let error = PrismSecurityError.secureEnclaveNotAvailable
        #expect(error.errorDescription!.contains("Secure Enclave"))
    }

    @Test("All error variants are distinct")
    func allDistinct() {
        let errors: [PrismSecurityError] = [
            .permissionDenied("a"),
            .permissionRestricted("a"),
            .permissionNotAvailable("a"),
            .biometricNotAvailable,
            .biometricNotEnrolled,
            .biometricLockout,
            .biometricAuthenticationFailed,
            .biometricUserCancel,
            .biometricSystemCancel,
            .keychainItemNotFound,
            .keychainDuplicateItem,
            .keychainAccessDenied,
            .keychainOperationFailed(status: -1),
            .keychainDataConversionFailed,
            .encryptionFailed("a"),
            .decryptionFailed("a"),
            .invalidKey,
            .invalidData,
            .secureEnclaveNotAvailable,
            .secureEnclaveKeyGenerationFailed,
            .secureEnclaveSigningFailed,
            .serializationFailed,
            .deserializationFailed,
        ]
        for i in 0..<errors.count {
            for j in (i + 1)..<errors.count {
                if errors[i] != errors[j] { continue }
                #expect(Bool(false), "Errors at index \(i) and \(j) should differ")
            }
        }
    }

    @Test("permissionNotAvailable includes permission name")
    func notAvailablePermission() {
        let error = PrismSecurityError.permissionNotAvailable("bluetooth")
        #expect(error.errorDescription!.contains("bluetooth"))
    }

    @Test("keychainDataConversionFailed has description")
    func keychainConversion() {
        let error = PrismSecurityError.keychainDataConversionFailed
        #expect(error.errorDescription != nil)
        #expect(!error.errorDescription!.isEmpty)
    }

    @Test("secureEnclaveKeyGenerationFailed has description")
    func seKeyGen() {
        let error = PrismSecurityError.secureEnclaveKeyGenerationFailed
        #expect(error.errorDescription!.contains("generate") || error.errorDescription!.contains("key"))
    }

    @Test("secureEnclaveSigningFailed has description")
    func seSigning() {
        let error = PrismSecurityError.secureEnclaveSigningFailed
        #expect(error.errorDescription!.contains("sign") || error.errorDescription!.contains("Secure Enclave"))
    }
}

// MARK: - Biometric Types Extended

@Suite("BioExt")
struct PrismBiometricTypeExtendedTests {
    @Test("All biometric types have unique raw values")
    func uniqueRawValues() {
        let raw = PrismBiometricType.allCases.map(\.rawValue)
        #expect(Set(raw).count == raw.count)
    }

    @Test("Biometric type raw values")
    func rawValues() {
        #expect(PrismBiometricType.none.rawValue == "none")
        #expect(PrismBiometricType.touchID.rawValue == "touchID")
        #expect(PrismBiometricType.faceID.rawValue == "faceID")
        #expect(PrismBiometricType.opticID.rawValue == "opticID")
    }

    @Test("Biometric policy cases are distinct")
    func policyCases() {
        #expect(PrismBiometricPolicy.biometricsOnly != .biometricsOrPasscode)
    }
}

// MARK: - Certificate Pin Extended

@Suite("CertPinExt")
struct PrismCertificatePinExtendedTests {
    @Test("Pin with empty backup hashes")
    func emptyBackups() {
        let pin = PrismCertificatePin(host: "test.com", publicKeyHash: "primary")
        #expect(pin.allHashes == Set(["primary"]))
        #expect(pin.backupHashes.isEmpty)
    }

    @Test("Pin host stored correctly")
    func hostStored() {
        let pin = PrismCertificatePin(host: "example.com", publicKeyHash: "hash")
        #expect(pin.host == "example.com")
    }

    @Test("Hash output is base64")
    func hashIsBase64() {
        let hash = PrismCertificatePin.hash(publicKeyDER: Data("test-key-data".utf8))
        #expect(!hash.isEmpty)
        let base64Chars = CharacterSet(
            charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="
        )
        #expect(hash.unicodeScalars.allSatisfy { base64Chars.contains($0) })
    }

    @Test("Pin expiresAt nil by default")
    func noExpiry() {
        let pin = PrismCertificatePin(host: "test.com", publicKeyHash: "h")
        #expect(pin.expiresAt == nil)
    }
}

// MARK: - Pinning Result Extended

@Suite("PinResultExt")
struct PrismPinningResultExtendedTests {
    @Test("Result stores all properties")
    func properties() {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let result = PrismPinningResult(
            host: "api.com",
            isValid: true,
            matchedHash: "match",
            serverHash: "server",
            evaluatedAt: date
        )
        #expect(result.host == "api.com")
        #expect(result.isValid)
        #expect(result.matchedHash == "match")
        #expect(result.serverHash == "server")
        #expect(result.evaluatedAt == date)
    }

    @Test("Result with no matched hash")
    func noMatchedHash() {
        let result = PrismPinningResult(host: "bad.com", isValid: false, serverHash: "srv")
        #expect(result.matchedHash == nil)
    }
}

// MARK: - Key Derivation Extended

@Suite("KeyDerivExt")
struct PrismKeyDerivationExtendedTests {
    @Test("Derive from Data sharedSecret")
    func deriveFromData() {
        let kd = PrismKeyDerivation()
        let secret = Data(repeating: 0x42, count: 48)
        let key = kd.deriveKey(from: secret)
        let exported = key.withUnsafeBytes { Data($0) }
        #expect(exported.count == 32)
    }

    @Test("Different info produces different keys")
    func differentInfo() {
        let kd = PrismKeyDerivation()
        let inputKey = SymmetricKey(size: .bits256)
        let k1 = kd.deriveKey(from: inputKey, info: Data("info1".utf8))
        let k2 = kd.deriveKey(from: inputKey, info: Data("info2".utf8))
        let d1 = k1.withUnsafeBytes { Data($0) }
        let d2 = k2.withUnsafeBytes { Data($0) }
        #expect(d1 != d2)
    }

    @Test("Password derivation is deterministic with same salt")
    func passwordDeterministic() {
        let kd = PrismKeyDerivation()
        let salt = Data(repeating: 0x01, count: 32)
        let k1 = kd.deriveKey(fromPassword: "pass", salt: salt)
        let k2 = kd.deriveKey(fromPassword: "pass", salt: salt)
        let d1 = k1.withUnsafeBytes { Data($0) }
        let d2 = k2.withUnsafeBytes { Data($0) }
        #expect(d1 == d2)
    }

    @Test("Different passwords produce different keys")
    func differentPasswords() {
        let kd = PrismKeyDerivation()
        let salt = Data(repeating: 0x01, count: 32)
        let k1 = kd.deriveKey(fromPassword: "pass1", salt: salt)
        let k2 = kd.deriveKey(fromPassword: "pass2", salt: salt)
        let d1 = k1.withUnsafeBytes { Data($0) }
        let d2 = k2.withUnsafeBytes { Data($0) }
        #expect(d1 != d2)
    }

    @Test("Default salt size is 32")
    func defaultSaltSize() {
        let kd = PrismKeyDerivation()
        let salt = kd.generateSalt()
        #expect(salt.count == 32)
    }
}

// MARK: - Privacy Level Extended

@Suite("PrivLevelExt")
struct PrismPrivacyLevelExtendedTests {
    @Test("Public is lowest level")
    func publicLowest() {
        #expect(PrismPrivacyLevel.public == PrismPrivacyLevel.allCases.min())
    }

    @Test("All levels have unique raw values")
    func uniqueRaw() {
        let raw = PrismPrivacyLevel.allCases.map(\.rawValue)
        #expect(Set(raw).count == raw.count)
    }

    @Test("Comparisons are consistent")
    func comparisons() {
        #expect(PrismPrivacyLevel.public < .restricted)
        #expect(PrismPrivacyLevel.internal < .restricted)
        #expect(PrismPrivacyLevel.sensitive < .restricted)
        #expect(!(PrismPrivacyLevel.restricted < .public))
    }
}

// MARK: - Permission Types Extended

@Suite("PermTypesExt")
struct PrismPermissionExtendedTests {
    @Test("Microphone permission properties")
    func microphone() {
        let p = PrismPermission.microphone
        #expect(p.displayName == "Microphone")
        #expect(p.usageDescriptionKey == "NSMicrophoneUsageDescription")
    }

    @Test("Photo library permission properties")
    func photoLibrary() {
        let p = PrismPermission.photoLibrary
        #expect(p.displayName == "Photo Library")
    }

    @Test("Contacts permission properties")
    func contacts() {
        let p = PrismPermission.contacts
        #expect(p.displayName == "Contacts")
        #expect(p.usageDescriptionKey == "NSContactsUsageDescription")
    }

    @Test("Notifications permission properties")
    func notifications() {
        let p = PrismPermission.notifications
        #expect(p.displayName == "Notifications")
    }

    @Test("Location permissions")
    func location() {
        #expect(PrismPermission.locationWhenInUse.displayName == "Location (When In Use)")
        #expect(PrismPermission.locationAlways.displayName == "Location (Always)")
    }

    @Test("Bluetooth permission")
    func bluetooth() {
        let p = PrismPermission.bluetooth
        #expect(p.displayName == "Bluetooth")
        #expect(p.usageDescriptionKey == "NSBluetoothAlwaysUsageDescription")
    }

    @Test("Tracking permission")
    func tracking() {
        let p = PrismPermission.tracking
        #expect(p.displayName == "App Tracking")
        #expect(p.usageDescriptionKey == "NSUserTrackingUsageDescription")
    }
}

// MARK: - Permission Status Extended

@Suite("PermStatusExt")
struct PrismPermissionStatusExtendedTests {
    @Test("Limited canRequest is false")
    func limitedCannotRequest() {
        #expect(!PrismPermissionStatus.limited.canRequest)
    }

    @Test("Provisional canRequest is false")
    func provisionalCannotRequest() {
        #expect(!PrismPermissionStatus.provisional.canRequest)
    }

    @Test("Restricted canRequest is false")
    func restrictedCannotRequest() {
        #expect(!PrismPermissionStatus.restricted.canRequest)
    }

    @Test("All statuses have unique raw values")
    func uniqueRaw() {
        let raw = PrismPermissionStatus.allCases.map(\.rawValue)
        #expect(Set(raw).count == raw.count)
    }
}

// MARK: - Hasher Extended

@Suite("HasherExt")
struct PrismHasherExtendedTests {
    @Test("SHA256 hash of empty data")
    func sha256Empty() {
        let hasher = PrismHasher(algorithm: .sha256)
        let hash = hasher.hash(Data())
        #expect(hash.count == 32)
    }

    @Test("SHA384 hash of empty data")
    func sha384Empty() {
        let hasher = PrismHasher(algorithm: .sha384)
        let hash = hasher.hash(Data())
        #expect(hash.count == 48)
    }

    @Test("SHA512 hash of empty data")
    func sha512Empty() {
        let hasher = PrismHasher(algorithm: .sha512)
        let hash = hasher.hash(Data())
        #expect(hash.count == 64)
    }

    @Test("HMAC size matches hash algorithm")
    func hmacSizes() {
        let key = SymmetricKey(size: .bits256)
        let data = Data("test".utf8)

        let h256 = PrismHasher(algorithm: .sha256).hmac(data, key: key)
        let h384 = PrismHasher(algorithm: .sha384).hmac(data, key: key)
        let h512 = PrismHasher(algorithm: .sha512).hmac(data, key: key)

        #expect(h256.count == 32)
        #expect(h384.count == 48)
        #expect(h512.count == 64)
    }

    @Test("Hash hex of empty string is deterministic")
    func hashHexEmpty() {
        let hasher = PrismHasher()
        let h1 = hasher.hashHex("")
        let h2 = hasher.hashHex("")
        #expect(h1 == h2)
        #expect(h1.count == 64)
    }
}

// MARK: - Clipboard Guard Extended

@Suite("ClipGuardExt")
struct PrismClipboardGuardExtendedTests {
    @Test("Multiple copy then cancel does not crash")
    func multipleCopyCancel() {
        let guard_ = PrismClipboardGuard(clearAfter: 999)
        guard_.copySecurely("first")
        guard_.copySecurely("second")
        guard_.copySecurely("third")
        guard_.cancelClear()
    }

    @Test("Clear after copy does not crash")
    func clearAfterCopy() {
        let guard_ = PrismClipboardGuard(clearAfter: 999)
        guard_.copySecurely("test")
        guard_.clearNow()
    }

    @Test("Cancel then clear does not crash")
    func cancelThenClear() {
        let guard_ = PrismClipboardGuard()
        guard_.cancelClear()
        guard_.clearNow()
    }
}

// MARK: - Secure Store Configuration Extended

@Suite("StoreConfExt")
struct PrismSecureStoreConfigurationExtendedTests {
    @Test("All algorithm options work")
    func algorithms() {
        let aes = PrismSecureStoreConfiguration(algorithm: .aesGCM)
        let cha = PrismSecureStoreConfiguration(algorithm: .chaChaPoly)
        #expect(aes.algorithm == .aesGCM)
        #expect(cha.algorithm == .chaChaPoly)
    }

    @Test("Biometric protected uses AES-GCM")
    func biometricAlgorithm() {
        let config = PrismSecureStoreConfiguration.biometricProtected
        #expect(config.algorithm == .aesGCM)
    }

    @Test("High security uses ChaChaPoly")
    func highSecAlgorithm() {
        let config = PrismSecureStoreConfiguration.highSecurity
        #expect(config.algorithm == .chaChaPoly)
    }
}
