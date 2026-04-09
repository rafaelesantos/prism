import Foundation
import Testing

@testable import RyzeFoundation

struct RyzeBundleTests {
    @Test
    func readsInjectedBundleMetadata() {
        let version = OperatingSystemVersion(
            majorVersion: 26,
            minorVersion: 4,
            patchVersion: 1
        )

        let bundle = RyzeBundle(
            infoDictionary: [
                "CFBundleName": "RyzeApp",
                "CFBundleIdentifier": "com.ryze.app",
                "CFBundleShortVersionString": "1.2.3",
                "CFBundleVersion": "456",
            ],
            operatingSystemVersion: version
        )

        #expect(bundle.applicationName == "RyzeApp")
        #expect(bundle.applicationIdentifier == "com.ryze.app")
        #expect(bundle.applicationVersion == "1.2.3")
        #expect(bundle.applicationBuild == "456")
        #expect(bundle.operatingSystemVersion.majorVersion == 26)
        #expect(bundle.operatingSystemVersion.minorVersion == 4)
        #expect(bundle.operatingSystemVersion.patchVersion == 1)
    }

    @Test
    func returnsNilWhenMetadataIsMissing() {
        let bundle = RyzeBundle(infoDictionary: nil)

        #expect(bundle.applicationName == nil)
        #expect(bundle.applicationIdentifier == nil)
        #expect(bundle.applicationVersion == nil)
        #expect(bundle.applicationBuild == nil)
    }
}
