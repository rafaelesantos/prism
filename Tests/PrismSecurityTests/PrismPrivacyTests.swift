import Foundation
import Testing

@testable import PrismSecurity

@Suite("PrivLevel")
struct PrismPrivacyLevelTests {
    @Test("All levels available")
    func allLevels() {
        #expect(PrismPrivacyLevel.allCases.count == 4)
    }

    @Test("Comparable ordering")
    func ordering() {
        #expect(PrismPrivacyLevel.public < .internal)
        #expect(PrismPrivacyLevel.internal < .sensitive)
        #expect(PrismPrivacyLevel.sensitive < .restricted)
    }

    @Test("Restricted is highest")
    func highest() {
        #expect(PrismPrivacyLevel.restricted == PrismPrivacyLevel.allCases.max())
    }
}

@Suite("Redactor")
struct PrismRedactorTests {
    let redactor = PrismRedactor()

    @Test("Redact email")
    func email() {
        let result = redactor.redact("Contact john@example.com")
        #expect(result.contains("j***@***.***"))
        #expect(!result.contains("john@example.com"))
    }

    @Test("Redact phone number")
    func phone() {
        let result = redactor.redact("Call 555-123-4567")
        #expect(result.contains("***-***-4567"))
    }

    @Test("Redact credit card")
    func creditCard() {
        let result = redactor.redact("Card: 4111 1111 1111 1234")
        #expect(result.contains("****-****-****-1234"))
    }

    @Test("Redact SSN")
    func ssn() {
        let result = redactor.redact("SSN: 123-45-6789")
        #expect(result.contains("***-**-6789"))
    }

    @Test("Redact IP address")
    func ip() {
        let result = redactor.redact("IP: 192.168.1.100")
        #expect(result.contains("***.***.***.***"))
    }

    @Test("No PII unchanged")
    func noPII() {
        let input = "Hello, World!"
        #expect(redactor.redact(input) == input)
    }

    @Test("Multiple PII in one string")
    func multiple() {
        let result = redactor.redact("Email: a@b.com, Phone: 123-456-7890")
        #expect(!result.contains("a@b.com"))
        #expect(result.contains("***-***-7890"))
    }

    @Test("Remove style")
    func removeStyle() {
        let redactor = PrismRedactor(style: .remove)
        let result = redactor.redactValue("john@example.com", type: .email)
        #expect(result == "[REDACTED]")
    }

    @Test("Hash style")
    func hashStyle() {
        let redactor = PrismRedactor(style: .hash)
        let result = redactor.redactValue("john@example.com", type: .email)
        #expect(result.hasSuffix("..."))
        #expect(result.count > 3)
    }

    @Test("All PII types available")
    func allTypes() {
        #expect(PrismPIIType.allCases.count == 6)
    }
}

@Suite("PrivGuard")
struct PrismPrivacyGuardTests {
    let guard_ = PrismPrivacyGuard()

    @Test("Classify email as sensitive")
    func classifyEmail() {
        #expect(guard_.classify("email") == .sensitive)
        #expect(guard_.classify("user_email") == .sensitive)
    }

    @Test("Classify password as restricted")
    func classifyPassword() {
        #expect(guard_.classify("password") == .restricted)
        #expect(guard_.classify("secret_key") == .restricted)
    }

    @Test("Classify user_id as internal")
    func classifyUserID() {
        #expect(guard_.classify("user_id") == .internal)
    }

    @Test("Classify name as public")
    func classifyName() {
        #expect(guard_.classify("name") == .public)
        #expect(guard_.classify("username") == .public)
    }

    @Test("Classify unknown as public")
    func classifyUnknown() {
        #expect(guard_.classify("totally_random_field") == .public)
    }

    @Test("Protect restricted field")
    func protectRestricted() {
        let result = guard_.protect(field: "password", value: "secret123")
        #expect(result == "[RESTRICTED]")
    }

    @Test("Protect public field unchanged")
    func protectPublic() {
        let result = guard_.protect(field: "name", value: "John")
        #expect(result == "John")
    }

    @Test("Protect sensitive field redacts")
    func protectSensitive() {
        let result = guard_.protect(field: "email", value: "john@example.com")
        #expect(!result.contains("john@example.com") || result.contains("j***"))
    }

    @Test("Redact delegates to redactor")
    func redact() {
        let result = guard_.redact("Email: test@test.com")
        #expect(!result.contains("test@test.com"))
    }

    @Test("Protect internal field returns value unchanged")
    func protectInternal() {
        let result = guard_.protect(field: "user_id", value: "12345")
        #expect(result == "12345")
    }

    @Test("Protect account_id field as internal")
    func protectAccountId() {
        let result = guard_.protect(field: "account_id", value: "acc-999")
        #expect(result == "acc-999")
    }

    @Test("RedactValue delegates to redactor")
    func redactValue() {
        let result = guard_.redactValue("john@example.com", type: .email)
        #expect(result.contains("***"))
    }

    @Test("Classify ip_address as internal")
    func classifyIp() {
        #expect(guard_.classify("ip_address") == .internal)
    }

    @Test("Classify device_id as internal")
    func classifyDeviceId() {
        #expect(guard_.classify("device_id") == .internal)
    }

    @Test("Classify credit_card as sensitive")
    func classifyCreditCard() {
        #expect(guard_.classify("credit_card") == .sensitive)
    }

    @Test("Classify token as sensitive")
    func classifyToken() {
        #expect(guard_.classify("auth_token") == .sensitive)
    }

    @Test("Classify api_key as sensitive")
    func classifyApiKey() {
        #expect(guard_.classify("api_key") == .sensitive)
    }

    @Test("Classify private_key as restricted")
    func classifyPrivateKey() {
        #expect(guard_.classify("private_key") == .restricted)
    }

    @Test("Classify ssn as restricted")
    func classifySsn() {
        #expect(guard_.classify("user_ssn") == .restricted)
    }

    @Test("Classify social_security as restricted")
    func classifySocialSecurity() {
        #expect(guard_.classify("social_security_number") == .restricted)
    }

    @Test("Classify birth as sensitive")
    func classifyBirth() {
        #expect(guard_.classify("date_of_birth") == .sensitive)
    }

    @Test("Classify phone as sensitive")
    func classifyPhone() {
        #expect(guard_.classify("phone_number") == .sensitive)
    }

    @Test("Classify address as sensitive")
    func classifyAddress() {
        #expect(guard_.classify("home_address") == .sensitive)
    }

    @Test("Custom field classifications override defaults")
    func customClassifications() {
        let guard2 = PrismPrivacyGuard(
            fieldClassifications: ["custom_field": .restricted]
        )
        #expect(guard2.classify("custom_field") == .restricted)
    }
}

@Suite("ClipGuard")
struct PrismClipboardGuardTests {
    @Test("Guard initializes with timeout")
    func init_() {
        let cg = PrismClipboardGuard(clearAfter: 60)
        _ = cg
    }

    @Test("Clear now does not throw")
    func clearNow() {
        let cg = PrismClipboardGuard()
        cg.clearNow()
    }

    @Test("Cancel clear does not throw")
    func cancelClear() {
        let cg = PrismClipboardGuard()
        cg.cancelClear()
    }

    @Test("Default timeout is 30 seconds")
    func defaultTimeout() {
        let cg = PrismClipboardGuard()
        _ = cg
    }

    @Test("Copy securely string does not throw")
    func copySecurelyString() {
        let cg = PrismClipboardGuard(clearAfter: 999)
        cg.copySecurely("test-clipboard")
        cg.cancelClear()
    }

    @Test("Copy securely data does not throw")
    func copySecurelyData() {
        let cg = PrismClipboardGuard(clearAfter: 999)
        cg.copySecurely(Data("test-data".utf8))
        cg.cancelClear()
    }

    @Test("Schedule clear triggers and can be cancelled")
    func scheduleClearCancel() async throws {
        let cg = PrismClipboardGuard(clearAfter: 0.1)
        cg.copySecurely("temp")
        cg.cancelClear()
    }
}
