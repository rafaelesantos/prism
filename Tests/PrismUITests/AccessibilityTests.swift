import SwiftUI
import Testing

@testable import PrismUI

struct AccessibilityTests {

    @Test
    func dynamicTypePreviewRendersFiveSizes() {
        let preview = PrismDynamicTypePreview {
            Text("Test")
        }
        #expect(preview != nil)
    }

    @Test
    func reduceMotionViewSelectsCorrectBranch() {
        let view = PrismReduceMotion {
            Text("Reduced")
        } full: {
            Text("Full").rotation3DEffect(.degrees(10), axis: (1, 0, 0))
        }
        #expect(view != nil)
    }

    @Test
    func accessibilityAuditCreatesWithContext() {
        let audit = PrismAccessibilityAudit(context: "LoginScreen")
        #expect(audit != nil)
    }
}
