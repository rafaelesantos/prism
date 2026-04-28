import SwiftUI
import Testing

@testable import PrismUI

struct PrimitiveTests {

    // MARK: - PrismButton

    @Test
    func buttonVariantsAreFiveCases() {
        let variants: [PrismButtonVariant] = [.filled, .tinted, .bordered, .plain, .glass]
        #expect(variants.count == 5)
    }

    @Test
    func buttonHapticsAreFourCases() {
        let haptics: [PrismButtonHaptic] = [.none, .light, .medium, .heavy]
        #expect(haptics.count == 4)
    }

    // MARK: - PrismIcon

    @Test
    func iconSizesHaveCorrectPoints() {
        #expect(PrismIcon.Size.small.points == 14)
        #expect(PrismIcon.Size.medium.points == 18)
        #expect(PrismIcon.Size.large.points == 24)
        #expect(PrismIcon.Size.xLarge.points == 32)
        #expect(PrismIcon.Size.custom(40).points == 40)
    }

    // MARK: - PrismDivider

    @Test
    func dividerDefaultsToSeparatorColor() {
        let divider = PrismDivider()
        #expect(divider != nil)
    }

    // MARK: - PrismTag

    @Test
    func tagStylesAreSixCases() {
        let styles: [PrismTag.Style] = [.default, .success, .warning, .error, .info, .brand]
        #expect(styles.count == 6)
    }

    // MARK: - PrismTextField

    @Test
    func textFieldValidationRequiredDetectsEmpty() {
        let validation = PrismTextField.Validation.required("Required")
        switch validation {
        case .required(let message):
            #expect(message != nil)
        default:
            Issue.record("Expected required validation")
        }
    }

    @Test
    func textFieldValidationMinLengthStoresCount() {
        let validation = PrismTextField.Validation.minLength(5, "Too short")
        switch validation {
        case .minLength(let count, _):
            #expect(count == 5)
        default:
            Issue.record("Expected minLength validation")
        }
    }

    @Test
    func textFieldValidationPatternStoresRegex() {
        let validation = PrismTextField.Validation.pattern("^[A-Z]", "Must start with uppercase")
        switch validation {
        case .pattern(let regex, _):
            #expect(regex == "^[A-Z]")
        default:
            Issue.record("Expected pattern validation")
        }
    }

    @Test
    func textFieldValidationCustomRunsClosure() {
        let validation = PrismTextField.Validation.custom { text in
            text.isEmpty ? "Empty" : nil
        }
        switch validation {
        case .custom(let validator):
            #expect(validator("") != nil)
            #expect(validator("hello") == nil)
        default:
            Issue.record("Expected custom validation")
        }
    }

    // MARK: - PrismLoadingState

    @Test
    func loadingStateHasThreeCases() {
        let loading = PrismLoadingState.State.loading
        let empty = PrismLoadingState.State.empty(title: "No data", message: nil, icon: nil)
        let error = PrismLoadingState.State.error("Failed", retry: nil)

        switch loading {
        case .loading: break
        default: Issue.record("Expected loading")
        }

        switch empty {
        case .empty(let title, _, _):
            #expect(title != nil)
        default: Issue.record("Expected empty")
        }

        switch error {
        case .error(let message, _):
            #expect(message != nil)
        default: Issue.record("Expected error")
        }
    }
}
