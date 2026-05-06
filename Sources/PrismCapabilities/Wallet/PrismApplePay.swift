#if canImport(PassKit)
    import PassKit

    #if canImport(AppKit)
        import AppKit
    #endif

    // MARK: - Payment Item Type

    public enum PrismPaymentItemType: Sendable {
        case final_
        case pending
    }

    // MARK: - Payment Item

    public struct PrismPaymentItem: Sendable {
        public let label: String
        public let amount: Decimal
        public let type: PrismPaymentItemType

        public init(label: String, amount: Decimal, type: PrismPaymentItemType = .final_) {
            self.label = label
            self.amount = amount
            self.type = type
        }
    }

    // MARK: - Payment Network

    public enum PrismPaymentNetwork: Sendable, CaseIterable {
        case visa
        case mastercard
        case amex
        case discover
    }

    // MARK: - Payment Request

    public struct PrismPaymentRequest: Sendable {
        public let merchantID: String
        public let countryCode: String
        public let currencyCode: String
        public let items: [PrismPaymentItem]
        public let supportedNetworks: [PrismPaymentNetwork]

        public init(
            merchantID: String, countryCode: String, currencyCode: String, items: [PrismPaymentItem],
            supportedNetworks: [PrismPaymentNetwork]
        ) {
            self.merchantID = merchantID
            self.countryCode = countryCode
            self.currencyCode = currencyCode
            self.items = items
            self.supportedNetworks = supportedNetworks
        }
    }

    // MARK: - Payment Result

    public struct PrismPaymentResult: Sendable {
        public let transactionID: String?
        public let token: Data?
        public let success: Bool

        public init(transactionID: String? = nil, token: Data? = nil, success: Bool) {
            self.transactionID = transactionID
            self.token = token
            self.success = success
        }
    }

    // MARK: - Apple Pay Client

    @MainActor
    public final class PrismApplePayClient {

        public init() {}

        public func canMakePayments() -> Bool {
            PKPaymentAuthorizationController.canMakePayments()
        }

        public func canMakePayments(networks: [PrismPaymentNetwork]) -> Bool {
            let pkNetworks = networks.map { $0.pkNetwork }
            return PKPaymentAuthorizationController.canMakePayments(usingNetworks: pkNetworks)
        }

        public func requestPayment(_ request: PrismPaymentRequest) async throws -> PrismPaymentResult {
            let pkRequest = PKPaymentRequest()
            pkRequest.merchantIdentifier = request.merchantID
            pkRequest.countryCode = request.countryCode
            pkRequest.currencyCode = request.currencyCode
            pkRequest.supportedNetworks = request.supportedNetworks.map { $0.pkNetwork }
            pkRequest.merchantCapabilities = .capability3DS
            pkRequest.paymentSummaryItems = request.items.map { item in
                PKPaymentSummaryItem(
                    label: item.label,
                    amount: NSDecimalNumber(decimal: item.amount),
                    type: item.type == .pending ? .pending : .final
                )
            }

            let controller = PKPaymentAuthorizationController(paymentRequest: pkRequest)

            return await withCheckedContinuation { continuation in
                let delegate = PaymentDelegate { result in
                    continuation.resume(returning: result)
                }
                // Store delegate reference to keep it alive during presentation
                objc_setAssociatedObject(controller, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN)
                controller.delegate = delegate
                controller.present()
            }
        }
    }

    // MARK: - Private Helpers

    extension PrismPaymentNetwork {
        fileprivate var pkNetwork: PKPaymentNetwork {
            switch self {
            case .visa: .visa
            case .mastercard: .masterCard
            case .amex: .amex
            case .discover: .discover
            }
        }
    }

    private final class PaymentDelegate: NSObject, PKPaymentAuthorizationControllerDelegate, @unchecked Sendable {
        private let completion: (PrismPaymentResult) -> Void

        init(completion: @escaping (PrismPaymentResult) -> Void) {
            self.completion = completion
        }

        func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
            controller.dismiss()
        }

        #if os(macOS)
            func presentationWindow(for controller: PKPaymentAuthorizationController) -> NSWindow? {
                NSApp?.mainWindow
            }
        #endif

        func paymentAuthorizationController(
            _ controller: PKPaymentAuthorizationController,
            didAuthorizePayment payment: PKPayment
        ) async -> PKPaymentAuthorizationResult {
            let result = PrismPaymentResult(
                transactionID: payment.token.transactionIdentifier,
                token: payment.token.paymentData,
                success: true
            )
            completion(result)
            return PKPaymentAuthorizationResult(status: .success, errors: nil)
        }
    }
#endif
