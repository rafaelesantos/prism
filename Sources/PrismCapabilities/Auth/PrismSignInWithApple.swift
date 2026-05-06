#if canImport(AuthenticationServices)
    import AuthenticationServices

    // MARK: - Apple ID Scope

    public enum PrismAppleIDScope: Sendable, CaseIterable {
        case email
        case fullName
    }

    // MARK: - Apple ID Credential

    public struct PrismAppleIDCredential: Sendable {
        public let userID: String
        public let email: String?
        public let fullName: String?
        public let identityToken: Data?
        public let authorizationCode: Data?

        public init(
            userID: String, email: String? = nil, fullName: String? = nil, identityToken: Data? = nil,
            authorizationCode: Data? = nil
        ) {
            self.userID = userID
            self.email = email
            self.fullName = fullName
            self.identityToken = identityToken
            self.authorizationCode = authorizationCode
        }
    }

    // MARK: - Credential State

    public enum PrismAppleIDCredentialState: Sendable, CaseIterable {
        case authorized
        case revoked
        case notFound
        case transferred
    }

    // MARK: - Sign In Client

    @MainActor
    public final class PrismSignInWithAppleClient {

        public init() {}

        public func signIn(scopes: [PrismAppleIDScope]) async throws -> PrismAppleIDCredential {
            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = scopes.map { scope in
                switch scope {
                case .email: .email
                case .fullName: .fullName
                }
            }

            return try await withCheckedThrowingContinuation { continuation in
                let delegate = SignInDelegate { result in
                    continuation.resume(with: result)
                }
                let controller = ASAuthorizationController(authorizationRequests: [request])
                objc_setAssociatedObject(controller, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN)
                controller.delegate = delegate
                controller.performRequests()
            }
        }

        public func checkCredentialState(userID: String) async -> PrismAppleIDCredentialState {
            await withCheckedContinuation { continuation in
                ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userID) { state, _ in
                    let prismState: PrismAppleIDCredentialState =
                        switch state {
                        case .authorized: .authorized
                        case .revoked: .revoked
                        case .notFound: .notFound
                        case .transferred: .transferred
                        @unknown default: .notFound
                        }
                    continuation.resume(returning: prismState)
                }
            }
        }
    }

    // MARK: - Private Delegate

    private final class SignInDelegate: NSObject, ASAuthorizationControllerDelegate, @unchecked Sendable {
        private let completion: (Result<PrismAppleIDCredential, Error>) -> Void

        init(completion: @escaping (Result<PrismAppleIDCredential, Error>) -> Void) {
            self.completion = completion
        }

        func authorizationController(
            controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization
        ) {
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                completion(.failure(ASAuthorizationError(.unknown)))
                return
            }
            let fullName = [credential.fullName?.givenName, credential.fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            let prismCredential = PrismAppleIDCredential(
                userID: credential.user,
                email: credential.email,
                fullName: fullName.isEmpty ? nil : fullName,
                identityToken: credential.identityToken,
                authorizationCode: credential.authorizationCode
            )
            completion(.success(prismCredential))
        }

        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            completion(.failure(error))
        }
    }
#endif
