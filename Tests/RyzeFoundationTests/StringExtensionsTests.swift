import Foundation
import Testing

@testable import RyzeFoundation

struct StringExtensionsTests {
    @Test
    func stableHashIsDeterministic() {
        let value = "Ryze"

        #expect(value.stableHash == value.stableHash)
    }

    @Test
    func stableHashChangesWhenContentChanges() {
        #expect("Ryze".stableHash != "Ryze Core".stableHash)
    }

    @Test
    func basicStringHelpersReturnExpectedValues() {
        #expect("Ryze".breakLine == "Ryze\n")
        #expect(String.breakLine == "\n")
        #expect("Ryze".space == "Ryze ")
        #expect(String.space == " ")
        #expect("42".int == 42)
        #expect("42.5".double == 42.5)
        #expect("São Paulo".normalized == "sao paulo")
    }

    @Test
    func stringConvertsToDateUsingFormatter() {
        let formatter = StubDateFormatter(format: "yyyy-MM-dd")
        let date = "2026-04-08".date(with: formatter)

        #expect(date == formatter.rawValue.date(from: "2026-04-08"))
    }

    @Test
    func substringStableHashMatchesItsContent() {
        let value = "Ryze".dropFirst()

        #expect(value.stableHash == "yze".stableHash)
    }
}
