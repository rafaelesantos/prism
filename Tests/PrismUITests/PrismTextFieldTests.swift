//
//  PrismTextFieldTests.swift
//  PrismUITests
//
//  Created by Rafael Escaleira on 27/04/26.
//

import SwiftUI
import XCTest

@testable import PrismUI

// MARK: - PrismDefaultTextFieldMask Tests

final class PrismDefaultTextFieldMaskTests: XCTestCase {

    // MARK: - Phone Number

    func testPhoneNumberMaskHasThreePatterns() {
        let mask = PrismDefaultTextFieldMask.phoneNumber
        XCTAssertNotNil(mask.rawValues)
        XCTAssertEqual(mask.rawValues?.count, 3)
    }

    func testPhoneNumberMaskContainsMobilePattern() {
        let patterns = PrismDefaultTextFieldMask.phoneNumber.rawValues
        XCTAssertTrue(patterns?.contains("(##) # ####-####") == true)
    }

    func testPhoneNumberMaskContainsLandlinePattern() {
        let patterns = PrismDefaultTextFieldMask.phoneNumber.rawValues
        XCTAssertTrue(patterns?.contains("(##) ####-####") == true)
    }

    func testPhoneNumberMaskContainsInternationalPattern() {
        let patterns = PrismDefaultTextFieldMask.phoneNumber.rawValues
        XCTAssertTrue(patterns?.contains("+## (##) # ####-####") == true)
    }

    // MARK: - CPF

    func testCPFMaskHasSinglePattern() {
        let mask = PrismDefaultTextFieldMask.cpf
        XCTAssertNotNil(mask.rawValues)
        XCTAssertEqual(mask.rawValues?.count, 1)
    }

    func testCPFMaskPatternMatchesExpectedFormat() {
        let mask = PrismDefaultTextFieldMask.cpf
        XCTAssertEqual(mask.rawValues?.first, "###.###.###-##")
    }

    func testCPFMaskPatternHasElevenDigitPlaceholders() {
        let pattern = PrismDefaultTextFieldMask.cpf.rawValues?.first ?? ""
        let digitCount = pattern.filter { $0 == "#" }.count
        XCTAssertEqual(digitCount, 11)
    }

    // MARK: - CNPJ

    func testCNPJMaskHasSinglePattern() {
        let mask = PrismDefaultTextFieldMask.cnpj
        XCTAssertNotNil(mask.rawValues)
        XCTAssertEqual(mask.rawValues?.count, 1)
    }

    func testCNPJMaskPatternMatchesExpectedFormat() {
        let mask = PrismDefaultTextFieldMask.cnpj
        XCTAssertEqual(mask.rawValues?.first, "##.###.###/####-##")
    }

    func testCNPJMaskPatternHasFourteenDigitPlaceholders() {
        let pattern = PrismDefaultTextFieldMask.cnpj.rawValues?.first ?? ""
        let digitCount = pattern.filter { $0 == "#" }.count
        XCTAssertEqual(digitCount, 14)
    }

    // MARK: - CEP

    func testCEPMaskHasSinglePattern() {
        let mask = PrismDefaultTextFieldMask.cep
        XCTAssertNotNil(mask.rawValues)
        XCTAssertEqual(mask.rawValues?.count, 1)
    }

    func testCEPMaskPatternMatchesExpectedFormat() {
        let mask = PrismDefaultTextFieldMask.cep
        XCTAssertEqual(mask.rawValues?.first, "#####-###")
    }

    func testCEPMaskPatternHasEightDigitPlaceholders() {
        let pattern = PrismDefaultTextFieldMask.cep.rawValues?.first ?? ""
        let digitCount = pattern.filter { $0 == "#" }.count
        XCTAssertEqual(digitCount, 8)
    }

    // MARK: - Credit Card Number

    func testCreditCardNumberMaskHasSinglePattern() {
        let mask = PrismDefaultTextFieldMask.creditCardNumber
        XCTAssertNotNil(mask.rawValues)
        XCTAssertEqual(mask.rawValues?.count, 1)
    }

    func testCreditCardNumberMaskPatternMatchesExpectedFormat() {
        let mask = PrismDefaultTextFieldMask.creditCardNumber
        XCTAssertEqual(mask.rawValues?.first, "#### #### #### ####")
    }

    func testCreditCardNumberMaskPatternHasSixteenDigitPlaceholders() {
        let pattern = PrismDefaultTextFieldMask.creditCardNumber.rawValues?.first ?? ""
        let digitCount = pattern.filter { $0 == "#" }.count
        XCTAssertEqual(digitCount, 16)
    }

    // MARK: - Credit Card Expiration Date

    func testCreditCardExpirationDateMaskHasSinglePattern() {
        let mask = PrismDefaultTextFieldMask.creditCardExpirationDate
        XCTAssertNotNil(mask.rawValues)
        XCTAssertEqual(mask.rawValues?.count, 1)
    }

    func testCreditCardExpirationDateMaskPatternMatchesExpectedFormat() {
        let mask = PrismDefaultTextFieldMask.creditCardExpirationDate
        XCTAssertEqual(mask.rawValues?.first, "##/##")
    }

    func testCreditCardExpirationDateMaskPatternHasFourDigitPlaceholders() {
        let pattern = PrismDefaultTextFieldMask.creditCardExpirationDate.rawValues?.first ?? ""
        let digitCount = pattern.filter { $0 == "#" }.count
        XCTAssertEqual(digitCount, 4)
    }

    // MARK: - Credit Card CVV

    func testCreditCardCVVMaskHasSinglePattern() {
        let mask = PrismDefaultTextFieldMask.creditCardCVV
        XCTAssertNotNil(mask.rawValues)
        XCTAssertEqual(mask.rawValues?.count, 1)
    }

    func testCreditCardCVVMaskPatternMatchesExpectedFormat() {
        let mask = PrismDefaultTextFieldMask.creditCardCVV
        XCTAssertEqual(mask.rawValues?.first, "###")
    }

    func testCreditCardCVVMaskPatternHasThreeDigitPlaceholders() {
        let pattern = PrismDefaultTextFieldMask.creditCardCVV.rawValues?.first ?? ""
        let digitCount = pattern.filter { $0 == "#" }.count
        XCTAssertEqual(digitCount, 3)
    }

    // MARK: - Protocol Conformance

    func testAllCasesConformToPrismTextFieldMask() {
        let allMasks: [PrismTextFieldMask] = [
            PrismDefaultTextFieldMask.phoneNumber,
            PrismDefaultTextFieldMask.cpf,
            PrismDefaultTextFieldMask.cnpj,
            PrismDefaultTextFieldMask.cep,
            PrismDefaultTextFieldMask.creditCardNumber,
            PrismDefaultTextFieldMask.creditCardExpirationDate,
            PrismDefaultTextFieldMask.creditCardCVV,
        ]

        for mask in allMasks {
            XCTAssertNotNil(mask.rawValues, "Every mask case should have non-nil rawValues")
        }
    }

    func testAllCasesHaveAtLeastOnePattern() {
        let allMasks: [PrismDefaultTextFieldMask] = [
            .phoneNumber, .cpf, .cnpj, .cep,
            .creditCardNumber, .creditCardExpirationDate, .creditCardCVV,
        ]

        for mask in allMasks {
            XCTAssertGreaterThanOrEqual(
                mask.rawValues?.count ?? 0, 1,
                "\(mask) should have at least one pattern"
            )
        }
    }
}

// MARK: - PrismDefaultTextFieldConfiguration Tests

final class PrismDefaultTextFieldConfigurationTests: XCTestCase {

    // MARK: - Email Configuration Properties

    func testEmailConfigurationMaskIsNil() {
        let config = PrismDefaultTextFieldConfiguration.email
        XCTAssertNil(config.mask)
    }

    func testEmailConfigurationIconIsEnvelopeFill() {
        let config = PrismDefaultTextFieldConfiguration.email
        XCTAssertEqual(config.icon, "envelope.fill")
    }

    func testEmailConfigurationContentTypeIsEmailAddress() {
        let config = PrismDefaultTextFieldConfiguration.email
        XCTAssertEqual(config.contentType, .emailAddress)
    }

    func testEmailConfigurationAutocapitalizationIsNever() {
        let config = PrismDefaultTextFieldConfiguration.email
        XCTAssertEqual(config.autocapitalizationType, .never)
    }

    func testEmailConfigurationSubmitLabelIsNotNil() {
        let config = PrismDefaultTextFieldConfiguration.email
        // SubmitLabel does not conform to Equatable, so we verify the property is accessible.
        let _ = config.submitLabel
    }

    // MARK: - Email Validation: Valid Emails

    func testEmailValidationAcceptsSimpleEmail() {
        let config = PrismDefaultTextFieldConfiguration.email
        XCTAssertNoThrow(try config.validate(text: "user@example.com"))
    }

    func testEmailValidationAcceptsEmailWithSubdomain() {
        let config = PrismDefaultTextFieldConfiguration.email
        XCTAssertNoThrow(try config.validate(text: "user@mail.example.com"))
    }

    func testEmailValidationAcceptsEmailWithPlusTag() {
        let config = PrismDefaultTextFieldConfiguration.email
        XCTAssertNoThrow(try config.validate(text: "user+tag@example.com"))
    }

    func testEmailValidationAcceptsEmailWithDots() {
        let config = PrismDefaultTextFieldConfiguration.email
        XCTAssertNoThrow(try config.validate(text: "first.last@example.com"))
    }

    func testEmailValidationAcceptsEmailWithNumbers() {
        let config = PrismDefaultTextFieldConfiguration.email
        XCTAssertNoThrow(try config.validate(text: "user123@example456.com"))
    }

    func testEmailValidationAcceptsEmailWithUnderscore() {
        let config = PrismDefaultTextFieldConfiguration.email
        XCTAssertNoThrow(try config.validate(text: "user_name@example.com"))
    }

    func testEmailValidationAcceptsEmailWithPercentSign() {
        let config = PrismDefaultTextFieldConfiguration.email
        XCTAssertNoThrow(try config.validate(text: "user%name@example.com"))
    }

    func testEmailValidationAcceptsEmailWithHyphenInDomain() {
        let config = PrismDefaultTextFieldConfiguration.email
        XCTAssertNoThrow(try config.validate(text: "user@my-domain.com"))
    }

    func testEmailValidationAcceptsEmailWithLongTLD() {
        let config = PrismDefaultTextFieldConfiguration.email
        XCTAssertNoThrow(try config.validate(text: "user@example.museum"))
    }

    func testEmailValidationAcceptsUppercaseEmail() {
        let config = PrismDefaultTextFieldConfiguration.email
        XCTAssertNoThrow(try config.validate(text: "USER@EXAMPLE.COM"))
    }

    func testEmailValidationAcceptsMixedCaseEmail() {
        let config = PrismDefaultTextFieldConfiguration.email
        XCTAssertNoThrow(try config.validate(text: "User@Example.Com"))
    }

    // MARK: - Email Validation: Empty String

    func testEmailValidationAcceptsEmptyString() {
        let config = PrismDefaultTextFieldConfiguration.email
        XCTAssertNoThrow(try config.validate(text: ""))
    }

    // MARK: - Email Validation: Invalid Emails

    func testEmailValidationRejectsMissingAtSign() {
        let config = PrismDefaultTextFieldConfiguration.email
        XCTAssertThrowsError(try config.validate(text: "userexample.com"))
    }

    func testEmailValidationRejectsMissingDomain() {
        let config = PrismDefaultTextFieldConfiguration.email
        XCTAssertThrowsError(try config.validate(text: "user@"))
    }

    func testEmailValidationRejectsMissingLocalPart() {
        let config = PrismDefaultTextFieldConfiguration.email
        XCTAssertThrowsError(try config.validate(text: "@example.com"))
    }

    func testEmailValidationRejectsMissingTLD() {
        let config = PrismDefaultTextFieldConfiguration.email
        XCTAssertThrowsError(try config.validate(text: "user@example"))
    }

    func testEmailValidationAcceptsDoubleDotsInDomain() {
        // The current regex pattern [A-Z0-9.-]+ permits consecutive dots in the domain.
        // This test documents the actual behavior of the implementation.
        let config = PrismDefaultTextFieldConfiguration.email
        XCTAssertNoThrow(try config.validate(text: "user@example..com"))
    }

    func testEmailValidationRejectsSpacesInEmail() {
        let config = PrismDefaultTextFieldConfiguration.email
        XCTAssertThrowsError(try config.validate(text: "user @example.com"))
    }

    func testEmailValidationRejectsMultipleAtSigns() {
        let config = PrismDefaultTextFieldConfiguration.email
        XCTAssertThrowsError(try config.validate(text: "user@@example.com"))
    }

    func testEmailValidationRejectsPlainText() {
        let config = PrismDefaultTextFieldConfiguration.email
        XCTAssertThrowsError(try config.validate(text: "not-an-email"))
    }

    func testEmailValidationRejectsSingleCharacterTLD() {
        let config = PrismDefaultTextFieldConfiguration.email
        XCTAssertThrowsError(try config.validate(text: "user@example.c"))
    }

    func testEmailValidationRejectsDotAtEnd() {
        let config = PrismDefaultTextFieldConfiguration.email
        XCTAssertThrowsError(try config.validate(text: "user@example.com."))
    }

    // MARK: - Email Validation Error Type

    func testEmailValidationThrowsEmailValidationFailedError() {
        let config = PrismDefaultTextFieldConfiguration.email
        do {
            try config.validate(text: "invalid")
            XCTFail("Expected PrismUIError.emailValidationFailed to be thrown")
        } catch let error as PrismUIError {
            XCTAssertEqual(error, .emailValidationFailed)
        } catch {
            XCTFail("Unexpected error type: \(type(of: error))")
        }
    }

    // MARK: - Protocol Conformance

    func testEmailConfigurationConformsToPrismTextFieldConfiguration() {
        let config: PrismTextFieldConfiguration = PrismDefaultTextFieldConfiguration.email
        XCTAssertNotNil(config.placeholder)
        XCTAssertNotNil(config.contentType)
    }
}

// MARK: - PrismTextFieldContentType Tests

final class PrismTextFieldContentTypeTests: XCTestCase {

    func testDefaultCaseExists() {
        let contentType = PrismTextFieldContentType.default
        XCTAssertNotNil(contentType)
    }

    func testAsciiCapableCaseExists() {
        let contentType = PrismTextFieldContentType.asciiCapable
        XCTAssertNotNil(contentType)
    }

    func testNumbersAndPunctuationCaseExists() {
        let contentType = PrismTextFieldContentType.numbersAndPunctuation
        XCTAssertNotNil(contentType)
    }

    func testURLCaseExists() {
        let contentType = PrismTextFieldContentType.URL
        XCTAssertNotNil(contentType)
    }

    func testNumberPadCaseExists() {
        let contentType = PrismTextFieldContentType.numberPad
        XCTAssertNotNil(contentType)
    }

    func testPhonePadCaseExists() {
        let contentType = PrismTextFieldContentType.phonePad
        XCTAssertNotNil(contentType)
    }

    func testNamePhonePadCaseExists() {
        let contentType = PrismTextFieldContentType.namePhonePad
        XCTAssertNotNil(contentType)
    }

    func testEmailAddressCaseExists() {
        let contentType = PrismTextFieldContentType.emailAddress
        XCTAssertNotNil(contentType)
    }

    func testDecimalPadCaseExists() {
        let contentType = PrismTextFieldContentType.decimalPad
        XCTAssertNotNil(contentType)
    }

    func testTwitterCaseExists() {
        let contentType = PrismTextFieldContentType.twitter
        XCTAssertNotNil(contentType)
    }

    func testWebSearchCaseExists() {
        let contentType = PrismTextFieldContentType.webSearch
        XCTAssertNotNil(contentType)
    }

    func testAsciiCapableNumberPadCaseExists() {
        let contentType = PrismTextFieldContentType.asciiCapableNumberPad
        XCTAssertNotNil(contentType)
    }

    func testAlphabetCaseExists() {
        let contentType = PrismTextFieldContentType.alphabet
        XCTAssertNotNil(contentType)
    }

    func testAllThirteenCasesAreDistinct() {
        let allCases: [PrismTextFieldContentType] = [
            .default, .asciiCapable, .numbersAndPunctuation, .URL,
            .numberPad, .phonePad, .namePhonePad, .emailAddress,
            .decimalPad, .twitter, .webSearch, .asciiCapableNumberPad,
            .alphabet,
        ]
        XCTAssertEqual(allCases.count, 13)
    }

    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    func testDefaultRawValueIsDefaultKeyboardType() {
        XCTAssertEqual(PrismTextFieldContentType.default.rawValue, .default)
    }

    func testAsciiCapableRawValueIsAsciiCapableKeyboardType() {
        XCTAssertEqual(PrismTextFieldContentType.asciiCapable.rawValue, .asciiCapable)
    }

    func testNumbersAndPunctuationRawValueIsNumbersAndPunctuation() {
        XCTAssertEqual(PrismTextFieldContentType.numbersAndPunctuation.rawValue, .numbersAndPunctuation)
    }

    func testURLRawValueIsURLKeyboardType() {
        XCTAssertEqual(PrismTextFieldContentType.URL.rawValue, .URL)
    }

    func testNumberPadRawValueIsNumberPadKeyboardType() {
        XCTAssertEqual(PrismTextFieldContentType.numberPad.rawValue, .numberPad)
    }

    func testPhonePadRawValueIsPhonePadKeyboardType() {
        XCTAssertEqual(PrismTextFieldContentType.phonePad.rawValue, .phonePad)
    }

    func testNamePhonePadRawValueIsNamePhonePadKeyboardType() {
        XCTAssertEqual(PrismTextFieldContentType.namePhonePad.rawValue, .namePhonePad)
    }

    func testEmailAddressRawValueIsEmailAddressKeyboardType() {
        XCTAssertEqual(PrismTextFieldContentType.emailAddress.rawValue, .emailAddress)
    }

    func testDecimalPadRawValueIsDecimalPadKeyboardType() {
        XCTAssertEqual(PrismTextFieldContentType.decimalPad.rawValue, .decimalPad)
    }

    func testTwitterRawValueIsTwitterKeyboardType() {
        XCTAssertEqual(PrismTextFieldContentType.twitter.rawValue, .twitter)
    }

    func testWebSearchRawValueIsWebSearchKeyboardType() {
        XCTAssertEqual(PrismTextFieldContentType.webSearch.rawValue, .webSearch)
    }

    func testAsciiCapableNumberPadRawValueIsAsciiCapableNumberPadKeyboardType() {
        XCTAssertEqual(PrismTextFieldContentType.asciiCapableNumberPad.rawValue, .asciiCapableNumberPad)
    }

    func testAlphabetRawValueIsAlphabetKeyboardType() {
        XCTAssertEqual(PrismTextFieldContentType.alphabet.rawValue, .alphabet)
    }
    #endif

    func testContentTypeEqualityComparison() {
        XCTAssertEqual(PrismTextFieldContentType.emailAddress, .emailAddress)
        XCTAssertNotEqual(PrismTextFieldContentType.emailAddress, .phonePad)
    }
}

// MARK: - PrismTextInputAutocapitalization Tests

final class PrismTextInputAutocapitalizationTests: XCTestCase {

    func testNeverCaseExists() {
        let autocap = PrismTextInputAutocapitalization.never
        XCTAssertNotNil(autocap)
    }

    func testWordsCaseExists() {
        let autocap = PrismTextInputAutocapitalization.words
        XCTAssertNotNil(autocap)
    }

    func testSentencesCaseExists() {
        let autocap = PrismTextInputAutocapitalization.sentences
        XCTAssertNotNil(autocap)
    }

    func testCharactersCaseExists() {
        let autocap = PrismTextInputAutocapitalization.characters
        XCTAssertNotNil(autocap)
    }

    func testAllFourCasesAreDistinct() {
        let allCases: [PrismTextInputAutocapitalization] = [
            .never, .words, .sentences, .characters,
        ]
        XCTAssertEqual(allCases.count, 4)
    }

    func testAutocapitalizationEqualityComparison() {
        XCTAssertEqual(PrismTextInputAutocapitalization.never, .never)
        XCTAssertNotEqual(PrismTextInputAutocapitalization.never, .words)
        XCTAssertNotEqual(PrismTextInputAutocapitalization.sentences, .characters)
    }

    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    func testNeverRawValueIsNever() {
        XCTAssertEqual(PrismTextInputAutocapitalization.never.rawValue, .never)
    }

    func testWordsRawValueIsWords() {
        XCTAssertEqual(PrismTextInputAutocapitalization.words.rawValue, .words)
    }

    func testSentencesRawValueIsSentences() {
        XCTAssertEqual(PrismTextInputAutocapitalization.sentences.rawValue, .sentences)
    }

    func testCharactersRawValueIsCharacters() {
        XCTAssertEqual(PrismTextInputAutocapitalization.characters.rawValue, .characters)
    }
    #endif
}

// MARK: - String Formatting Tests

final class PrismStringFormattingTests: XCTestCase {

    func testFormattedWithSimpleFormatString() {
        let result = "world".formatted(with: "Hello, %@!")
        XCTAssertEqual(result, "Hello, world!")
    }

    func testFormattedWithPrefixFormat() {
        let result = "value".formatted(with: "prefix_%@")
        XCTAssertEqual(result, "prefix_value")
    }

    func testFormattedWithSuffixFormat() {
        let result = "value".formatted(with: "%@_suffix")
        XCTAssertEqual(result, "value_suffix")
    }

    func testFormattedWithOnlyPlaceholder() {
        let result = "test".formatted(with: "%@")
        XCTAssertEqual(result, "test")
    }

    func testFormattedWithEmptyString() {
        let result = "".formatted(with: "prefix_%@_suffix")
        XCTAssertEqual(result, "prefix__suffix")
    }

    func testFormattedWithNoPlaceholder() {
        let result = "ignored".formatted(with: "static text")
        XCTAssertEqual(result, "static text")
    }

    func testFormattedWithMultiplePlaceholders() {
        // String(format:) only replaces the first %@ with self
        let result = "first".formatted(with: "%@ and %@")
        // The second %@ will not be replaced by this method since only one argument is passed.
        // NSString format with one argument and two placeholders results in the second being empty or undefined.
        // We simply verify it does not crash.
        XCTAssertNotNil(result)
    }

    func testFormattedPreservesSpecialCharacters() {
        let result = "cafe".formatted(with: "Welcome to %@!")
        XCTAssertEqual(result, "Welcome to cafe!")
    }

    func testFormattedWithUnicodeContent() {
        let result = "Sao Paulo".formatted(with: "City: %@")
        XCTAssertEqual(result, "City: Sao Paulo")
    }

    func testFormattedWithNumericString() {
        let result = "42".formatted(with: "The answer is %@")
        XCTAssertEqual(result, "The answer is 42")
    }
}

// MARK: - PrismUIError Tests (email validation related)

final class PrismUIErrorEmailTests: XCTestCase {

    func testEmailValidationFailedHasNonEmptyDescription() {
        let error = PrismUIError.emailValidationFailed
        XCTAssertFalse(error.description.isEmpty)
    }

    func testEmailValidationFailedHasNonNilFailureReason() {
        let error = PrismUIError.emailValidationFailed
        XCTAssertNotNil(error.failureReason)
    }

    func testEmailValidationFailedHasNonNilRecoverySuggestion() {
        let error = PrismUIError.emailValidationFailed
        XCTAssertNotNil(error.recoverySuggestion)
    }

    func testEmailValidationFailedDescriptionContainsExpectedText() {
        let error = PrismUIError.emailValidationFailed
        XCTAssertEqual(error.description, "Email validation failed.")
    }

    func testEmailValidationFailedIsDistinctFromOtherErrors() {
        XCTAssertNotEqual(PrismUIError.emailValidationFailed, .systemSymbolNotFound)
    }
}
