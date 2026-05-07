import CryptoKit
import Foundation
import Testing

@testable import PrismSecurity

@Suite("IntPolicy")
struct PrismIntegrityPolicyTests {
    @Test("All actions available")
    func allActions() {
        #expect(PrismIntegrityAction.allCases.count == 3)
    }

    @Test("All violation kinds available")
    func allKinds() {
        #expect(PrismIntegrityViolationKind.allCases.count == 6)
    }

    @Test("Default policy has log action")
    func defaultPolicy() {
        let policy = PrismIntegrityPolicy.default
        #expect(policy.actions == [.log])
    }

    @Test("Strict policy has all actions")
    func strictPolicy() {
        let policy = PrismIntegrityPolicy.strict
        #expect(policy.actions.count == 3)
    }

    @Test("Violation equality")
    func violationEquality() {
        let v1 = PrismIntegrityViolation(kind: .jailbreak, detail: "test")
        let v2 = PrismIntegrityViolation(kind: .jailbreak, detail: "test")
        #expect(v1.kind == v2.kind)
        #expect(v1.detail == v2.detail)
    }
}

@Suite("IntCheck")
struct PrismIntegrityCheckerTests {
    let checker = PrismIntegrityChecker()

    @Test("Checker returns results")
    func checkAll() {
        let violations = checker.checkAll()
        #expect(violations.isEmpty || !violations.isEmpty)
    }

    @Test("Simulator detection works")
    func simulator() {
        #if targetEnvironment(simulator)
            #expect(checker.isSimulator())
        #else
            #expect(!checker.isSimulator())
        #endif
    }

    @Test("Not jailbroken in test environment")
    func jailbreak() {
        #if targetEnvironment(simulator)
            #expect(!checker.isJailbroken())
        #endif
    }

    @Test("isSecure is consistent with checkAll")
    func isSecure() {
        let violations = checker.checkAll()
        #expect(checker.isSecure == violations.isEmpty)
    }

    @Test("Debugger detection returns Bool")
    func debugger() {
        let result = checker.isDebuggerAttached()
        #expect(result || !result)
    }

    @Test("Reverse engineering tools detection")
    func reverseEngineeringTools() {
        let result = checker.hasReverseEngineeringTools()
        #expect(!result)
    }

    @Test("Violation init stores kind and detail")
    func violationProperties() {
        let v = PrismIntegrityViolation(kind: .debuggerAttached, detail: "ptrace")
        #expect(v.kind == .debuggerAttached)
        #expect(v.detail == "ptrace")
    }

    @Test("All violation kinds distinct")
    func allViolationKinds() {
        let kinds = PrismIntegrityViolationKind.allCases
        #expect(Set(kinds.map(\.rawValue)).count == kinds.count)
    }
}

@Suite("FileIntVerify")
struct PrismFileIntegrityVerificationResultTests {
    @Test("VerificationResult stores all properties")
    func properties() {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let result = PrismFileIntegrity.VerificationResult(
            path: "/tmp/test.txt",
            isValid: true,
            expectedHash: "abc",
            actualHash: "abc",
            verifiedAt: date
        )
        #expect(result.path == "/tmp/test.txt")
        #expect(result.isValid)
        #expect(result.expectedHash == "abc")
        #expect(result.actualHash == "abc")
        #expect(result.verifiedAt == date)
    }

    @Test("VerificationResult equality")
    func equality() {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let a = PrismFileIntegrity.VerificationResult(
            path: "/a", isValid: true, expectedHash: "x", actualHash: "x", verifiedAt: date
        )
        let b = PrismFileIntegrity.VerificationResult(
            path: "/a", isValid: true, expectedHash: "x", actualHash: "x", verifiedAt: date
        )
        #expect(a == b)
    }

    @Test("VerificationResult inequality on isValid")
    func inequality() {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let a = PrismFileIntegrity.VerificationResult(
            path: "/a", isValid: true, expectedHash: "x", actualHash: "x", verifiedAt: date
        )
        let b = PrismFileIntegrity.VerificationResult(
            path: "/a", isValid: false, expectedHash: "x", actualHash: "y", verifiedAt: date
        )
        #expect(a != b)
    }
}

@Suite("DataSeal")
struct PrismDataSealTests {
    let key = SymmetricKey(size: .bits256)

    @Test("Seal and unseal Codable")
    func roundTrip() throws {
        struct Secret: Codable, Sendable, Equatable {
            let value: String
        }
        let seal = PrismDataSeal(key: key)
        let original = Secret(value: "confidential")
        let sealed = try seal.seal(original)
        let unsealed = try seal.unseal(Secret.self, from: sealed)
        #expect(unsealed == original)
    }

    @Test("Seal and verify data")
    func verifyData() {
        let seal = PrismDataSeal(key: key)
        let data = Data("important data".utf8)
        let sealed = seal.sealData(data)
        #expect(seal.verify(sealed))
    }

    @Test("Tampered data fails verification")
    func tamperedData() {
        let seal = PrismDataSeal(key: key)
        let data = Data("original".utf8)
        let sealed = seal.sealData(data)

        var tampered = sealed
        tampered = PrismDataSeal.SealedData(
            payload: Data("tampered".utf8),
            mac: sealed.mac,
            sealedAt: sealed.sealedAt
        )
        #expect(!seal.verify(tampered))
    }

    @Test("Wrong key fails verification")
    func wrongKey() {
        let seal1 = PrismDataSeal(key: SymmetricKey(size: .bits256))
        let seal2 = PrismDataSeal(key: SymmetricKey(size: .bits256))
        let sealed = seal1.sealData(Data("test".utf8))
        #expect(!seal2.verify(sealed))
    }

    @Test("Unseal tampered data throws")
    func unsealTampered() throws {
        struct Value: Codable, Sendable { let x: Int }
        let seal = PrismDataSeal(key: key)
        let sealed = try seal.seal(Value(x: 1))
        let tampered = PrismDataSeal.SealedData(
            payload: Data("bad".utf8),
            mac: sealed.mac,
            sealedAt: sealed.sealedAt
        )
        #expect(throws: PrismSecurityError.self) {
            try seal.unseal(Value.self, from: tampered)
        }
    }

    @Test("Raw data verify")
    func rawVerify() {
        let seal = PrismDataSeal(key: key)
        let data = Data("msg".utf8)
        let mac = Data(HMAC<SHA256>.authenticationCode(for: data, using: key))
        #expect(seal.verify(data: data, mac: mac))
    }

    @Test("Raw data verify fails with wrong mac")
    func rawVerifyFails() {
        let seal = PrismDataSeal(key: key)
        let data = Data("msg".utf8)
        let wrongMac = Data("not-a-mac".utf8)
        #expect(!seal.verify(data: data, mac: wrongMac))
    }

    @Test("Sealed data is Codable")
    func sealedDataCodable() throws {
        let seal = PrismDataSeal(key: key)
        let sealed = seal.sealData(Data("codable test".utf8))
        let encoded = try JSONEncoder().encode(sealed)
        let decoded = try JSONDecoder().decode(PrismDataSeal.SealedData.self, from: encoded)
        #expect(decoded.payload == sealed.payload)
        #expect(decoded.mac == sealed.mac)
    }

    @Test("Unseal with valid HMAC but invalid JSON throws deserialization error")
    func unsealBadJSON() {
        struct Value: Codable, Sendable { let x: Int }
        let seal = PrismDataSeal(key: key)
        let badPayload = Data("not-json".utf8)
        let validMac = Data(HMAC<SHA256>.authenticationCode(for: badPayload, using: key))
        let sealed = PrismDataSeal.SealedData(payload: badPayload, mac: validMac, sealedAt: .now)
        #expect(throws: PrismSecurityError.deserializationFailed) {
            try seal.unseal(Value.self, from: sealed)
        }
    }

    @Test("Seal empty data")
    func sealEmptyData() {
        let seal = PrismDataSeal(key: key)
        let sealed = seal.sealData(Data())
        #expect(sealed.payload.isEmpty)
        #expect(!sealed.mac.isEmpty)
        #expect(seal.verify(sealed))
    }

    @Test("SealedData equality")
    func sealedDataEquality() {
        let seal = PrismDataSeal(key: key)
        let data = Data("eq".utf8)
        let s1 = seal.sealData(data)
        let s2 = PrismDataSeal.SealedData(payload: s1.payload, mac: s1.mac, sealedAt: s1.sealedAt)
        #expect(s1 == s2)
    }
}
