import SwiftUI
import Testing

@testable import PrismUI

struct LayoutTests {

    // MARK: - PrismSpacer

    @Test
    func spacerDefaultUsesMediumToken() {
        let spacer = PrismSpacer()
        #expect(spacer != nil)
    }

    @Test
    func spacerAcceptsAllTokens() {
        for token in SpacingToken.allCases {
            let spacer = PrismSpacer(token)
            #expect(spacer != nil)
        }
    }

    @Test
    func spacerSupportsAxisConstraint() {
        let horizontal = PrismSpacer(.lg, axis: .horizontal)
        let vertical = PrismSpacer(.lg, axis: .vertical)
        let both = PrismSpacer(.lg)
        #expect(horizontal != nil)
        #expect(vertical != nil)
        #expect(both != nil)
    }

    // MARK: - PrismScaffold

    @Test
    func scaffoldDefaultUsesBackgroundToken() {
        let scaffold = PrismScaffold {
            Text("Content")
        }
        #expect(scaffold != nil)
    }

    @Test
    func scaffoldAcceptsCustomBackground() {
        let scaffold = PrismScaffold(background: .surfaceSecondary) {
            Text("Content")
        }
        #expect(scaffold != nil)
    }

    // MARK: - PrismAdaptiveStack

    @Test
    func adaptiveStackDefaultSpacingIsMedium() {
        let stack = PrismAdaptiveStack {
            Text("A")
            Text("B")
        }
        #expect(stack != nil)
    }

    // MARK: - PrismSection

    @Test
    func sectionSupportsHeaderOnly() {
        let section = PrismSection {
            Text("Content")
        } header: {
            Text("Header")
        }
        #expect(section != nil)
    }

    @Test
    func sectionSupportsContentOnly() {
        let section = PrismSection {
            Text("Content")
        }
        #expect(section != nil)
    }

    @Test
    func sectionSupportsHeaderAndFooter() {
        let section = PrismSection {
            Text("Content")
        } header: {
            Text("Header")
        } footer: {
            Text("Footer")
        }
        #expect(section != nil)
    }
}
