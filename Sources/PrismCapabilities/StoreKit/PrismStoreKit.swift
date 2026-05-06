#if canImport(StoreKit)
    import StoreKit

    // MARK: - Product Type

    public enum PrismProductType: Sendable, CaseIterable {
        case consumable
        case nonConsumable
        case autoRenewable
        case nonRenewable
    }

    // MARK: - Product Info

    public struct PrismProductInfo: Sendable {
        public let id: String
        public let displayName: String
        public let description: String
        public let price: Decimal
        public let type: PrismProductType

        public init(id: String, displayName: String, description: String, price: Decimal, type: PrismProductType) {
            self.id = id
            self.displayName = displayName
            self.description = description
            self.price = price
            self.type = type
        }
    }

    // MARK: - Transaction Info

    public struct PrismTransactionInfo: Sendable {
        public let id: UInt64
        public let productID: String
        public let purchaseDate: Date
        public let expirationDate: Date?
        public let isUpgraded: Bool
        public let revocationDate: Date?

        public init(
            id: UInt64, productID: String, purchaseDate: Date, expirationDate: Date? = nil, isUpgraded: Bool = false,
            revocationDate: Date? = nil
        ) {
            self.id = id
            self.productID = productID
            self.purchaseDate = purchaseDate
            self.expirationDate = expirationDate
            self.isUpgraded = isUpgraded
            self.revocationDate = revocationDate
        }
    }

    // MARK: - Subscription Status

    public enum PrismSubscriptionStatus: Sendable, CaseIterable {
        case subscribed
        case expired
        case revoked
        case inBillingRetry
        case inGracePeriod
    }

    // MARK: - StoreKit Client

    @MainActor @Observable
    public final class PrismStoreKitClient {
        public private(set) var products: [PrismProductInfo] = []
        public private(set) var purchasedProductIDs: Set<String> = []

        private var transactionListener: Task<Void, Never>?

        public init() {}

        deinit {
            MainActor.assumeIsolated {
                transactionListener?.cancel()
            }
        }

        public func fetchProducts(ids: Set<String>) async throws {
            let storeProducts = try await Product.products(for: ids)
            products = storeProducts.map { product in
                let productType: PrismProductType =
                    switch product.type {
                    case .consumable: .consumable
                    case .nonConsumable: .nonConsumable
                    case .autoRenewable: .autoRenewable
                    case .nonRenewable: .nonRenewable
                    default: .nonConsumable
                    }
                return PrismProductInfo(
                    id: product.id,
                    displayName: product.displayName,
                    description: product.description,
                    price: product.price,
                    type: productType
                )
            }
        }

        public func purchase(productID: String) async throws -> PrismTransactionInfo? {
            guard let product = try await Product.products(for: [productID]).first else {
                return nil
            }
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                purchasedProductIDs.insert(transaction.productID)
                return PrismTransactionInfo(
                    id: transaction.id,
                    productID: transaction.productID,
                    purchaseDate: transaction.purchaseDate,
                    expirationDate: transaction.expirationDate,
                    isUpgraded: transaction.isUpgraded,
                    revocationDate: transaction.revocationDate
                )
            case .userCancelled, .pending:
                return nil
            @unknown default:
                return nil
            }
        }

        public func restorePurchases() async {
            for await result in Transaction.currentEntitlements {
                if let transaction = try? checkVerified(result) {
                    purchasedProductIDs.insert(transaction.productID)
                }
            }
        }

        public func subscriptionStatus(for groupID: String) async -> PrismSubscriptionStatus {
            guard let statuses = try? await Product.SubscriptionInfo.status(for: groupID),
                let status = statuses.first
            else {
                return .expired
            }
            switch status.state {
            case .subscribed: return .subscribed
            case .expired: return .expired
            case .revoked: return .revoked
            case .inBillingRetryPeriod: return .inBillingRetry
            case .inGracePeriod: return .inGracePeriod
            default: return .expired
            }
        }

        public func startTransactionListener() {
            transactionListener = Task.detached { [weak self] in
                for await result in Transaction.updates {
                    if let transaction = try? self?.checkVerified(result) {
                        _ = await MainActor.run {
                            self?.purchasedProductIDs.insert(transaction.productID)
                        }
                        await transaction.finish()
                    }
                }
            }
        }

        // MARK: - Private

        private nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
            switch result {
            case .unverified: throw StoreKitError.notAvailableInStorefront
            case .verified(let value): return value
            }
        }
    }
#endif
