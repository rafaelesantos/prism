import Foundation
import Testing

@testable import RyzeFoundation

struct RyzeDefaultsTests {
    @Test
    func storesAndLoadsCodableValues() throws {
        let suiteName = "ryze.tests.defaults.\(UUID().uuidString)"
        let userDefaults = try #require(UserDefaults(suiteName: suiteName))
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        let defaults = RyzeDefaults(userDefaults: userDefaults)
        let expected = SampleSettings(
            username: "rafael",
            launchCount: 7
        )

        defaults.set(expected, for: "settings")

        let stored: SampleSettings? = defaults.get(for: "settings")
        #expect(stored == expected)
    }

    @Test
    func returnsNilForMissingKeys() throws {
        let suiteName = "ryze.tests.defaults.\(UUID().uuidString)"
        let userDefaults = try #require(UserDefaults(suiteName: suiteName))
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        let defaults = RyzeDefaults(userDefaults: userDefaults)
        let stored: SampleSettings? = defaults.get(for: "missing")

        #expect(stored == nil)
    }

    @Test
    func removesStoredValuesWhenSettingNil() throws {
        let suiteName = "ryze.tests.defaults.\(UUID().uuidString)"
        let userDefaults = try #require(UserDefaults(suiteName: suiteName))
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        let defaults = RyzeDefaults(userDefaults: userDefaults)
        defaults.set(
            SampleSettings(
                username: "rafael",
                launchCount: 7
            ),
            for: "settings"
        )

        defaults.set(Optional<SampleSettings>.none, for: "settings")

        let stored: SampleSettings? = defaults.get(for: "settings")
        #expect(stored == nil)
    }

    @Test
    func returnsNilForCorruptedStoredData() throws {
        let suiteName = "ryze.tests.defaults.\(UUID().uuidString)"
        let userDefaults = try #require(UserDefaults(suiteName: suiteName))
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        userDefaults.set(Data([0xFF, 0xFE, 0xFD]), forKey: "settings")

        let defaults = RyzeDefaults(userDefaults: userDefaults)
        let stored: SampleSettings? = defaults.get(for: "settings")

        #expect(stored == nil)
    }

    @Test
    func ignoresValuesThatCannotBeEncoded() throws {
        let suiteName = "ryze.tests.defaults.\(UUID().uuidString)"
        let userDefaults = try #require(UserDefaults(suiteName: suiteName))
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        let defaults = RyzeDefaults(userDefaults: userDefaults)
        defaults.set(BrokenCodable(), for: "broken")

        #expect(userDefaults.data(forKey: "broken") == nil)
    }

    @Test
    func defaultInitializerProvidesAWorkingStore() {
        let key = "ryze.tests.defaults.default.\(UUID().uuidString)"
        let expected = SampleSettings(username: "rafael", launchCount: 11)
        let defaults = RyzeDefaults()
        defer { defaults.userDefaults.removeObject(forKey: key) }

        defaults.set(expected, for: key)

        let stored: SampleSettings? = defaults.get(for: key)
        #expect(stored == expected)
    }

    @Test
    func userDefaultsFactoryUsesSuiteWhenAvailableAndFallbackOtherwise() throws {
        let suiteName = "ryze.tests.defaults.factory.\(UUID().uuidString)"
        let suiteDefaults = try #require(UserDefaults(suiteName: suiteName))
        let fallbackDefaults = UserDefaults()

        let resolved = RyzeDefaults.makeUserDefaults(
            suiteName: suiteName,
            makeSuite: { _ in suiteDefaults },
            fallback: fallbackDefaults
        )
        let fallback = RyzeDefaults.makeUserDefaults(
            suiteName: suiteName,
            makeSuite: { _ in nil },
            fallback: fallbackDefaults
        )

        #expect(resolved === suiteDefaults)
        #expect(fallback === fallbackDefaults)
    }
}
